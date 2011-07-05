From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 22:15:40 +0200
Message-ID: <1309896940.2545.34.camel@edumazet-laptop>
References: <1309844009.2720.39.camel@edumazet-laptop>
	 <1309845573.2720.41.camel@edumazet-laptop>
	 <20110705160531.GC2959@hmsreliant.think-freely.org>
	 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
	 <1309890775.2545.17.camel@edumazet-laptop>
	 <1309891516.2545.23.camel@edumazet-laptop>
	 <20110705195353.GG2959@hmsreliant.think-freely.org>
	 <1309896147.2545.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44928 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab1GEUPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 16:15:46 -0400
Received: by wwe5 with SMTP id 5so6281657wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 13:15:45 -0700 (PDT)
In-Reply-To: <1309896147.2545.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 22:02 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 05 juillet 2011 =C3=A0 15:53 -0400, Neil Horman a =C3=A9crit=
 :
> > I think this is a goo idea, at least for testing.  It seems odd to =
me that we
> > have the B44_DMARX_PTR value which indicates (ostensibly) the point=
er to the
> > descriptor to be processed next (the documentation isnt' very verbo=
se on the
> > subject), along with the EOT bit on a descriptor.  It seems like bo=
th the
> > register and the bit are capable of conveying the same (or at least=
 overlapping)
> > information.
> >=20
> > I think what I'm having the most trouble with is understanding when=
 the hw looks
> > at the EOT bit in the descriptor.  If it completes a DMA and sees t=
he EOT bit
> > set, does the next DMA occur to the descriptor pointed to by the DM=
ARX_ADDR
> > register?  Of does it stall until such time as the DMARX_PTR regist=
er is rotated
> > around?  What if it doesn't see the EOT bit set?  Does it just keep=
 going with
> > the next descriptor? =20

Since there is no OWN bit (at least not on the online doc I got : it
says the rx_ring is read only by the NIC), I would say we really need t=
o
advance DMARX_PTR to signal NIC a new entry is available for following
incoming frames.

This is the reason rx_pending max value is B44_RX_RING_SIZE - 1, or els=
e
chip could loop on a circular rx_ring.




