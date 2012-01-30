From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: fix EPOLLET regression for stream sockets
Date: Mon, 30 Jan 2012 12:45:37 -0500 (EST)
Message-ID: <20120130.124537.2246327212488304490.davem@davemloft.net>
References: <CAKDKvuzH14AZjDG3WSdrf5VtmiUgG0Y+EaC83qqSd0VFKzyitg@mail.gmail.com>
	<1327686822.3159.3.camel@edumazet-laptop>
	<1327803063.2805.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nickm@freehaven.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, himeraster@gmail.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327803063.2805.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 29 Jan 2012 03:11:03 +0100

> Commit 0884d7aa24 (AF_UNIX: Fix poll blocking problem when reading from
> a stream socket) added a regression for epoll() in Edge Triggered mode
> (EPOLLET)
> 
> Appropriate fix is to use skb_peek()/skb_unlink() instead of
> skb_dequeue(), and only call skb_unlink() when skb is fully consumed.
> 
> This remove the need to requeue a partial skb into sk_receive_queue head
> and the extra sk->sk_data_ready() calls that added the regression.
> 
> This is safe because once skb is given to sk_receive_queue, it is not
> modified by a writer, and readers are serialized by u->readlock mutex.
> 
> This also reduce number of spinlock acquisition for small reads or
> MSG_PEEK users so should improve overall performance.
> 
> Reported-by: Nick Mathewson <nickm@freehaven.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Alexey Moiseytsev <himeraster@gmail.com>

Applied and queued up for -stable, thanks.
