From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Mon, 4 Jul 2011 13:05:31 +0000
Message-ID: <20110704130531.37cf876e@Nokia-N900>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
	<BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	<CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	<1309707971.2523.20.camel@edumazet-laptop>
	<CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:42035 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831Ab1GDNCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 09:02:06 -0400
In-Reply-To: <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Jul 2011 15:48:31 +0400
Alexey Zaytsev <alexey.zaytsev@gmail.com> wrote:
> The skb is reinserted into the ring before its data is copied, it
> seems. But this can't be the cause of my problem, as it would lead to
> data corruption at most, not a write-after-free.

Recycling the skb does not imply that the device can reuse it immediately. The device is told at the very end of the RX function (after the loop) that it's now safe to put stuff into the recyceled/new buffers.

> And an other question. Why so we have the logic to work-around the 1Gb
> DMA limit instead of just setting the dma mask?

Because the DMA mask does not work correctly on all arches for masks smaller than 4G.

And btw, I dont understand what that wmb() patch is supposed to fix. There may be a wmb() missing, but rather after the ctrl _and_ the address assignment to the descriptor.
But I don't think this can cause this use-after-free anyway.

