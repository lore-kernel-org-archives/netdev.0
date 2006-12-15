From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/14] e1000: omit stats for broken counter in 82543
Date: Fri, 15 Dec 2006 09:30:21 -0500
Message-ID: <4582B17D.3070500@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175100.3365.115.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55112 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621AbWLOOaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:30:23 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175100.3365.115.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: omit stats for broken counter in 82543
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The 82543 chip does not count tx_carrier_errors properly in FD mode;
> report zeros instead of garbage.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    5 +++++
>  1 file changed, 5 insertions(+), 0 deletion(-)
> 
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -3580,7 +3580,12 @@ e1000_update_stats(struct e1000_adapter 
>  	adapter->net_stats.tx_errors = adapter->stats.txerrc;
>  	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
>  	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
>  	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
> +	if (adapter->hw.mac_type == e1000_82543 &&
> +	    adapter->link_duplex == FULL_DUPLEX) {
> +		adapter->net_stats.tx_carrier_errors = 0;
> +		adapter->stats.tncrs = 0;
> +	}

Needs to use an "i have broken stats" feature flag, rather than adding 
yet another mac_type test into the code.  This testing of MAC type 
rather than feature flags is a major e1000 problem, and it bloats the 
driver quite a bit.  Intel has been told for /months/ this is a problem, 
yet I still see patches like this.

This is one of the comments I sent to Auke.

	Jeff



