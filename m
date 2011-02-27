From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 08:54:12 +0100
Message-ID: <1298793252.8726.45.camel@edumazet-laptop>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Albert Cahalan <acahalan@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45941 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab1B0HyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 02:54:17 -0500
In-Reply-To: <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 08:02 +0100, Mikael Abrahamsson=
 a =C3=A9crit :
> On Sun, 27 Feb 2011, Albert Cahalan wrote:
>=20
> > Nanoseconds seems fine; it's unlikely you'd ever want
> > more than 4.2 seconds (32-bit unsigned) of queue.
>=20
> I think this is shortsighted and I'm sure someone will come up with a=
 case=20
> where 4.2 seconds isn't enough. Let's not build in those kinds of=20
> limitations from start.
>=20
> Why not make it 64bit and go to picoseconds from start?
>=20
> If you need to make it 32bit unsigned, I'd suggest to start from=20
> microseconds instead. It's less likely someone would want less than a=
=20
> microsecond of queue, than someone wanting more than 4.2 seconds of q=
ueue.
>=20

32 or 64 bits doesnt matter a lot. At Qdisc stage we have up to 40 byte=
s
available in skb->sb[] for our usage.

Problem is some machines have slow High Resolution timing services.

_If_ we have a time limit, it will probably use the low resolution (aka
jiffies), unless high resolution services are cheap.

I was thinking not having an absolute hard limit, but an EWMA based one=
=2E



