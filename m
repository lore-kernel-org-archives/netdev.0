From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 1/2 nf] netfilter: seqadj: Fix one possible panic in
 seqadj when mem is exhausted
Date: Fri, 2 Sep 2016 08:59:14 +0200
Message-ID: <20160902065914.GC8883@breakpoint.cc>
References: <1472792932-26187-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49108 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751039AbcIBG7R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 02:59:17 -0400
Content-Disposition: inline
In-Reply-To: <1472792932-26187-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fgao@ikuai8.com <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
> extension. But the function nf_ct_seqadj_init doesn't check if get valid
> seqadj pointer by the nfct_seqadj, while other functions perform the
> sanity check.
> 
> So the system would be panic when nfct_seqadj_ext_add failed.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
> index dff0f0c..2c8e201 100644
> --- a/net/netfilter/nf_conntrack_seqadj.c
> +++ b/net/netfilter/nf_conntrack_seqadj.c
> @@ -16,9 +16,14 @@ int nf_ct_seqadj_init(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
>  	if (off == 0)
>  		return 0;
>  
> +	seqadj = nfct_seqadj(ct);
> +	if (unlikely(!seqadj)) {
> +		WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
> +		return 0;
> +	}
> +

Not sure this WARN() is really needed, I would remove it (since its most
likely only missing due to memory shortage).

Other than that, this looks good.
