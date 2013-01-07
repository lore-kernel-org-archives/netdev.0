From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix MSG_SENDPAGE_NOTLAST logic
Date: Sun, 06 Jan 2013 20:59:39 -0800 (PST)
Message-ID: <20130106.205939.1265185319066155577.davem@davemloft.net>
References: <1357501171.6919.650.camel@edumazet-glaptop>
	<20130106195359.GN16031@1wt.eu>
	<1357532509.6919.1715.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357532509.6919.1715.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 06 Jan 2013 20:21:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 35f9c09fe9c72e (tcp: tcp_sendpages() should call tcp_push() once)
> added an internal flag : MSG_SENDPAGE_NOTLAST meant to be set on all
> frags but the last one for a splice() call.
> 
> The condition used to set the flag in pipe_to_sendpage() relied on
> splice() user passing the exact number of bytes present in the pipe,
> or a smaller one.
> 
> But some programs pass an arbitrary high value, and the test fails.
> 
> The effect of this bug is a lack of tcp_push() at the end of a
> splice(pipe -> socket) call, and possibly very slow or erratic TCP
> sessions.
> 
> We should both test sd->total_len and fact that another fragment
> is in the pipe (pipe->nrbufs > 1)
> 
> Many thanks to Willy for providing very clear bug report, bisection
> and test programs.
> 
> Reported-by: Willy Tarreau <w@1wt.eu>
> Bisected-by: Willy Tarreau <w@1wt.eu>
> Tested-by: Willy Tarreau <w@1wt.eu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks everyone.
