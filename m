From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xfrm: Call IP receive handler directly for
 inbound tunnel-mode packets
Date: Mon, 02 Jan 2012 09:18:02 +0100
Message-ID: <1325492282.2526.32.camel@edumazet-laptop>
References: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu>
	 <20120102072828.GA5380@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ward <david.ward@ll.mit.edu>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60400 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab2ABISH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 03:18:07 -0500
Received: by werm1 with SMTP id m1so7320541wer.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 00:18:06 -0800 (PST)
In-Reply-To: <20120102072828.GA5380@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 18:28 +1100, Herbert Xu a =C3=A9crit :

> You can't do this as this may cause stack overruns if we nest
> too deeply.
>=20

I was considering adding a generic helper, for tunneling,
taking into account the depth for current packet.

[ calling netif_receive_skb() instead of netif_rx(), to solve the OOO
problem occurring on SMP when interrupts are spreaded on several cpus ]


We could use the delta between skb->data and skb->head as an estimation
of this depth, in order not adding a new skb field ?

#define DEPTH_THRESHOLD (NET_SKB_PAD + 64)

static inline void netif_reinject(struct sk_buff *skb)
{
if (skb->data - skb->head < DEPTH_THRESHOLD)
	netif_receive_skb(skb);
else
	netif_rx(skb);
}
