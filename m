From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 14 Aug 2009 12:38:32 -0400
Message-ID: <20090814123832.a7a27a9d.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CCEFC.7020308@myri.com>
	<20090807213557.d0faec23.billfink@mindspring.com>
	<4A7D5CA4.3030307@myri.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
	<20090811033210.6b422ed1.billfink@mindspring.com>
	<87ws5af0km.fsf@basil.nowhere.org>
	<20090812003049.185cd52a.billfink@mindspring.com>
	<4A856781.2080301@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:38746 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932386AbZHNQid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 12:38:33 -0400
In-Reply-To: <4A856781.2080301@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Drew,

On Fri, 14 Aug 2009, Andrew Gallatin wrote:

> Hi Bill,
> 
> A few questions.   I was looking at the manual for the
> X8DAH+-F, and it claims to support both I/OAT and DCA.
> Do you have either or both enabled?

I did not explicitly set either one, and the manual indicates they
are both enabled by default, which I also vaguely seem to recall
was the way they were set.  I'm not in at the office today so I
can't physically check.

> If yes, then
> what happens if you disable ioatdma (by setting
> net.ipv4.tcp_dma_copybreak=2147483647 with sysctl)?
> How about if you disable myri10ge's use of dca (load driver
> with myri10ge_dca=0).
> 
> Do you see any changes?

Good suggestions but unfortunately it didn't help (or hurt).
It may have helped a little bit on the transmit side (I saw one
test at 102 Gbps when the previous high I had seen was 101 Gbps),
but the receive side was still at 55 Mbps.

Would there be any difference between disabling I/OAT and DCA in
the BIOS versus the myri10ge module parameter and sysctl setting?
I can try any BIOS changes on Monday.

> I'm worried about ioatdma because I've seen problems with it
> before.  At least on Linux, it tends to busywait for the DMA
> to complete, which is actually slower than a memory copy in
> most cases that I've seen.
> 
> I'm worried about DCA because you've shown that the BIOS is buggy,
> so the tag table could be wrong (resulting in bad prefetching hints).

The new BIOS seems to be better at setting the NUMA node info.

> I'm also worried about DCA because I've never had the chance to
> use it on a 5520 based system, and there is always the chance
> that we may be doing something wrong ourselves in the NIC firmware
> (again resulting in bad prefetching hints).  Bad prefetching hints
> can cause cross-CPU chatter, and kill performance by wasting
> memory bandwidth, and dirtying a cache on another CPU
> for no reason.

Is there any easy way to monitor active memory bandwidth usage?

> Drew

						-Thanks

						-Bill

P.S.  I don't know if it's at all significant, but one time after
      a reboot that required an fsck because of exceeding the number
      of mounts without an fsck, thus incurring a significant delay
      in the boot process, the transmit performance dropped from
      its normal ~100 Gbps to 57 Gbps (similar to the receive side
      performance).  Another reboot restored the normal ~100 Gbps
      transmit side performance.  I have no idea why this might be,
      but I saw it once before when an fsck was required on boot,
      so it may not be a fluke.
