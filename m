From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 12:00:51 +0200
Message-ID: <1277719251.4235.306.camel@edumazet-laptop>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	 <1277716394.4235.235.camel@edumazet-laptop>
	 <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Courtier-Dutton <james.dutton@gmail.com>,
	netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:39908 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960Ab0F1KA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 06:00:58 -0400
Received: by wwi17 with SMTP id 17so2472026wwi.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 03:00:54 -0700 (PDT)
In-Reply-To: <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 02:33 -0700, Mitchell Erblich a =C3=A9crit=
 :

>=20
> Why wouldn't the ability to recv frames after a Recv FIFO overflow
>  indicate that a reset is NOT required?
>=20

Do you have datasheets of all b44 chips ? I dont.

> Thus,  should't it be an indication of congestion if associated with =
a single
> flow and either speed up (reduce latency to service) the recv side or=
=20
> slow down the xmit side?

I dont understand what you are saying. xmit is not the problem here.
And driver is flow agnostic. Its well before network stack.

Problem is we receive a spike of RX network frames (possibly UDP or som=
e
other RX only trafic), and chip raises an RX fifo overflow _error_
indication.

Some hardware are buggy enough that such error indication is fatal and
_require_ hardware reset. Thats life. I suspect b44 driver doing a full
reset is not a random guess from driver author, but to avoid a complete
NIC lockup.

Refs:

http://bugzilla.kernel.org/show_bug.cgi?id=3D7696
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D216338

commit 5fc7d61aee1a7f7d3448f8fbccaa93371ebeecb0



