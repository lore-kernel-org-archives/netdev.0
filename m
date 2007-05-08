From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] skge: default WOL should be magic only
Date: Tue, 08 May 2007 01:06:34 -0400
Message-ID: <4640055A.5000502@garzik.org>
References: <20070507110036.050e7b5b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54231 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967843AbXEHFGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:06:37 -0400
In-Reply-To: <20070507110036.050e7b5b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> By default, the skge driver now enables wake on magic and wake on PHY.
> This is a bad default (bug), wake on PHY means machine will never shutdown 
> if connected to a switch.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a
> 
> ---
>  drivers/net/skge.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-07 10:01:47.000000000 -0700
> +++ sky2-2.6.21/drivers/net/skge.c	2007-05-07 10:03:29.000000000 -0700
> @@ -3591,7 +3591,7 @@ static struct net_device *skge_devinit(s
>  	skge->duplex = -1;
>  	skge->speed = -1;
>  	skge->advertising = skge_supported_modes(hw);
> -	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
> +	skge->wol = pci_wake_enabled(hw->pdev) ? WAKE_MAGIC : 0;

NAK.  You still need to check for buggy chips (as in patch #2)

If stable@kernel.org applied this, they need to fix it as you will for 
upstream...

	Jeff


