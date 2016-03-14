From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: Fix use after free in the recvmmsg exit path
Date: Mon, 14 Mar 2016 12:42:19 -0400 (EDT)
Message-ID: <20160314.124219.1956200224905019589.davem@davemloft.net>
References: <1457960195-4302-1-git-send-email-acme@kernel.org>
	<1457960195-4302-2-git-send-email-acme@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	acme@redhat.com, glider@google.com, edumazet@google.com,
	kcc@google.com, sasha.levin@oracle.com
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbcCNQmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 12:42:22 -0400
In-Reply-To: <1457960195-4302-2-git-send-email-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Mon, 14 Mar 2016 09:56:35 -0300

> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> The syzkaller fuzzer hit the following use-after-free:
> 
>   Call Trace:
>    [<ffffffff8175ea0e>] __asan_report_load8_noabort+0x3e/0x40 mm/kasan/report.c:295
>    [<ffffffff851cc31a>] __sys_recvmmsg+0x6fa/0x7f0 net/socket.c:2261
>    [<     inline     >] SYSC_recvmmsg net/socket.c:2281
>    [<ffffffff851cc57f>] SyS_recvmmsg+0x16f/0x180 net/socket.c:2270
>    [<ffffffff86332bb6>] entry_SYSCALL_64_fastpath+0x16/0x7a
>   arch/x86/entry/entry_64.S:185
> 
> And, as Dmitry rightly assessed, that is because we can drop the
> reference and then touch it when the underlying recvmsg calls return
> some packets and then hit an error, which will make recvmmsg to set
> sock->sk->sk_err, oops, fix it.
> 
> Reported-and-Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Fixes: a2e2725541fa ("net: Introduce recvmmsg socket syscall")
> http://lkml.kernel.org/r/20160122211644.GC2470@redhat.com
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied and queued up for -stable, thanks Arnaldo!
