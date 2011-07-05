From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 5 Jul 2011 18:27:03 +0200
Message-ID: <20110705182703.0bb9eb33@maggie>
References: <1309839258.2720.17.camel@edumazet-laptop>
	<CAB9v_DGSFAG9V0jqem+tDP3G-N8v6Z+_6oKdPwL-ZwhfhCOZnw@mail.gmail.com>
	<1309839928.2720.23.camel@edumazet-laptop>
	<CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
	<1309840708.2720.31.camel@edumazet-laptop>
	<CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
	<1309842642.2720.36.camel@edumazet-laptop>
	<CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
	<1309844009.2720.39.camel@edumazet-laptop>
	<1309845573.2720.41.camel@edumazet-laptop>
	<20110705160531.GC2959@hmsreliant.think-freely.org>
	<1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:49508 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754542Ab1GEQ12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 12:27:28 -0400
In-Reply-To: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Jul 2011 18:12:32 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hmm... We are in a NAPI handler... There wont be a new interrupt.
> 
> Plus, we do at start of b44_rx() :
> 
> prod  = br32(bp, B44_DMARX_STAT) & DMARX_STAT_CDMASK;
> 
> So all descriptors before prod are guaranteed to be ready for host
> consume... Fact that a dma access is running on 'next descriptor' should
> be irrelevant.
> 
> IMHO Peeking B44_DMARX_STAT for each packet would be a waste of time.

Yeah I think so, too. We don't need to wait for the _whole_ DMA engine
to go idle, before we can access a buffer in the ring. We just need to make sure
that the device is finished with that buffer. And we do this by reading the current
descriptor pointer.
