From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 14:32:34 +0200
Message-ID: <1335443554.2775.33.camel@edumazet-glaptop>
References: <1335427854.2775.15.camel@edumazet-glaptop>
	 <20120426.043623.1317043382565428400.davem@davemloft.net>
	 <1335431402.2775.24.camel@edumazet-glaptop>
	 <20120426.051800.637617874638567499.davem@davemloft.net>
	 <1335432147.2775.27.camel@edumazet-glaptop>
	 <CANP3RGdnZk5b-gMkF8BPScrp9xos4X1u3n58ocuBQhTT7taE8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, ycheng@google.com
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57403 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337Ab2DZMck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 08:32:40 -0400
Received: by eaaq12 with SMTP id q12so314644eaa.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 05:32:39 -0700 (PDT)
In-Reply-To: <CANP3RGdnZk5b-gMkF8BPScrp9xos4X1u3n58ocuBQhTT7taE8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 03:09 -0700, Maciej =C5=BBenczykowski wrote:
> it would be very useful if there was an api for freeing skb->head mem=
ory...
>=20
> I've fooled around with a single memory buffer for both the head and
> the data and seen huge performance wins under heavy packet load (half
> the amount of malloc/free), but could never quite get it to be 100%
> stable.

My patch is almost ready, and seems very good.

I added a param to skb_build() to tell the memory comes from a (sub)pag=
e

tg3 uses the new thing.

GRO does the correct merging.

(by the way, I noticed GRO lies about skb truesize... since it
accumulates frag lengths instead of allocated space... with a 1448/2048
mismatch for MTU=3D1500)

And this apparently solves my slub performance issue I had on my dual
quad core machine, since I no longer hit slub slow path.
