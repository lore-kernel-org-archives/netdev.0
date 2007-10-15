From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169 Fix hang in rtl8169_down (NAPI)
Date: Mon, 15 Oct 2007 13:53:10 -0700 (PDT)
Message-ID: <20071015.135310.41635381.davem@davemloft.net>
References: <20071015202546.GA4060@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: markus@trippelsdorf.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbXJOUxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 16:53:10 -0400
In-Reply-To: <20071015202546.GA4060@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Trippelsdorf <markus@trippelsdorf.de>
Date: Mon, 15 Oct 2007 22:25:46 +0200

> commit bea3348eef27e6044b6161fd04c3152215f96411 :
> [NET]: Make NAPI polling independent of struct net_device objects.
> causes my machine to hang on shutdown. The following patch fixes the
> problem for me.
> 
> Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>

This change doesn't make any sense.

> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 419c00c..2cddbf8 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2888,10 +2888,12 @@ core_down:
>  
>  	synchronize_irq(dev->irq);
>  
> +#ifdef CONFIG_R8169_NAPI
>  	if (!poll_locked) {
>  		napi_disable(&tp->napi);
>  		poll_locked++;
>  	}
> +#endif
>  
>  	/* Give a racing hard_start_xmit a few cycles to complete. */
>  	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */

If anything the test should be the other way around, use of
napi interfaces should be used when R8169_NAPI is set.

You're just papering around some other bug in the NAPI support
of this driver, which someone will need to figure out and fix
correctly.

But thanks for the report, and the patch, whilst bogus, might
provide a clue.
