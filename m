From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH v2 net-next] softirq: reduce latencies
Date: Sat, 5 Jan 2013 09:58:16 +0100
Message-ID: <CA+icZUW+pvysyTKxaeO=1t1yXGHbSvLjViYnPHoz-osykuVq+w@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:57054 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152Ab3AEI6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 03:58:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ QUOTE ]

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jan 2013 23:49:40 -0800

> From: Eric Dumazet <edumazet@google.com>
>
> In various network workloads, __do_softirq() latencies can be up
> to 20 ms if HZ=1000, and 200 ms if HZ=100.
>
> This is because we iterate 10 times in the softirq dispatcher,
> and some actions can consume a lot of cycles.
>
> This patch changes the fallback to ksoftirqd condition to :
>
> - A time limit of 2 ms.
> - need_resched() being set on current task
>
> When one of this condition is met, we wakeup ksoftirqd for further
> softirq processing if we still have pending softirqs.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: David S. Miller <davem@davemloft.net>

[ /QUOTE ]

Tested-by: Sedat Dilek <sedat.dilek@gmail.com> (against Linux v3.8-rc2)
