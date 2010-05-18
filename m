From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v3] Fix SJA1000 command register writes on SMP systems
Date: Tue, 18 May 2010 23:31:09 +0200
Message-ID: <20100518213109.GA29894@merkur.ravnborg.org>
References: <4BF2E512.1090109@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:58175 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563Ab0ERVbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 17:31:11 -0400
Content-Disposition: inline
In-Reply-To: <4BF2E512.1090109@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver.

> diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
> index 97a622b..de8e778 100644
> --- a/drivers/net/can/sja1000/sja1000.h
> +++ b/drivers/net/can/sja1000/sja1000.h
> @@ -167,6 +167,7 @@ struct sja1000_priv {
>  
>  	void __iomem *reg_base;	 /* ioremap'ed address to registers */
>  	unsigned long irq_flags; /* for request_irq() */
> +	spinlock_t cmdreg_lock;  /* lock for concurrent cmd register writes */
>  
>  	u16 flags;		/* custom mode flags */
>  	u8 ocr;			/* output control register */

You define your spinlock inside a struct so you cannot use
DEFINE_SPINLOCK().

But then you need to use spin_lock_init() - which I fail to see
you are doing in your patch.

	Sam
