From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 07 Nov 2011 15:33:42 +0100
Message-ID: <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EB6AE62.5050803@itcare.pl>
	 <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	 <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	 <1320608290.6506.33.camel@edumazet-laptop>
	 <1320673364.3020.21.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54949 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab1KGOdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 09:33:46 -0500
Received: by wyh15 with SMTP id 15so4511039wyh.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 06:33:45 -0800 (PST)
In-Reply-To: <1320673364.3020.21.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 novembre 2011 =C3=A0 13:42 +0000, Ben Hutchings a =C3=A9cri=
t :

> A routing cache this big is not going to fit in the processor caches,
> anyway; in fact even the hash table may not.  So a routing cache hit =
is
> likely to involve processor cache misses.  After David's work to make
> cacheless operation faster, I suspect that such a 'hit' can be a net
> loss.  But it *is* necessary to run a benchmark to answer this (and t=
he
> answer will obviously vary between systems).
>=20

I dont know why you think full hash table should fit processor cache.
If it does, thats perfect, but its not a requirement.

This is one cache miss, to get the pointer to the first element in
chain. Of course this might be a cache hit if several packets for a
given flow are processed in a short period of time.

Given a dst itself is 256 bytes (4 cache lines), one extra cache miss t=
o
get the pointer to dst is not very expensive.

At least, in recent kernels we dont change dst->refcnt in forwarding
patch (usinf NOREF skb->dst)

One particular point is the atomic_inc(dst->refcnt) we have to perform
when queuing an UDP packet if socket asked PKTINFO stuff (for example a
typical DNS server has to setup this option)

I have one patch somewhere that stores the information in skb->cb[] and
avoid the atomic_{inc|dec}(dst->refcnt).
