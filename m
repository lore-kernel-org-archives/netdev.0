From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: remove tail_call and get_stackid helper
 declarations from bpf.h
Date: Fri, 27 Oct 2017 22:14:38 +0900 (KST)
Message-ID: <20171027.221438.2258011998431145175.davem@davemloft.net>
References: <20171026014742.48509-1-g.borello@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
To: g.borello@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751908AbdJ0NOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:14:45 -0400
In-Reply-To: <20171026014742.48509-1-g.borello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>
Date: Thu, 26 Oct 2017 01:47:42 +0000

> commit afdb09c720b6 ("security: bpf: Add LSM hooks for bpf object related
> syscall") included linux/bpf.h in linux/security.h. As a result, bpf
> programs including bpf_helpers.h and some other header that ends up
> pulling in also security.h, such as several examples under samples/bpf,
> fail to compile because bpf_tail_call and bpf_get_stackid are now
> "redefined as different kind of symbol".
> 
> From bpf.h:
> 
> u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
> u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
> 
> Whereas in bpf_helpers.h they are:
> 
> static void (*bpf_tail_call)(void *ctx, void *map, int index);
> static int (*bpf_get_stackid)(void *ctx, void *map, int flags);
> 
> Fix this by removing the unused declaration of bpf_tail_call and moving
> the declaration of bpf_get_stackid in bpf_trace.c, which is the only
> place where it's needed.
> 
> Signed-off-by: Gianluca Borello <g.borello@gmail.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thank you Gianluca.
