From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH][bpf-next] bpf: remove redundant variable old_flags
Date: Wed, 11 Oct 2017 11:15:49 -0700
Message-ID: <20171011181548.xcdz7s44h5lo4pu2@ast-mbp>
References: <20171011105623.19998-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171011105623.19998-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 11, 2017 at 11:56:23AM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable old_flags is being assigned but is never read; it is redundant
> and can be removed.
> 
> Cleans up clang warning: Value stored to 'old_flags' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  kernel/bpf/cgroup.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> index e88abc0865d5..3db5a17fcfe8 100644
> --- a/kernel/bpf/cgroup.c
> +++ b/kernel/bpf/cgroup.c
> @@ -192,7 +192,6 @@ int __cgroup_bpf_attach(struct cgroup *cgrp, struct bpf_prog *prog,
>  	struct cgroup_subsys_state *css;
>  	struct bpf_prog_list *pl;
>  	bool pl_was_allocated;
> -	u32 old_flags;
>  	int err;
>  
>  	if ((flags & BPF_F_ALLOW_OVERRIDE) && (flags & BPF_F_ALLOW_MULTI))
> @@ -239,7 +238,6 @@ int __cgroup_bpf_attach(struct cgroup *cgrp, struct bpf_prog *prog,
>  		pl->prog = prog;
>  	}
>  
> -	old_flags = cgrp->bpf.flags[type];

Acked-by: Alexei Starovoitov <ast@kernel.org>

thanks for the cleanup. That was a leftover of one of the previous
experiments I did.

The patch is for net-next.
