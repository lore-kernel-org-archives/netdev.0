From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Fix incorrect prototype for ipxrtr_route_packet()
Date: Fri, 18 May 2007 09:48:32 +0800
Message-ID: <1179452912.2859.521.camel@shinybook.infradead.org>
References: <1179398893.2859.479.camel@shinybook.infradead.org>
	 <20070517152746.8bd3ea07.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, acme@ghostprotocols.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59989 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759656AbXERBsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 21:48:39 -0400
In-Reply-To: <20070517152746.8bd3ea07.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-17 at 15:27 -0700, Andrew Morton wrote:
> Lovely.  So it was actually generating wrong code on all
> sizeof(size_t)!=sizeof(int) architectures.

I was trying to work out which architectures would actually be affected.
Probably not many. If it's in a register it probably doesn't matter --
the size only matters if you put it on the stack. And it would have to
be a 64-bit architecture, none of which (iirc) are so register-starved
that this particular argument would be on the stack anyway.

So I'm not actually sure it will really generate wrong code on any
architecture we support -- not that this excuses it in any way :)

> If only we could find some way in which all callers of a function as
> well as its definition can see the same declaration? 

Well, building with --combine helps. :)

Admittedly it doesn't necessarily catch _all_ callers -- only those
which we actually compile together. That does cover _most_ of the times
we do crap like this without a prototype in a header file though, I
suspect.

As Geert points out, sparse can warn about non-static functions which
aren't prototyped; if we start getting anal about that, it might help.

-- 
dwmw2

