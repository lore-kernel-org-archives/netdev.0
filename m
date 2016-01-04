From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Mon, 04 Jan 2016 16:44:35 -0500 (EST)
Message-ID: <20160104.164435.2254202571374844451.davem@davemloft.net>
References: <20151228141435.GA13351@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, edumazet@google.com,
	hannes@stressinduktion.org, socketpair@gmail.com
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151228141435.GA13351@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 28 Dec 2015 15:14:35 +0100

> It is possible for a process to allocate and accumulate far more FDs than
> the process' limit by sending them over a unix socket then closing them
> to keep the process' fd count low.
> 
> This change addresses this problem by keeping track of the number of FDs
> in flight per user and preventing non-privileged processes from having
> more FDs in flight than their configured FD limit.
> 
> Reported-by: socketpair@gmail.com
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
> It would be nice if (if accepted) it would be backported to -stable as the
> issue is currently exploitable.

As mentioned, please remove the unix_sock_count variable and
associated code as it is completely unused after this patch.
