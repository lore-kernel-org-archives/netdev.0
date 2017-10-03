From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: fix bpf_tail_call() x64 JIT
Date: Tue, 03 Oct 2017 15:48:38 -0700
Message-ID: <1507070918.8061.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171003223720.1517246-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37338 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750865AbdJCWsk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:48:40 -0400
Received: by mail-pg0-f67.google.com with SMTP id o1so10029408pga.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 15:48:40 -0700 (PDT)
In-Reply-To: <20171003223720.1517246-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-03 at 15:37 -0700, Alexei Starovoitov wrote:
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

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
