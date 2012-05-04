From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Fri, 4 May 2012 13:03:11 +0300
Message-ID: <20120504100310.GB31083@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:65169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256Ab2EDKDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:03:08 -0400
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

This is more intrusive than I'd like because on
error we need to free the skb, so need
to return error code from orphan, but it does not add
an extra branch since skb_orphan is inline.
So intrusive but should not hurt fast path.

It's weekend here, I'll work on a patch like this
Sunday.

-- 
MST
