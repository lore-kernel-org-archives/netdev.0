From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: Fix test_lru_sanity5() in test_lru_map.c
Date: Tue, 17 Jan 2017 10:07:32 +0100
Message-ID: <587DDED4.5060706@iogearbox.net>
References: <1484633849-2742833-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49486 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdAQJIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 04:08:05 -0500
In-Reply-To: <1484633849-2742833-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 07:17 AM, Martin KaFai Lau wrote:
> test_lru_sanity5() fails when the number of online cpus
> is fewer than the number of possible cpus.  It can be
> reproduced with qemu by using cmd args "--smp cpus=2,maxcpus=8".
>
> The problem is the loop in test_lru_sanity5() is testing
> 'i' which is incorrect.
>
> This patch:
> 1. Make sched_next_online() always return -1 if it cannot
>     find a next cpu to schedule the process.
> 2. In test_lru_sanity5(), the parent process does
>     sched_setaffinity() first (through sched_next_online())
>     and the forked process will inherit it according to
>     the 'man sched_setaffinity'.
>
> Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Looks good, thanks for fixing!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

(Patch is against -net tree.)
