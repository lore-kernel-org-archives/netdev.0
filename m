From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: dctcp: loosen requirement to assert ECT(0)
 during 3WHS
Date: Mon, 02 Feb 2015 18:49:31 -0800 (PST)
Message-ID: <20150202.184931.1024091126990318037.davem@davemloft.net>
References: <1422647120-27252-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	glenn.judd@morganstanley.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755516AbbBCCtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:49:32 -0500
In-Reply-To: <1422647120-27252-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 30 Jan 2015 20:45:20 +0100

> One deployment requirement of DCTCP is to be able to run
> in a DC setting along with TCP traffic. As Glenn Judd's
> NSDI'15 paper "Attaining the Promise and Avoiding the Pitfalls
> of TCP in the Datacenter" [1] (tba) explains, one way to
> solve this on switch side is to split DCTCP and TCP traffic
> in two queues per switch port based on the DSCP: one queue
> soley intended for DCTCP traffic and one for non-DCTCP traffic.
> 
> For the DCTCP queue, there's the marking threshold K as
> explained in commit e3118e8359bb ("net: tcp: add DCTCP congestion
> control algorithm") for RED marking ECT(0) packets with CE.
> For the non-DCTCP queue, there's f.e. a classic tail drop queue.
> As already explained in e3118e8359bb, running DCTCP at scale
> when not marking SYN/SYN-ACK packets with ECT(0) has severe
> consequences as for non-ECT(0) packets, traversing the RED
> marking DCTCP queue will result in a severe reduction of
> connection probability.
> 
> This is due to the DCTCP queue being dominated by ECT(0) traffic
> and switches handle non-ECT traffic in the RED marking queue
> after passing K as drops, where K is usually a low watermark
> in order to leave enough tailroom for bursts. Splitting DCTCP
> traffic among several queues (ECN and non-ECN queue) is being
> considered a terrible idea in the network community as it
> splits single flows across multiple network paths.
> 
> Therefore, commit e3118e8359bb implements this on Linux as
> ECT(0) marked traffic, as we argue that marking all packets
> of a DCTCP flow is the only viable solution and also doesn't
> speak against the draft.
> 
> However, recently, a DCTCP implementation for FreeBSD hit also
> their mainline kernel [2]. In order to let them play well
> together with Linux' DCTCP, we would need to loosen the
> requirement that ECT(0) has to be asserted during the 3WHS as
> not implemented in FreeBSD. This simplifies the ECN test and
> lets DCTCP work together with FreeBSD.
> 
> Joint work with Daniel Borkmann.
> 
>   [1] https://www.usenix.org/conference/nsdi15/technical-sessions/presentation/judd
>   [2] https://github.com/freebsd/freebsd/commit/8ad879445281027858a7fa706d13e458095b595f
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
