From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [CORRECTION][PATCH] Fix a potential NULL pointer dereference in
 uli526x_interrupt() in drivers/net/tulip/uli526x.c
Date: Thu, 13 Sep 2007 02:03:46 -0700
Message-ID: <20070913020346.979647c1.akpm@linux-foundation.org>
References: <46DD13CE.6010905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, Grant Grundler <grundler@parisc-linux.org>
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35485 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754504AbXIMJED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 05:04:03 -0400
In-Reply-To: <46DD13CE.6010905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 04 Sep 2007 16:14:06 +0800 Micah Gruber <micah.gruber@gmail.com> wrote:

> This patch fixes a potential null dereference bug where we dereference dev before a null check. This patch simply moves the dereferencing after the null check.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
> ---
> 
> --- a/drivers/net/tulip/uli526x.c
> +++ b/drivers/net/tulip/uli526x.c
> @@ -663,7 +663,7 @@
>  {
>  	struct net_device *dev = dev_id;
>  	struct uli526x_board_info *db = netdev_priv(dev);
> -	unsigned long ioaddr = dev->base_addr;
> +	unsigned long ioaddr;
>  	unsigned long flags;
>  
>  	if (!dev) {
> @@ -671,6 +671,8 @@
>  		return IRQ_NONE;
>  	}
>  
> +	ioaddr = dev->base_addr;
> +
>  	spin_lock_irqsave(&db->lock, flags);
>  	outl(0, ioaddr + DCR7);
> 

I suspect the fix we want is:


--- a/drivers/net/tulip/uli526x.c~fix-a-potential-null-pointer-dereference-in-uli526x_interrupt
+++ a/drivers/net/tulip/uli526x.c
@@ -666,11 +666,6 @@ static irqreturn_t uli526x_interrupt(int
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
-	if (!dev) {
-		ULI526X_DBUG(1, "uli526x_interrupt() without DEVICE arg", 0);
-		return IRQ_NONE;
-	}
-
 	spin_lock_irqsave(&db->lock, flags);
 	outl(0, ioaddr + DCR7);
 
_

