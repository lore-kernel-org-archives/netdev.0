From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 14/22] e1000: always turn on receives on esb2
Date: Mon, 11 Dec 2006 09:47:39 -0500
Message-ID: <457D6F8B.5000701@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230316.30109.64868.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46396 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760659AbWLKOrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:47:42 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230316.30109.64868.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> In rare occasions, esb2 systems would end up started without the RX
> unit being turned on. Add a check that runs post-init to make sure.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 12f9f61..67fc379 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -2673,6 +2673,13 @@ e1000_watchdog(unsigned long data)
>  			netif_wake_queue(netdev);
>  			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
>  			adapter->smartspeed = 0;
> +		} else {
> +			/* make sure the receive unit is started */
> +			if (adapter->hw.mac_type == e1000_80003es2lan) {
> +				struct e1000_hw *hw = &adapter->hw;
> +				uint32_t rctl = E1000_READ_REG(hw, RCTL);
> +				E1000_WRITE_REG(hw, RCTL, rctl | E1000_RCTL_EN);
> +			}

seems like feature flag territory to me


