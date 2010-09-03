From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Fri, 03 Sep 2010 07:23:52 +0200
Message-ID: <1283491432.3699.1371.camel@edumazet-laptop>
References: <20100830.095012.233695092.davem@davemloft.net>
	 <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local>
	 <20100901.145151.93454549.davem@davemloft.net>
	 <20100902083327.GA6246@ff.dom.local>
	 <1283419909.2454.137.camel@edumazet-laptop>
	 <20100902095502.GA8775@ff.dom.local>
	 <1283424105.2454.311.camel@edumazet-laptop>
	 <20100902212617.GA25150@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41801 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab0ICFa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 01:30:27 -0400
Received: by wwj40 with SMTP id 40so1985723wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 22:30:26 -0700 (PDT)
In-Reply-To: <20100902212617.GA25150@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 05:26 +0800, Herbert Xu a =C3=A9cr=
it :
> On Thu, Sep 02, 2010 at 12:41:45PM +0200, Eric Dumazet wrote:
> >=20
> > [PATCH net-next-2.6] gro: remove use of napi->dev
> >=20
> > Only use of napi->dev in GRO stack is the one found in napi_get_fra=
gs()
> >=20
> > We can remove it and use a plain dev_alloc_skb() call.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Why do you think napi->dev is not needed?

Origin was that sky2 could use one napi and two devices on it.
No bug, only a conceptual problem using a napi->dev.

Then, there is a small second point :

netdev_alloc_skb_ip_align() is using 'device' NUMA node to allocate
memory.

In this context, this makes litle sense because this skb is not going t=
o
be used by the device. Its a pure software one, for the sake of GRO
handling.

It would be more efficient to allocate an skb on NUMA node of the CPU
handling the softirq.

Thanks


