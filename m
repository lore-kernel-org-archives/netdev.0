From: Jeff Garzik <jeff@garzik.org>
Subject: Re: DM9000: Remove blackfin as special case.
Date: Tue, 17 Jun 2008 23:02:02 -0400
Message-ID: <48587AAA.8080005@garzik.org>
References: <20080615233648.597885961@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cooloney@kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48427 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862AbYFRDCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:02:06 -0400
In-Reply-To: <20080615233648.597885961@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> The first part of remove the DEFAULT_TRIGGER should
> be relatively easy to fixup in whatever blackfin archs
> still use this.
> 
> The otherbits, I would recommend the relevant blackfin
> IO headers should deal with defining the six functions to
> the relevant blackfin implementation.
> 
> I would have sent this directly to the blackfin list, but
> it is marked as subscribers only.
> 
> CC: Bryan Wu <cooloney@kernel.org>
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> 
> Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
> ===================================================================
> --- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-16 00:31:57.000000000 +0100
> +++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-16 00:32:17.000000000 +0100
> @@ -47,18 +47,6 @@
>  #define CARDNAME	"dm9000"
>  #define DRV_VERSION	"1.31"
>  
> -#ifdef CONFIG_BLACKFIN
> -#define readsb	insb
> -#define readsw	insw
> -#define readsl	insl
> -#define writesb	outsb
> -#define writesw	outsw
> -#define writesl	outsl
> -#define DEFAULT_TRIGGER IRQF_TRIGGER_HIGH
> -#else
> -#define DEFAULT_TRIGGER (0)
> -#endif
> -
>  /*
>   * Transmit timeout, default 5 seconds.
>   */
> @@ -1012,10 +1000,8 @@ dm9000_open(struct net_device *dev)
>  	/* If there is no IRQ type specified, default to something that
>  	 * may work, and tell the user that this is a problem */
>  
> -	if (irqflags == IRQF_TRIGGER_NONE) {
> +	if (irqflags == IRQF_TRIGGER_NONE)
>  		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
> -		irqflags = DEFAULT_TRIGGER;

Is this for 2.6.26 or 2.6.27?

And please CC me on net driver patches, thanks...

	Jeff



