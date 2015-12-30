From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net, socket, socket_wq: fix missing initialization
 of flags
Date: Wed, 30 Dec 2015 16:39:15 -0500 (EST)
Message-ID: <20151230.163915.990334768673899184.davem@davemloft.net>
References: <87ege73bma.fsf@gmail.com>
	<1451323186.8255.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<87ziwtphdo.fsf_-_@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nicstange@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbL3VjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 16:39:17 -0500
In-Reply-To: <87ziwtphdo.fsf_-_@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolai Stange <nicstange@gmail.com>
Date: Tue, 29 Dec 2015 13:29:55 +0100

> Fixes: ceb5d58b2170 ("net: fix sock_wake_async() rcu protection")
> 
> Commit ceb5d58b2170 ("net: fix sock_wake_async() rcu protection") from
> the current 4.4 release cycle introduced a new flags member in
> struct socket_wq and moved SOCKWQ_ASYNC_NOSPACE and SOCKWQ_ASYNC_WAITDATA
> from struct socket's flags member into that new place.
> 
> Unfortunately, the new flags field is never initialized properly, at least
> not for the struct socket_wq instance created in sock_alloc_inode().
> 
> One particular issue I encountered because of this is that my GNU Emacs
> failed to draw anything on my desktop -- i.e. what I got is a transparent
> window, including the title bar. Bisection lead to the commit mentioned
> above and further investigation by means of strace told me that Emacs
> is indeed speaking to my Xorg through an O_ASYNC AF_UNIX socket. This is
> reproducible 100% of times and the fact that properly initializing the
> struct socket_wq ->flags fixes the issue leads me to the conclusion that
> somehow SOCKWQ_ASYNC_WAITDATA got set in the uninitialized ->flags,
> preventing my Emacs from receiving any SIGIO's due to data becoming
> available and it got stuck.
> 
> Make sock_alloc_inode() set the newly created struct socket_wq's ->flags
> member to zero.
> 
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>

Applied, but please in the future please put the Fixes: tag right
above the first signoff/ack, like this:

Fixes: ceb5d58b2170 ("net: fix sock_wake_async() rcu protection")
Signed-off-by: Nicolai Stange <nicstange@gmail.com>
