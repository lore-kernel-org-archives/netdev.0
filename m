From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: initialize tp->copied_seq in case of cross
 SYN connection
Date: Mon, 30 Nov 2015 15:35:29 -0500 (EST)
Message-ID: <20151130.153529.521824880876255065.davem@davemloft.net>
References: <1448554694.24696.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbbK3Ufb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 15:35:31 -0500
In-Reply-To: <1448554694.24696.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Nov 2015 08:18:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry provided a syzkaller (http://github.com/google/syzkaller)
> generated program that triggers the WARNING at 
> net/ipv4/tcp.c:1729 in tcp_recvmsg() :
> 
> WARN_ON(tp->copied_seq != tp->rcv_nxt &&
>         !(flags & (MSG_PEEK | MSG_TRUNC)));
> 
> His program is specifically attempting a Cross SYN TCP exchange,
> that we support (for the pleasure of hackers ?), but it looks we
> lack proper tcp->copied_seq initialization.
> 
> Thanks again Dmitry for your report and testings.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks Eric!
