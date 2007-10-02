From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [patch 06/13] Fix a potential NULL pointer dereference in
	uli526x_interrupt() in drivers/net/tulip/uli526x.c
Date: Tue, 2 Oct 2007 15:20:00 -0600
Message-ID: <20071002212000.GC31301@colo.lackof.org>
References: <200710022111.l92LBcIs022492@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, micah.gruber@gmail.com,
	grundler@parisc-linux.org, kyle@mcmartin.ca
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:59399 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754337AbXJBVUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:20:18 -0400
Content-Disposition: inline
In-Reply-To: <200710022111.l92LBcIs022492@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 02:11:38PM -0700, akpm@linux-foundation.org wrote:
> From: Micah Gruber <micah.gruber@gmail.com>
> 
> This patch fixes an apparent potential null dereference bug where we
> dereference dev before a null check.  This patch simply remvoes the
> can't-happen test for a null pointer.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks!
grant

> Acked-by: Jeff Garzik <jeff@garzik.org>
> Acked-by: Kyle McMartin <kyle@mcmartin.ca>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/tulip/uli526x.c |    5 -----
>  1 file changed, 5 deletions(-)
> 
> diff -puN drivers/net/tulip/uli526x.c~fix-a-potential-null-pointer-dereference-in-uli526x_interrupt drivers/net/tulip/uli526x.c
> --- a/drivers/net/tulip/uli526x.c~fix-a-potential-null-pointer-dereference-in-uli526x_interrupt
> +++ a/drivers/net/tulip/uli526x.c
> @@ -664,11 +664,6 @@ static irqreturn_t uli526x_interrupt(int
>  	unsigned long ioaddr = dev->base_addr;
>  	unsigned long flags;
>  
> -	if (!dev) {
> -		ULI526X_DBUG(1, "uli526x_interrupt() without DEVICE arg", 0);
> -		return IRQ_NONE;
> -	}
> -
>  	spin_lock_irqsave(&db->lock, flags);
>  	outl(0, ioaddr + DCR7);
>  
> _
