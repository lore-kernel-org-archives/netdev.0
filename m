From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Thu, 28 May 2009 23:12:58 +0200
Message-ID: <20090528211258.GA3658@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com> <20090521085116.GC2892@ami.dom.local> <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com> <20090523073201.GA2766@ami.dom.local> <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:50074 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbZE1VOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 17:14:14 -0400
Received: by bwz22 with SMTP id 22so5740011bwz.37
        for <netdev@vger.kernel.org>; Thu, 28 May 2009 14:14:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2009 at 07:13:40PM +0100, Antonio Almeida wrote:
> On Sat, May 23, 2009 at 8:32 AM, Jarek Poplawski wrote:
> > Actually, from these two I was more interested in iproute2 more
> > fitting the kernel version. :-((It should be enough to have at least
> > tc compiled properly, I guess.)
> I installed iproute2-ss090115 with the new patch but the results are
> the same for my test scenery. HTB keeps sending 620Mbit/s when I
> configure it's ceil to 555Mbit/s, with 800 bytes packets long.
> 
> > Btw.: if at any point you think this testing is too disturbing to you
> > etc., feel free to stop this or delay in time as you like.
> I'm working on this, don't worry. Since I have a traffic
> generator/analyser, any modification you would make I can test it.
> You're free to ask.
> 
> I've been looking inside htb source code. The granularity problem
> could be in the use qdisc_rate_table or near that.

Yes, but according to my assessment there should be "only" 50Mbit
difference for this rate/packet size. Anyway, could you try a testing
patch below, which should add some granularity to this rate table?

Thanks,
Jarek P.
---

 include/net/pkt_sched.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index e37fe31..f0faf03 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -42,8 +42,8 @@ typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
 /* Avoid doing 64 bit divide by 1000 */
-#define PSCHED_US2NS(x)			((s64)(x) << 10)
-#define PSCHED_NS2US(x)			((x) >> 10)
+#define PSCHED_US2NS(x)			((s64)(x) << 6)
+#define PSCHED_NS2US(x)			((x) >> 6)
 
 #define PSCHED_TICKS_PER_SEC		PSCHED_NS2US(NSEC_PER_SEC)
 #define PSCHED_PASTPERFECT		0
