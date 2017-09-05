From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: fix numa_node validation
Date: Tue, 5 Sep 2017 07:43:12 -0700
Message-ID: <8bcc1ff5-7b0e-1d4e-fb4e-8e5033630443@fb.com>
References: <1504590062.15310.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49938 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751345AbdIEOnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 10:43:12 -0400
In-Reply-To: <1504590062.15310.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/4/17 10:41 PM, Eric Dumazet wrote:
> Call Trace:
>  __do_kmalloc_node mm/slab.c:3688 [inline]
>  __kmalloc_node+0x33/0x70 mm/slab.c:3696
>  kmalloc_node include/linux/slab.h:535 [inline]
>  alloc_htab_elem+0x2a8/0x480 kernel/bpf/hashtab.c:740
>  htab_map_update_elem+0x740/0xb80 kernel/bpf/hashtab.c:820
>  map_update_elem kernel/bpf/syscall.c:587 [inline]
>  SYSC_bpf kernel/bpf/syscall.c:1468 [inline]
>  SyS_bpf+0x20c5/0x4c40 kernel/bpf/syscall.c:1443
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x440409
> RSP: 002b:00007ffd1f1792b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000141
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 0000000000440409
> RDX: 0000000000000020 RSI: 0000000020006000 RDI: 0000000000000002
> RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000401d70
> R13: 0000000000401e00 R14: 0000000000000000 R15: 0000000000000000
> Code: 83 c2 01 89 50 18 4c 03 70 08 e8 38 f4 ff ff 4d 85 f6 0f 85 3e ff ff ff 44 89 fe 4c 89 ef e8 94 fb ff ff 49 89 c6 e9 2b ff ff ff <0f> 0b 0f 0b 0f 0b 66 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 41
> RIP: ____cache_alloc_node+0x1d4/0x1e0 mm/slab.c:3292 RSP: ffff8801c0c97638
> ---[ end trace d745f355da2e33ce ]---
> Kernel panic - not syncing: Fatal exception
>
> Fixes: 96eabe7a40aa ("bpf: Allow selecting numa node during map creation")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good catch. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
