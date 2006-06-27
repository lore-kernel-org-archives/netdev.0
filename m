From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Mon, 26 Jun 2006 21:48:52 -0400
Message-ID: <44A08E84.1000902@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052029.25497.67575.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38868 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030598AbWF0Bsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:48:54 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052029.25497.67575.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> CRC stripping is breaking SMBUS-connected BMC's. We disable this
> feature to make it work. This fixes related bugs regarding SOL.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index c44ed6f..7787299 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1628,8 +1628,11 @@ e1000_setup_rctl(struct e1000_adapter *a
>  		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
>  		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
>  
> +	/* disable hardware stripping of CRC because it breaks
> +	 * BMC firmware connected over SMBUS
>  	if (adapter->hw.mac_type > e1000_82543)
>  		rctl |= E1000_RCTL_SECRC;
> +	 */
>  
>  	if (adapter->hw.tbi_compatibility_on == 1)
>  		rctl |= E1000_RCTL_SBP;
> @@ -1696,7 +1699,9 @@ e1000_setup_rctl(struct e1000_adapter *a
>  		rfctl |= E1000_RFCTL_IPV6_DIS;
>  		E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);
>  
> -		rctl |= E1000_RCTL_DTYP_PS | E1000_RCTL_SECRC;
> +		/* disable the stripping of CRC because it breaks
> +		 * BMC firmware connected over SMBUS */
> +		rctl |= E1000_RCTL_DTYP_PS /* | E1000_RCTL_SECRC */;

This is quite ugly.  You are basically bloating the code with historic, 
dead code, no different than filling the e1000/*.c with '#if 0' regions.

Just delete it, and explain why in the patch description.

	Jeff



