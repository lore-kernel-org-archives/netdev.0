From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 3/4] net:ethernet:aquantia: Fix transient invalid
 link down/up indications
Date: Thu, 21 Sep 2017 17:38:19 +0200
Message-ID: <20170921153819.GH27589@lunn.ch>
References: <cover.1505915085.git.igor.russkikh@aquantia.com>
 <6c8d54cad231f22ba46e08d3ec0fe9d6fcef7468.1505915085.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: Igor Russkikh <igor.russkikh@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:51427 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751739AbdIUPiV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 11:38:21 -0400
Content-Disposition: inline
In-Reply-To: <6c8d54cad231f22ba46e08d3ec0fe9d6fcef7468.1505915085.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 01:53:41PM +0300, Igor Russkikh wrote:
> Due to a bug in aquantia atlantic card firmware, it sometimes reports
> invalid link speed bits. That caused driver to report link down events,
> although link itself is totally fine.
> 
> This patch ignores such out of blue readings.
> 
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
> index 4f5ec9a..ab5d3cb 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
> @@ -351,8 +351,7 @@ int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self)
>  			break;
>  
>  		default:
> -			link_status->mbps = 0U;
> -			break;
> +			return -1;

Hi Igno

Please use a proper error code.

       Andrew
