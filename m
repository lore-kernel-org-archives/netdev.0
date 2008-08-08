From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 20:31:24 +0200
Message-ID: <19f34abd0808081131p4e83cd79r8b7e0cb8da4f747b@mail.gmail.com>
References: <200807171653.59177.wolfgang.walter@stwm.de>
	 <200807301411.01622.wolfgang.walter@stwm.de>
	 <20080806103354.GA31623@gondor.apana.org.au>
	 <200808061933.25631.wolfgang.walter@stwm.de>
	 <20080806201401.GA607@linux-os.sc.intel.com>
	 <20080806212152.GB607@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: wolfgang.walter@stwm.de,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Suresh Siddha" <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:39701 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbYHHSbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 14:31:25 -0400
Received: by py-out-1112.google.com with SMTP id p76so630925pyb.10
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 11:31:25 -0700 (PDT)
In-Reply-To: <20080806212152.GB607@linux-os.sc.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2008 at 11:21 PM, Suresh Siddha
<suresh.b.siddha@intel.com> wrote:
> BTW, in one of your oops, I see:
>
> note: cron[1207] exited with preempt_count 268435459
>
> I smell some kind of stack corruption here which is corrupting
> thread_info (in the above case preempt_count in the thread_info).
>
> Similarly, if the status field(in thread_info) gets corrupted(setting
> TS_USEDFPU) without proper math state allocated(present in thread_struct),
> we can end up oops in __switch_to.
>
> But you seem to say, reverting recent fpu patches make the problem go away.
> hmm, just wondering if your test kernel (with fpu patches reverted) is stable
> enough and don't see other oops/issues?
>
> Recently Vegard also noticed some stack corruptions (in network stack) leading
> to similar problems. Not sure if Vegard has root caused his issue. copying him
> for his comments.

I don't think this is the same problem. What I see is almost certainly
a problem with netpoll, netconsole, or the 8139too driver. I see a UDP
packet in a task_struct.

There is also the fact that reverting fpu patches makes it go away
(for Wolfgang), while for the issue I am seeing, oops in FP code is
just one out of several different corruptions (sometimes it happens in
other slabs).

(Sorry for the little late reply.)

Thanks.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
