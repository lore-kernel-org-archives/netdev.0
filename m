From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] bpf: muli prog support for cgroup-bpf
Date: Wed, 04 Oct 2017 16:05:28 -0700 (PDT)
Message-ID: <20171004.160528.1174839158695833052.davem@davemloft.net>
References: <20171003055028.1294791-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tj@kernel.org, dsa@cumulusnetworks.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdJDXF3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 19:05:29 -0400
In-Reply-To: <20171003055028.1294791-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 2 Oct 2017 22:50:20 -0700

> v1->v2:
> - fixed accidentally swapped two lines which caused static_key not going to zero
> - addressed Martin's feedback and changed prog_query to be consistent
>   with verifier output: return -enospc and fill supplied buffer instead
>   of just returning -enospc when buffer is too small to fit all prog_ids
> 
> v1:
> cgroup-bpf use cases are getting more advanced and running only
> one program per cgroup is no longer enough. Therefore introduce
> support for attaching multiple programs per cgroup and running
> a set of effective programs.
> 
> These patches introduces BPF_F_ALLOW_MULTI flag for BPF_PROG_ATTACH cmd.
> The default is still NONE and behavior of BPF_F_ALLOW_OVERRIDE flag
> is unchanged.
> The difference between three possible flags for BPF_PROG_ATTACH command:
> - NONE(default): No further bpf programs allowed in the subtree.
> - BPF_F_ALLOW_OVERRIDE: If a sub-cgroup installs some bpf program,
>   the program in this cgroup yields to sub-cgroup program.
> - BPF_F_ALLOW_MULTI: If a sub-cgroup installs some bpf program,
>   that cgroup program gets run in addition to the program in this cgroup.
> 
> Most of the logic is in patch 1. Even when cgroup doesn't have
> any programs attached its set of effective program can be non-empty.
> To quickly execute them and avoid penalizing cgroups without
> any effective programs introduce 'struct bpf_prog_array'
> which has an optimization for cgroups with zero effective programs.
> 
> Patch 2 introduces BPF_PROG_QUERY command for introspection
> Patch 3 makes verifier more strict for cgroup-bpf program types.
> Patch 4+ are tests.
> 
> More details in individual patches

Looks good, series applied, thanks!
