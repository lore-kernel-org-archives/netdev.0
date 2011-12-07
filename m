From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bloat] Time in Queue, bufferbloat, and... our accidentally
 interplanetary network
Date: Wed, 07 Dec 2011 12:53:19 +0100
Message-ID: <1323258799.2312.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	 <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <9dfc3c5eb811f2774b378fce0158b3e7@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	bloat-devel <bloat-devel@lists.bufferbloat.net>,
	bloat <bloat@lists.bufferbloat.net>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:63392 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754513Ab1LGLxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 06:53:24 -0500
In-Reply-To: <9dfc3c5eb811f2774b378fce0158b3e7@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 d=C3=A9cembre 2011 =C3=A0 11:15 +0100, Hagen Paul Pfeife=
r a =C3=A9crit :
> On Mon, 05 Dec 2011 11:59:34 +0100, Eric Dumazet wrote:
>=20
>=20
> > Adding a time limit is possible, all we need is a proper design and
> > implementation :)
> >=20
> > Here is my suggestion :
> >=20
> > Design a new tfifo/tred qdisc, with following properties :
> >=20
> > Adaptative RED, (ECN enabled + head drop), but instead of using
> > bytes/packet qlen average, use time_in_queue average.
>=20
> Question one: is anything wrong with sfb or choke as the basis, inste=
ad of
> RED?
>=20

RED is the module to bring EWMA stuff, it seems natural to start with
it. Please note that choke has a RED module too.

Then later, we can add time limit stuff to other Qdisc if needed, its a
plug anyway. But is there any meaning to compute a global EWMA after
SFB/SFQ packet classification ?

> Question two: I submitted pfast_head_drop to drop more outdated data
> instead of new data. Back in time I thought TCP _may_ experience bene=
fits
> because more up-to-date SACK data packets are saved. Are there any ot=
her
> TCP advantages with head drop policy?
>=20

Note that head drop is a consequence of time limit idea on top of FIFO,
since only at dequeue time, we compute the delta between current time
and enqueue time, and we drop/mark the (head) packet if time exceeds ou=
r
current limit.

In general, being able to drop/mark firsts packets in queue instead of
last ones can let TCP sender be notified of congestion much earlier tha=
n
a tail drop. (We gain the time to transmit whole packets in queue befor=
e
receiver can report in its ACK the congestion back to sender)
