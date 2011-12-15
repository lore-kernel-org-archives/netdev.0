From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: TCP fast retransmit
Date: Thu, 15 Dec 2011 08:41:06 +0100
Message-ID: <201112150841.08087.carsten@wolffcarsten.de>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de> <CAK6E8=dcG3mw8r4FXt62G-0uoRNa9tcyQL3DS62MYe8F=9R6Nw@mail.gmail.com> <1323901909.2631.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:44873 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab1LOHl3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 02:41:29 -0500
In-Reply-To: <1323901909.2631.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 December 2011, Eric Dumazet wrote:
> Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 11:00 -0800, Yuchung Cheng a=
 =C3=A9crit :
> > I use tcptrace to check the time sequence and I am puzzled:
> > I see a lot of OOO packets too but how can this happen at a sender-=
side
> > trace? unless the trace is taken close to but not exactly at the se=
nder.
> > I expect on seeing in-sequence packets but a lots of SACKs plus som=
e
> > spurious retransmists.
>=20
> I understood the trace was a receiver-side one (a linux machine if I =
am
> not mistaken, while the sender is AIX powered)
>=20
> (Looking at timings of ACKS, coming a few us after corresponding data
> packet arrival)

Oh. Right. This also means, that net.ipv4.tcp_reordering is only availa=
ble at=20
the receiver (Linux), which doesn't help, because the reordering robust=
ness=20
stuff happens on sender-side. So don't even bother changing that sysctl=
=2E

Carsten
