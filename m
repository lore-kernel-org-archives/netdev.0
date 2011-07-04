From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Mon, 4 Jul 2011 16:27:26 +0200
Message-ID: <20110704162726.4072e715@maggie>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
	<BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	<CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	<1309707971.2523.20.camel@edumazet-laptop>
	<CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	<20110704130531.37cf876e@Nokia-N900>
	<1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:58342 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459Ab1GDO1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 10:27:43 -0400
In-Reply-To: <1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Jul 2011 15:57:02 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I dont have the b44 specs, but :

It uses the 30-bit version of the Broadcom HND engine, for which complete
specs are available here:
http://bcm-v4.sipsolutions.net/802.11/DMA

> For sure, addr should be set before ctl, just in case ctl allows chip to
> start a dma transfert (to previous packet), because a OWN bit is unset
> for example...

Certainly not.
The device does not know about the buffer until this line:
 bw32(bp, B44_DMARX_PTR, cons * sizeof(struct dma_desc));
which advances the DMA descriptor pointer.
However, I do think we probably need a wmb() right before that bw32() line, to make sure
memory is committed before we tell the device it's OK to access it.
We do this in b43, which has exactly the same DMA engine.
