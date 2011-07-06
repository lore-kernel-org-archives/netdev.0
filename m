From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Wed, 06 Jul 2011 18:35:24 +0200
Message-ID: <1309970124.2292.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
	 <1309890775.2545.17.camel@edumazet-laptop>
	 <1309891516.2545.23.camel@edumazet-laptop>
	 <20110705195353.GG2959@hmsreliant.think-freely.org>
	 <1309896147.2545.28.camel@edumazet-laptop>
	 <1309896940.2545.34.camel@edumazet-laptop>
	 <20110705220644.GB12118@hmsreliant.think-freely.org>
	 <20110706173243.404d8599@maggie>
	 <1309968019.2292.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110706181258.57b3c112@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59451 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab1GFQfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 12:35:38 -0400
Received: by wyg8 with SMTP id 8so76500wyg.19
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 09:35:37 -0700 (PDT)
In-Reply-To: <20110706181258.57b3c112@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 juillet 2011 =C3=A0 18:12 +0200, Michael B=C3=BCsch a =C3=
=A9crit :
> On Wed, 06 Jul 2011 18:00:19 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Not exactly :
> >=20
> > If we read one skb at descriptor 0, we prepare a new buffer on slot=
 200,
> > and advance DMARX_PTR to 201*sizeof(descriptor).
>=20
> I don't think so. Why do you think this is the case?
> We allocate a new descriptor buffer for the consumed buffer at exactl=
y
> the same place (which is "cons").
> (Alternatively, we leave the buffer in place, and just copy the data =
to a new buffer).
> And DMARX_PTR is updated to the last "cons", which is one beyond
> the last buffer that we consumed (and pushed up the net stack).

Not at all.

If it was true, b44_recycle_rx() would not even exist as is.

When we allocate a new buffer, we put it at rx_prod index, which is the
slot _after_ window, not the first slot.

=46irst time we dequeue a packet from NIC, rx_prod is something like 20=
0


Oh, it seems we do the following in b44_init_hw()

bp->rx_prod =3D bp->rx_pending;

But this seems completely wrong, if b44_init_rings() was not able to
allocate rx_pending buffers (b44_alloc_rx_skb() can return NULL)



