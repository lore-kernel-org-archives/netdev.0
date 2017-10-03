From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bpf_tail_call() x64 JIT
Date: Tue, 03 Oct 2017 16:05:00 -0700 (PDT)
Message-ID: <20171003.160500.1804100102889469834.davem@davemloft.net>
References: <20171003223720.1517246-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, kafai@fb.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbdJCXFB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 19:05:01 -0400
In-Reply-To: <20171003223720.1517246-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 3 Oct 2017 15:37:20 -0700

> - bpf prog_array just like all other types of bpf array accepts 32-bit index.
>   Clarify that in the comment.
> - fix x64 JIT of bpf_tail_call which was incorrectly loading 8 instead of 4 bytes
> - tighten corresponding check in the interpreter to stay consistent
> 
> The JIT bug can be triggered after introduction of BPF_F_NUMA_NODE flag
> in commit 96eabe7a40aa in 4.14. Before that the map_flags would stay zero and
> though JIT code is wrong it will check bounds correctly.
> Hence two fixes tags. All other JITs don't have this problem.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Fixes: 96eabe7a40aa ("bpf: Allow selecting numa node during map creation")
> Fixes: b52f00e6a715 ("x86: bpf_jit: implement bpf_tail_call() helper")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> ---
> Backport to stable would be nice, but not strictly necessary.

Applied and queued up for -stable, thanks.
