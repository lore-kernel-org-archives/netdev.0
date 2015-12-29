From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Tue, 29 Dec 2015 21:35:27 +0100
Message-ID: <20151229203527.GA13826@1wt.eu>
References: <20151228141435.GA13351@1wt.eu> <56829D4D.4090109@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:21855 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821AbbL2UhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 15:37:24 -0500
Content-Disposition: inline
In-Reply-To: <56829D4D.4090109@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 03:48:45PM +0100, Hannes Frederic Sowa wrote:
> On 28.12.2015 15:14, Willy Tarreau wrote:
> >It is possible for a process to allocate and accumulate far more FDs than
> >the process' limit by sending them over a unix socket then closing them
> >to keep the process' fd count low.
> >
> >This change addresses this problem by keeping track of the number of FDs
> >in flight per user and preventing non-privileged processes from having
> >more FDs in flight than their configured FD limit.
> >
> >Reported-by: socketpair@gmail.com
> >Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> >Signed-off-by: Willy Tarreau <w@1wt.eu>
> 
> Thanks for the patch!
> 
> I think this does not close the DoS attack completely as we duplicate 
> fds if the reader uses MSG_PEEK on the unix domain socket and thus 
> clones the fd. Have I overlooked something?

I didn't know this behaviour. However, then the fd remains in flight, right ?
So as long as it's not removed from the queue, the sender cannot add more
than its FD limit. I may be missing something obvious though :-/

Thanks,
Willy
