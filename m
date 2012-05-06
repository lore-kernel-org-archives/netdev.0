From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Sun, 6 May 2012 20:01:56 +0300
Message-ID: <20120506170156.GA30827@redhat.com>
References: <20120503154142.GB27671@redhat.com>
 <20120503.135532.1038384417514973419.davem@davemloft.net>
 <20120503210826.GA30504@redhat.com>
 <20120504.025433.1474691040952890731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab2EFSUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2012 14:20:50 -0400
Content-Disposition: inline
In-Reply-To: <20120504.025433.1474691040952890731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 04, 2012 at 02:54:33AM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Fri, 4 May 2012 00:10:24 +0300
> 
> > Hmm we orphan skbs when we loop them back so how about reusing the
> > skb->destructor for this?
> 
> That's one possibility.
> 
> But I fear we're about to toss Ian into yet another rabbit hole. :-)
> 
> Let's try to converge on something quickly as I think integration of
> his work has been delayed enough as-is.

OK I tried doing this and I recalled why we
do the copy with ubufs before clone:
the problem is that shinfo is shared between skbs,
so modifying frags like skb_orphan_frags does is racy.
Stuck for now.

So I have a question: how about reusing the TX_DEV_ZEROCOPY
machinery for this, instead of frag destructors?

Thanks,

-- 
MST
