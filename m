From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: check both type and procotol for tcp sockets
Date: Thu, 17 Dec 2015 15:47:11 -0500 (EST)
Message-ID: <20151217.154711.623723483208177420.davem@davemloft.net>
References: <1450337944-22834-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemdebruijn.kernel@gmail.com,
	eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbLQUrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:47:13 -0500
In-Reply-To: <1450337944-22834-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 16 Dec 2015 23:39:04 -0800

> Dmitry reported the following out-of-bound access:
> 
> Call Trace:
>  [<ffffffff816cec2e>] __asan_report_load4_noabort+0x3e/0x40
> mm/kasan/report.c:294
>  [<ffffffff84affb14>] sock_setsockopt+0x1284/0x13d0 net/core/sock.c:880
>  [<     inline     >] SYSC_setsockopt net/socket.c:1746
>  [<ffffffff84aed7ee>] SyS_setsockopt+0x1fe/0x240 net/socket.c:1729
>  [<ffffffff85c18c76>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
> 
> This is because we mistake a raw socket as a tcp socket.
> We should check both sk->sk_type and sk->sk_protocol to ensure
> it is a tcp socket.
> 
> Willem points out __skb_complete_tx_timestamp() needs to fix as well.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
