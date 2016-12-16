From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: cgroup: annotate pointers in struct cgroup_bpf with
 __rcu
Date: Fri, 16 Dec 2016 10:20:37 -0800
Message-ID: <20161216182036.GB80546@ast-mbp.thefacebook.com>
References: <20161215095321.10571-1-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35598 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757923AbcLPSUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:20:41 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so10429474pga.2
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 10:20:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161215095321.10571-1-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 10:53:21AM +0100, Daniel Mack wrote:
> The member 'effective' in 'struct cgroup_bpf' is protected by RCU.
> Annotate it accordingly to squelch a sparse warning.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>

was only wondering whether this is really needed for net or can wait till net-next.

> ---
>  include/linux/bpf-cgroup.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
> index 7b6e5d1..92bc89a 100644
> --- a/include/linux/bpf-cgroup.h
> +++ b/include/linux/bpf-cgroup.h
> @@ -20,7 +20,7 @@ struct cgroup_bpf {
>  	 * when this cgroup is accessed.
>  	 */
>  	struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
> -	struct bpf_prog *effective[MAX_BPF_ATTACH_TYPE];
> +	struct bpf_prog __rcu *effective[MAX_BPF_ATTACH_TYPE];
>  };
>  
>  void cgroup_bpf_put(struct cgroup *cgrp);
> -- 
> 2.9.3
> 
