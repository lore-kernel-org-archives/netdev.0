From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/14]: netlink: memory mapped I/O
Date: Thu, 18 Apr 2013 12:27:39 +0200
Message-ID: <20130418102738.GA25166@macbook.localnet>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
 <20130417194046.GF1408@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35369 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030393Ab3DRK1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 06:27:45 -0400
Content-Disposition: inline
In-Reply-To: <20130417194046.GF1408@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 09:40:46PM +0200, Florian Westphal wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> > The following patches contain an implementation of memory mapped I/O for
> > netlink. The implementation is modelled after AF_PACKET memory mapped I/O
> > with a few differences:
> 
> [..]
> 
> > Following are some numbers collected by Florian Westphal based on a
> > slightly older version, which included an experimental patch for the
> > nfnetlink_queue ordering issue.
> 
> I'd like to see a comparision with Eric Dumazets nfnetlink_queue zerocopy
> patch [ ae08ce0021087a5d812d2714fb2a326ef9f8c450, netfilter:
> nfnetlink_queue: zero copy support ].
> 
> The nice thing about that patch is its transparency to userspace, and
> the avoidance of the 'nfnetlink_queue packet reordering' issue.
> 
> Sorry :)

No need to be sorry :) The use cases only partially overlap, the zero copy
(actually single copy, just like mmaped netlink) requires drivers to generate
fragmented skbs, while the mmaped netlink code works in all cases. It also
supports TX and, in case of nfnetlink_queue, modification of the packets.
And it works for all netlink subsystems and is not specific to nfnetlink_queue.

So I think while the nfnetlink_queue zero copy patches are a great idea,
there are still enough unhandled use cases for memory mapped netlink.
 
> Another issue with mmap is the need to preallocate the ring frame size.
> After the gso avoidance change [ no skb_gso_segment calls anymore ],
> we will need to be able to queue GSO/GRO skbs, which makes it necessary to
> cope with 64k payload in the mmap case...

Hmm that might actually also be a problem in the zcopy case for userspace since
the netlink recv buffer sizes are in many cases not that large.
