From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Tue, 3 Aug 2010 14:11:30 +0800
Message-ID: <AANLkTikJMih-CAA_d95ot0z57EOhMFsiNc2nnki6v6LY@mail.gmail.com>
References: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com>
	<AANLkTikNOstJr3qqMUqtUoOm1xHOjw5uM7NpQUNJz4PR@mail.gmail.com>
	<OF46AA822C.08F8EAED-ON65257774.001F5AE3-65257774.00209BBF@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, bhutchings@solarflare.com, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org, therbert@google.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46284 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894Ab0HCGLw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 02:11:52 -0400
Received: by wyb39 with SMTP id 39so4046343wyb.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 23:11:51 -0700 (PDT)
In-Reply-To: <OF46AA822C.08F8EAED-ON65257774.001F5AE3-65257774.00209BBF@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 1:57 PM, Krishna Kumar2 <krkumar2@in.ibm.com> wr=
ote:
> Hi Changli,
>
> Good catch.
>
> Instead of adding support for ethernet header or pull/push,
> I could defer the skb_push(ETH_HLEN), something like:
>
> static int macvtap_forward(struct net_device *dev, struct sk_buff *sk=
b)
> {
> =A0 =A0 =A0 =A0struct macvtap_queue *q =3D macvtap_get_queue(dev, skb=
);
> =A0 =A0 =A0 =A0if (!q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> =A0 =A0 =A0 =A0if (skb_queue_len(&q->sk.sk_receive_queue) >=3D dev->t=
x_queue_len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> + =A0 =A0 =A0 skb_push(skb, ETH_HLEN);
> =A0 =A0 =A0 =A0...
> }
>
> and remove the same in macvtap_receive. Will this be better?
>

I am confused by the call sites of macvlan_dev.receive and
macvlan_dev.forward. They both are possible to be called in both
RX(skb->data points to network header) and TX(skb->data points to
ethernet) paths. The current code in macvtap shows that
macvlan_dev.receive should be called in network layer, and
macvlan_dev.forward should be called in dev layer. Am I correct?


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
