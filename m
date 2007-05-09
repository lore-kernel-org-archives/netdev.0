From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] skge: default WOL should be magic only (rev2)
Date: Wed, 09 May 2007 19:25:44 -0400
Message-ID: <46425878.9060102@garzik.org>
References: <20070507110036.050e7b5b@freekitty> <4640055A.5000502@garzik.org> <20070508133620.0a7c6d12@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50092 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759094AbXEIXZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 19:25:47 -0400
In-Reply-To: <20070508133620.0a7c6d12@localhost>
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
>  drivers/net/skge.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> --- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-08 10:06:39.000000000 -0700
> +++ sky2-2.6.21/drivers/net/skge.c	2007-05-08 10:21:51.000000000 -0700
> @@ -3594,7 +3594,9 @@ static struct net_device *skge_devinit(s
>  	skge->duplex = -1;
>  	skge->speed = -1;
>  	skge->advertising = skge_supported_modes(hw);
> -	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
> +
> +	if (pci_wake_enabled(hw->pdev))
> +		skge->wol = wol_supported(hw) & WAKE_MAGIC;

thanks for the revision, applied


