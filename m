From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix oops in L2TP IP sockets for connect()
 AF_UNSPEC case
Date: Tue, 29 May 2012 17:20:08 -0400 (EDT)
Message-ID: <20120529.172008.875375243438479060.davem@davemloft.net>
References: <1338298242-22261-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, levinsasha928@gmail.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab2E2VUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 17:20:15 -0400
In-Reply-To: <1338298242-22261-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 29 May 2012 14:30:42 +0100

> An application may call connect() to disconnect a socket using an
> address with family AF_UNSPEC. The L2TP IP sockets were not handling
> this case when the socket is not bound and an attempt to connect()
> using AF_UNSPEC in such cases would result in an oops. This patch
> addresses the problem by protecting the sk_prot->disconnect() call
> against trying to unhash the socket before it is bound.
> 
> The L2TP IPv4 and IPv6 sockets have the same problem. Both are fixed
> by this patch.
> 
> The patch also adds more checks that the sockaddr supplied to bind()
> and connect() calls is valid.
> 
>  RIP: 0010:[<ffffffff82e133b0>]  [<ffffffff82e133b0>] inet_unhash+0x50/0xd0
>  RSP: 0018:ffff88001989be28  EFLAGS: 00010293
>  Stack:
>   ffff8800407a8000 0000000000000000 ffff88001989be78 ffffffff82e3a249
>   ffffffff82e3a050 ffff88001989bec8 ffff88001989be88 ffff8800407a8000
>   0000000000000010 ffff88001989bec8 ffff88001989bea8 ffffffff82e42639
>  Call Trace:
>  [<ffffffff82e3a249>] udp_disconnect+0x1f9/0x290
>  [<ffffffff82e42639>] inet_dgram_connect+0x29/0x80
>  [<ffffffff82d012fc>] sys_connect+0x9c/0x100
> 
> Reported-by: Sasha Levin <levinsasha928@gmail.com>
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied and queued up for -stable, thanks James.
