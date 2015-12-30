From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Wed, 30 Dec 2015 12:23:17 +0100
Message-ID: <20151230112317.GC14049@1wt.eu>
References: <20151228141435.GA13351@1wt.eu> <56829D4D.4090109@stressinduktion.org> <20151229203527.GA13826@1wt.eu> <56839CC2.9080000@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56839CC2.9080000@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 09:58:42AM +0100, Hannes Frederic Sowa wrote:
> The MSG_PEEK code should not be harmful and the patch is good as is. I 
> first understood from the published private thread, that it is possible 
> for a program to exceed the rlimit of fds. But the DoS is only by 
> keeping the fds in flight and not attaching them to any program.

Exactly. The real issue is when these FDs become very expensive such as
pipes full of data.

> __alloc_fd, called on the receiver side, does check for the rlimit 
> maximum anyway, so I don't see a loophole anymore:
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!

> Another idea would be to add the amount of memory used to manage the fds 
> to sock_rmem/wmem but I don't see any advantages or disadvantages.

Compared to the impact of the pending data in pipes themselves in flight,
this would remain fairly minimal.

Thanks,
Willy
