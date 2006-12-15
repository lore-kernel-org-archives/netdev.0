From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/14] e1000: narrow down the scope of the tipg timer
 tweak
Date: Fri, 15 Dec 2006 09:34:40 -0500
Message-ID: <4582B280.7000101@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175512.3365.129.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55186 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbWLOOem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:34:42 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175512.3365.129.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: narrow down the scope of the tipg timer tweak
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> the driver has (ancient) code for messing with TIPG from the 82542 days.
> Unfortunately this code was running on our current adapters and setting
> TIPG for fiber to be +1 over the copper value.  This caused 1.45Mpps
> to be sent instead of 1.487Mpps.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -1582,9 +1582,9 @@ e1000_configure_tx(struct e1000_adapter 
>  	}
>  
>  	/* Set the default values for the Tx Inter Packet Gap timer */
> -
> -	if (hw->media_type == e1000_media_type_fiber ||
> -	    hw->media_type == e1000_media_type_internal_serdes)
> +	if (adapter->hw.mac_type <= e1000_82547_rev_2 &&
> +	    (hw->media_type == e1000_media_type_fiber ||
> +	     hw->media_type == e1000_media_type_internal_serdes))
>  		tipg = DEFAULT_82543_TIPG_IPGT_FIBER;
>  	else
>  		tipg = DEFAULT_82543_TIPG_IPGT_COPPER;

NAK, ditto


