From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 23:57:59 +0200
Message-ID: <20120517215759.GR14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu> <1337290822.3403.47.camel@edumazet-glaptop> <1337291410.3403.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2350 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965954Ab2EQV6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 17:58:02 -0400
Content-Disposition: inline
In-Reply-To: <1337291410.3403.52.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 11:50:10PM +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 23:40 +0200, Eric Dumazet wrote:
> 
> > I dont understand why we should tcp_push() if we sent 0 bytes in this
> > splice() call.
> > 
> > The push() should have be done already by prior splice() call, dont you
> > think ?
> > 
> > out:
> > 	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
> > 		tcp_push(sk, flags, mss_now, tp->nonagle);
> > 
> 
> I think I now understand
> 
> One splice() syscall actually calls do_tcp_sendpages() several times
> (N).
> 
> Problem is N-1 calls are done with MSG_SENDPAGE_NOTLAST set
> 
> And last one with MSG_SENDPAGE_NOTLAST unset
> 
> So maybe we should replace this test by :
> 
> 	if (!(flags & MSG_SENDPAGE_NOTLAST))
> 		tcp_push(...);

Just tested, and it unfortunately does not fix the issue :-(

I'll see if I can log errors from lower layers.
Willy
