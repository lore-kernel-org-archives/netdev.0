From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 20 Sep 2010 11:02:00 +0200
Message-ID: <1284973320.3420.49.camel@edumazet-laptop>
References: <1283852248.2338.160.camel@edumazet-laptop>
	 <20100910.125449.235704956.davem@davemloft.net>
	 <20100911123140.GA1939@del.dom.local>
	 <20100919.171725.245378386.davem@davemloft.net>
	 <20100920072149.GA6353@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52555 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab0ITJDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 05:03:14 -0400
Received: by wwj40 with SMTP id 40so80134wwj.1
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 02:03:11 -0700 (PDT)
In-Reply-To: <20100920072149.GA6353@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 07:21 +0000, Jarek Poplawski a =C3=A9=
crit :

> Probably we could start from enhacing moving drivers to paged skbs
> where possible. And maybe simplifying the skb model by not allowing
> frags and frag lists together?
>=20

Sure. I believe current model, pre-allocating skb in huge tx rings is a
waste of mem bandwidth anyway. (I am refering to the struct sk_buff
itself, not the payload part)

Of course some drivers are doing it right, using netdev_alloc_skb()
right before feeding this skb to network stack, not an old one.

> Btw, I wonder what is the exact reason we can't use only
> NET_SKBUFF_DATA_USES_OFFSET?

I see no real reason.

On 32bit arches, it might be faster to manipulate pointers, and not
'base+offset' values.



