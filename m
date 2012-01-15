From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why does skb->tstamp use getnstimeofday?
Date: Sun, 15 Jan 2012 17:42:30 +0100
Message-ID: <1326645750.5287.48.camel@edumazet-laptop>
References: <op.v74shh18fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anatoly Sivov <mm05@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40602 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab2AOQme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2012 11:42:34 -0500
Received: by wgbds12 with SMTP id ds12so4688941wgb.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2012 08:42:33 -0800 (PST)
In-Reply-To: <op.v74shh18fzo5me@stalin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 janvier 2012 =C3=A0 19:11 +0400, Anatoly Sivov a =C3=A9c=
rit :
> Hello everyone.
>=20
> struct sk_buff has a field tstamp, which is used for high resolution =
rtt =20
> calculation.
> All operations with this field are done directly or indirectly via kt=
ime_* =20
> interface,
> which uses getnstimeofday function.
> My question is why does skb->tstamp use getnstimeofday?
> Isn't it better to use getrawmonotonic, where we are not inetrfered w=
ith =20
> ntp,  for rtt calculation?
>=20

It's using this since day 0, so cannot be changed or break applications=
,
which expect timeofday, not monotonic.

monotonic time services were added later.
