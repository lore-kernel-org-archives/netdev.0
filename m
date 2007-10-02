From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] dm9601: Fix receive MTU
Date: Tue, 02 Oct 2007 13:01:29 -0400
Message-ID: <47027969.8060209@garzik.org>
References: <87myv35aoo.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37322 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbXJBRBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:01:31 -0400
In-Reply-To: <87myv35aoo.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> Please apply to 2.6.23.
> ---
> dm9601 didn't take the ethernet header into account when calculating
> RX MTU, causing packets bigger than 1486 to fail.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  drivers/net/usb/dm9601.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.23-rc8/drivers/net/usb/dm9601.c
> ===================================================================
> --- linux-2.6.23-rc8.orig/drivers/net/usb/dm9601.c
> +++ linux-2.6.23-rc8/drivers/net/usb/dm9601.c
> @@ -405,7 +405,7 @@
>  	dev->net->ethtool_ops = &dm9601_ethtool_ops;
>  	dev->net->hard_header_len += DM_TX_OVERHEAD;
>  	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> -	dev->rx_urb_size = dev->net->mtu + DM_RX_OVERHEAD;
> +	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD;

applied.  in the future, please note (and avoid) a patch formatting 
error.  As noted in #14 of Documentation/SubmittingPatches, any comments 
on the patch like "Please apply to 2.6.23" should go AFTER the patch 
description and "---" separator.

Without hand editing, the normal tools everybody uses for importing 
patches would delete your "dm9601 didn't take the ethernet header..." 
description, leaving only the "Please apply to 2.6.23." part and nothing 
else.

I did the hand-editing, but please try to follow the standard patch 
format in the future.


