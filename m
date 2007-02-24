From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 18/29] netfilter: notify about NF_QUEUE
	vs	emergency	skbs
Date: Sat, 24 Feb 2007 17:55:49 +0100
Message-ID: <1172336149.28579.11.camel@lappy>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144843.299254000@taijtu.programming.kicks-ass.net>
	 <45E05954.8050204@trash.net> <1172332010.28579.6.camel@lappy>
	 <45E064FF.8010000@trash.net> <1172333937.6374.47.camel@twins>
	 <45E06A86.2060408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep19-int.chello.nl ([62.179.120.14]:64787 "EHLO
	amsfep19-int.chello.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933519AbXBXQz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 11:55:59 -0500
In-Reply-To: <45E06A86.2060408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-02-24 at 17:40 +0100, Patrick McHardy wrote:
> Peter Zijlstra wrote:
> > On Sat, 2007-02-24 at 17:17 +0100, Patrick McHardy wrote:
> > 
> > 
> >>I don't really see why
> >>queueing is special though, dropping the packets in the ruleset
> >>will break things just as well, as will routing them to a blackhole.
> >>I guess the user just needs to be smart enough not to do this.
> > 
> > 
> > Its user-space and no emergency packet may rely on user-space because it
> > most likely is needed to maintain user-space.
> 
> I believe I might have misunderstood the intention of this patch.
> 
> Assuming the user is smart enough not to queue packets destined
> to a SOCK_VMIO socket, are you worried about unrelated packets
> allocated from the emergency reserve not getting freed fast
> enough because they're sitting in a queue? In that case simply
> dropping the packets would be fine I guess.

OK, that sounds good. I shall make NF_QUEUE a black hole for emergency
packets.

Alas, that leaves no way to warn a user about a SOCK_VMIO bound packet
treated this way, since, as you said, that is unknown at this point in
the chain.

Thanks,
Peter

