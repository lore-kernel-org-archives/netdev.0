From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Sun, 23 Apr 2006 15:43:22 +1000
Message-ID: <E1FXXNS-0003dJ-00@gondolin.me.apana.org.au>
References: <20060421102757.45d26db0@localhost.localdomain>
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org, tomri@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:26888 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751285AbWDWFni
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 01:43:38 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060421102757.45d26db0@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<tomri@gmx.net> wrote:
>
> And the output in the kernel ring buffer is:
> dmesg | grep xmit
> ei_start_xmit(): skb->data unaligned fffffc0019be55d5 align to fffffc001ef37620
> length 60

Very weird.  The length seems to indicate that this packet went through
skb_padto.  However, I can't see how skb_padto can produce an unaligned
skb if the input was aligned (the input coming out of TCP should definitely
be aligned).

Can you please put some printks in to find out if

1) skb_padto is being called.
2) Is the input to skb_padto aligned?
 
> Here some stack traces with BUG_ON/ WARN_ON added by me in more places to trace
> down the problem:
> Kernel bug at net/ipv4/ip_output.c:297
> cc1(2841): Kernel Bug 1
> pc = [<fffffc000062a92c>]  ra = [<fffffc00006407c8>]  ps = 0000    Not tainted
> pc is at ip_queue_xmit+0x59c/0x690
> ra is at tcp_transmit_skb+0x588/0xbb0

This is pretty meaningless if you don't show us the check that you added
to produce this.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
