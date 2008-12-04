From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: qmgr for ixp4xx
Date: Thu, 04 Dec 2008 22:06:21 +0100
Message-ID: <m3zljby7jm.fsf@maximus.localdomain>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50970 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754163AbYLDVGX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 16:06:23 -0500
In-Reply-To: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Tue\, 2 Dec
 2008 19\:44\:40 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> As I am trying to use my HSSs as 4E1, I find that the FIFOs for each
> HDLC should be 1 word wide and not 4 words wide. I think that this
> finally means that when accessing the queues, I have to do the
> following modification.
>
> +++ linux-2.6.26.7/include/asm-arm/arch-ixp4xx/qmgr.h	2008-12-02
> 10:47:23.000000000 +0100
> @@ -67,16 +67,17 @@
>  void qmgr_release_queue(unsigned int queue);
>
>
> -static inline void qmgr_put_entry(unsigned int queue, u32 val)
> +static inline void qmgr_put_entry(unsigned int queue, unsigned int p=
ipe,
> +                   u32 val)
>  {
>  	extern struct qmgr_regs __iomem *qmgr_regs;
> -	__raw_writel(val, &qmgr_regs->acc[queue][0]);
> +	__raw_writel(val, &qmgr_regs->acc[queue][pipe]);
>  }
>
> -static inline u32 qmgr_get_entry(unsigned int queue)
> +static inline u32 qmgr_get_entry(unsigned int queue, unsigned int pi=
pe)
>  {
>  	extern struct qmgr_regs __iomem *qmgr_regs;
> -	return __raw_readl(&qmgr_regs->acc[queue][0]);
> +	return __raw_readl(&qmgr_regs->acc[queue][pipe]);
>  }

The FIFOs are some internal property of HDLC controller (it isn't
documented but they probably connect the bus master DMA controller to
the bit-stuffer and transmitter (and bit-destuffer and receiver in the
RX path)). You just need to send a message to HSS to tell it the
correct value.

Queues, on the other hand, can be 1, 2 or 4-words wide (32, 64 or 128
bits). I think nothing uses/needs 2 or 4-word queues so they aren't
implemented.

4E1 mode uses the same 1-word queues. It just uses more queues :-)
--=20
Krzysztof Halasa
