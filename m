From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: WARNING (skb_gso_segment) with tg3+bridge in 2.6.27
Date: Wed, 22 Oct 2008 15:45:02 +0800
Message-ID: <20081022074502.GA25058@gondor.apana.org.au>
References: <20081011172002.GA12659@pest> <20081013.004226.171259546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: berni@birkenwald.de, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37268 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750930AbYJVHpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 03:45:14 -0400
Content-Disposition: inline
In-Reply-To: <20081013.004226.171259546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 12:42:26AM -0700, David Miller wrote:
> From: Bernhard Schmidt <berni@birkenwald.de>
> Date: Sat, 11 Oct 2008 19:20:03 +0200
> 
> > [  289.588669] ------------[ cut here ]------------
> > [  289.588673] WARNING: at net/core/dev.c:1505 skb_gso_segment+0x82/0x1a7()
> > 
> >         if (WARN_ON(skb->ip_summed != CHECKSUM_PARTIAL)) {
> 
> So this is via tg3_tso_bug()
> 
>  ...
> > [  289.588760]  [<ffffffff803d14ab>] dev_queue_xmit+0x3aa/0x462
> > [  289.588778]  [<ffffffffa024ca8c>] ip6_output+0xce7/0xcff [ipv6]
> > [  289.588785]  [<ffffffffa023ade0>] br_dev_queue_push_xmit+0x75/0x79 [bridge]
> > [  289.588792]  [<ffffffffa023a2fe>] br_dev_xmit+0x66/0x7c [bridge]
> > [  289.588795]  [<ffffffff803d1535>] dev_queue_xmit+0x434/0x462
> > [  289.588811]  [<ffffffffa024ca8c>] ip6_output+0xce7/0xcff [ipv6]
> > [  289.588827]  [<ffffffffa024b8b4>] ip6_xmit+0x35c/0x439 [ipv6]
> > [  289.588848]  [<ffffffffa026d303>] inet6_csk_xmit+0x223/0x236 [ipv6]
> > [  289.588850]  [<ffffffff80443e8e>] _spin_lock_irqsave+0x21/0x29
> > [  289.588853]  [<ffffffff804059ff>] tcp_transmit_skb+0x60f/0x64e
> 
> And it seems we have a TCP TSO frame that went through bridging
> netfilter.

I'm pretty sure this particular backtrace is a result of tg3
enabling NETIF_F_TSO6 without also enabling NETIF_F_IPV6_CSUM.

So my question is to the tg3 developers, does having TSO6 without
IPv6 checksums ever make sense? Put it another way, how can you
have a device that can compute checksums for TCPv6 packets but
not UDPv6 packets?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
