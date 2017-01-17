From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: Fix test_lru_sanity5() in test_lru_map.c
Date: Tue, 17 Jan 2017 15:40:06 -0500 (EST)
Message-ID: <20170117.154006.1457576513883871851.davem@davemloft.net>
References: <1484633849-2742833-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdAQUkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:40:08 -0500
In-Reply-To: <1484633849-2742833-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 16 Jan 2017 22:17:29 -0800

> test_lru_sanity5() fails when the number of online cpus
> is fewer than the number of possible cpus.  It can be
> reproduced with qemu by using cmd args "--smp cpus=2,maxcpus=8".
> 
> The problem is the loop in test_lru_sanity5() is testing
> 'i' which is incorrect.
> 
> This patch:
> 1. Make sched_next_online() always return -1 if it cannot
>    find a next cpu to schedule the process.
> 2. In test_lru_sanity5(), the parent process does
>    sched_setaffinity() first (through sched_next_online())
>    and the forked process will inherit it according to
>    the 'man sched_setaffinity'.
> 
> Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied, thanks.
