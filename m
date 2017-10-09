From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: linux-next: manual merge of the cgroup tree with the net-next
 tree
Date: Mon, 9 Oct 2017 16:04:25 -0700
Message-ID: <20171009230424.4p7r4b7s7xubmyhi@ast-mbp>
References: <20171009183836.cceczuqytzmgqubr@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009183836.cceczuqytzmgqubr@sirena.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 07:38:36PM +0100, Mark Brown wrote:
> Hi Tejun,
> 
> Today's linux-next merge of the cgroup tree got a conflict in:
> 
>   kernel/cgroup/cgroup.c
> 
> between commit:
> 
>   324bda9e6c5ad ("bpf: multi program support for cgroup+bpf")
> 
> from the net-next tree and commit:
> 
>   041cd640b2f3c ("cgroup: Implement cgroup2 basic CPU usage accounting")
> 
> from the cgroup tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.
> 
> diff --cc kernel/cgroup/cgroup.c
> index 00f5b358aeac,c3421ee0d230..000000000000
> --- a/kernel/cgroup/cgroup.c
> +++ b/kernel/cgroup/cgroup.c
> @@@ -4765,8 -4785,9 +4788,11 @@@ static struct cgroup *cgroup_create(str
>   
>   	return cgrp;
>   
>  +out_idr_free:
>  +	cgroup_idr_remove(&root->cgroup_idr, cgrp->id);
> + out_stat_exit:
> + 	if (cgroup_on_dfl(parent))
> + 		cgroup_stat_exit(cgrp);

thanks. I did the same merge conflict resolution for our combined tree.
