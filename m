From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 22:02:27 +0200
Message-ID: <1309896147.2545.28.camel@edumazet-laptop>
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
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53391 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab1GEUCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 16:02:32 -0400
Received: by wwe5 with SMTP id 5so6272674wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 13:02:31 -0700 (PDT)
In-Reply-To: <20110705195353.GG2959@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 15:53 -0400, Neil Horman a =C3=A9crit :
> I think this is a goo idea, at least for testing.  It seems odd to me=
 that we
> have the B44_DMARX_PTR value which indicates (ostensibly) the pointer=
 to the
> descriptor to be processed next (the documentation isnt' very verbose=
 on the
> subject), along with the EOT bit on a descriptor.  It seems like both=
 the
> register and the bit are capable of conveying the same (or at least o=
verlapping)
> information.
>=20
> I think what I'm having the most trouble with is understanding when t=
he hw looks
> at the EOT bit in the descriptor.  If it completes a DMA and sees the=
 EOT bit
> set, does the next DMA occur to the descriptor pointed to by the DMAR=
X_ADDR
> register?  Of does it stall until such time as the DMARX_PTR register=
 is rotated
> around?  What if it doesn't see the EOT bit set?  Does it just keep g=
oing with
> the next descriptor? =20
>=20
> Also, there seems to be some inconsistency in the settnig of the B44_=
DMARX_PTR
> register.  In bnx2_init_hw its set to the value of bp->rx_pending, wh=
ich is
> defined as being 200.  But in b44_rx its advanced by sizeof(struct dm=
a_desc) for
> every iteration.  So in b44_init_hw we write the value 200 to it, ost=
ensibly
> indicating a limit of 200 descriptors, but in b44_rx we iteratively w=
rite the
> values 0, 8, 16, 24...4*n to the register to indicate which descripto=
r we're
> indexing?  Something really doesn't sit right with me there.  In the =
former case
> we treat the register as holding  number of entries, and in the latte=
r we treat
> it as holding a byte offset into an array.  Or am I missing something=
?
>=20

Yes, definitely this needs some clarification.

More over, when we hit the last entry (currently at slot 511), the EOT
instructs hardware to go back to slot 0, while our real window is
511-200 -> 511 . Slot 0 contains garbage (well, an old value)

Its late here so I dont plan to send a patch before 8/10 hours.



