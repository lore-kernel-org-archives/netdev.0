From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: dev_alloc_skb and latency issues
Date: Tue, 26 Oct 2010 10:25:16 +0200
Message-ID: <1288081516.3169.3.camel@edumazet-laptop>
References: <AANLkTikzQw3gHT8RZUD4cnGny5Xwh6_X==zFXBfi5muS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42034 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450Ab0JZIZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 04:25:21 -0400
Received: by wwe15 with SMTP id 15so4469463wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 01:25:20 -0700 (PDT)
In-Reply-To: <AANLkTikzQw3gHT8RZUD4cnGny5Xwh6_X==zFXBfi5muS@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 10:04 +0200, Jean-Michel Hautbois a =C3=
=A9crit :
> Hi Everyone !
>=20
> I am new to this mailing list, and I hope this kind of question hasn'=
t
> already been solved before (didn't find anything in the archives...).
> I am facing some latency issues in the network layer (I am using a
> bridge in order to transmit data between one interface to another).
>=20
> I am focusing on allocation of memory using alloc_skb for *every* new
> packet, and freeing of each packet before receiving a new one.
> My use case is quite easy : I always have similar packets (some bytes
> are changed, but the size is the same).
> I don't think I am the only one with such a use case, and am thinking
> about an optimization in this case (probably for others too) : why do
> we have to allocate using kmem_cache for all the new packets ?
>=20
> We could probably use a little piece of code which would reuse the
> buffer if it hasn't to be used by anyone else.
> I am thinking that if the buffer is ready to be freed (in kfree_skb o=
r
> skb_release_all for instance) then, mark the skb as "free" but do not
> actually free memory.
> On the next dev_alloc_skb, check this mark, and if it is present, do
> not allocate, and just "memset" the skb.
>=20
> This would be in my point of view really efficient when packets are s=
imilar.
> Anyway, you probably have ideas about that stuff, and I am waiting fo=
r
> your advices about that :).

Once you add all necessary code to handle a new cache layer, you end in
a situation is brings nothing but extra cost and bugs (check recent
discussion about rx_recycle stuff in gianfar driver)

Really, kmem_cache is pretty fast and scalable. If not, better to work
on this, instead of adding yet another layer.



