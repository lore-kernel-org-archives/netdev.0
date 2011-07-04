From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Mon, 04 Jul 2011 17:12:03 +0200
Message-ID: <1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	 <1309707971.2523.20.camel@edumazet-laptop>
	 <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	 <20110704130531.37cf876e@Nokia-N900>
	 <1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110704162726.4072e715@maggie>  <20110704164351.338dc12e@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42846 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab1GDPMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 11:12:18 -0400
Received: by wyg8 with SMTP id 8so3462948wyg.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 08:12:16 -0700 (PDT)
In-Reply-To: <20110704164351.338dc12e@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 juillet 2011 =C3=A0 16:43 +0200, Michael B=C3=BCsch a =C3=A9=
crit :
> On Mon, 4 Jul 2011 16:27:26 +0200
> Michael B=C3=BCsch <m@bues.ch> wrote:
> > We do this in b43, which has exactly the same DMA engine.
>=20
> (Ok, it turns out we don't do this in b43 (We only do it on the TX si=
de).
>  But that's a bug. We should do a wmb() on the RX side before advanci=
ng the
>  descriptor ring pointer.)

I am wondering what happens if RX ring is set to 64, and we receive
exactly 64 buffers in one round, B44_DMARX_PTR wont change at all ?

Alexey, could you try this patch please ?

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index a69331e..51072a3 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -829,6 +829,7 @@ static int b44_rx(struct b44 *bp, int budget)
 	}
=20
 	bp->rx_cons =3D cons;
+	wmb();
 	bw32(bp, B44_DMARX_PTR, cons * sizeof(struct dma_desc));
=20
 	return received;


