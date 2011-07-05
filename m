From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 20:45:16 +0200
Message-ID: <1309891516.2545.23.camel@edumazet-laptop>
References: <1309840708.2720.31.camel@edumazet-laptop>
	 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
	 <1309842642.2720.36.camel@edumazet-laptop>
	 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
	 <1309844009.2720.39.camel@edumazet-laptop>
	 <1309845573.2720.41.camel@edumazet-laptop>
	 <20110705160531.GC2959@hmsreliant.think-freely.org>
	 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
	 <1309890775.2545.17.camel@edumazet-laptop>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42511 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435Ab1GESpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:45:21 -0400
Received: by wyg8 with SMTP id 8so4194373wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 11:45:20 -0700 (PDT)
In-Reply-To: <1309890775.2545.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 20:32 +0200, Eric Dumazet a =C3=A9crit =
:

> Then, maybe the driver model is completely wrong, and should really
> setup 512 buffers, or use less descs but set EOT on last one.
>=20
> Currently it uses a 200 sliding window out of the 512 descs.
>=20
>=20

One thing we could do would be to allocate a special guard buffer and
set all 'out of window' descriptors to point to this guard buffer, and
periodically check if buffer is dirtied by the card.

(first word would be enough)

(instead of setting desc->addr to NULL, set to
dma_map_single(guard_buffer))



