From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 00/14]: netlink: memory mapped I/O
Date: Thu, 18 Apr 2013 13:01:05 +0200
Message-ID: <20130418110105.GH1408@breakpoint.cc>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
 <20130417194046.GF1408@breakpoint.cc>
 <20130418102738.GA25166@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51357 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965199Ab3DRLBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 07:01:08 -0400
Content-Disposition: inline
In-Reply-To: <20130418102738.GA25166@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:
> So I think while the nfnetlink_queue zero copy patches are a great idea,
> there are still enough unhandled use cases for memory mapped netlink.
>
> > Another issue with mmap is the need to preallocate the ring frame size.
> > After the gso avoidance change [ no skb_gso_segment calls anymore ],
> > we will need to be able to queue GSO/GRO skbs, which makes it necessary to
> > cope with 64k payload in the mmap case...
> 
> Hmm that might actually also be a problem in the zcopy case for userspace since
> the netlink recv buffer sizes are in many cases not that large.

I am not sure I am following here.  Can you elaborate?
Maybe I was a bit too vague, so let me try to clarify.

The GSO segmentation avoidance patch requires userspace support, including large
recv buffer size (i.e., 64k + a few byte netlink overhead).

It will be off by default, userspace needs to enable it when it binds
the nfqueue.

What I was pointing out is that for mmap'd netlink you usually need
to allocate enough slots so the ring can handle e.g. 1024 packets.

For the 64k packet case, that would be >64 MB mmap-ring.

I'm not saying its a problem, just wanted to point it out.

[ 64k is probably rare enough to have mmap-users fallback to recv,
  and your patches already support this ].

Cheers,
Florian
