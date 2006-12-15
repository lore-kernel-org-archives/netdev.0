From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 07/14] e1000: workaround for the ESB2 NIC RX unit issue
Date: Fri, 15 Dec 2006 09:33:26 -0500
Message-ID: <4582B236.8040209@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175343.3365.123.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55161 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbWLOOd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:33:28 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175343.3365.123.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: workaround for the ESB2 NIC RX unit issue
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> In rare occasions, ESB2 systems would end up started without the RX
> unit being turned on. Add a check that runs post-init to work around this
> issue.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -2579,6 +2579,13 @@ e1000_watchdog(unsigned long data)
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

NAK, ditto


