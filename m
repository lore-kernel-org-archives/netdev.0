From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/6] netfilter: sanity checks on NFPROTO_NUMPROTO
Date: Mon, 14 May 2012 16:42:35 +0200
Message-ID: <20120514144235.GE12992@1984>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 02:56:34PM +0100, Alban Crequy wrote:
> With the NFPROTO_* constants introduced by commit 7e9c6e ("netfilter: Introduce
> NFPROTO_* constants"), it is too easy to confuse PF_* and NFPROTO_* constants
> in new protocols.
> 
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
> ---
>  net/netfilter/core.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index e1b7e05..4f16552 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -67,6 +67,11 @@ int nf_register_hook(struct nf_hook_ops *reg)
>  	struct nf_hook_ops *elem;
>  	int err;
>  
> +	if (reg->pf >= NFPROTO_NUMPROTO || reg->hooknum >= NF_MAX_HOOKS) {
> +		BUG();
> +		return 1;

nf_register_hook returns a negative value on error. -EINVAL can be
fine.

> +	}
> +
>  	err = mutex_lock_interruptible(&nf_hook_mutex);
>  	if (err < 0)
>  		return err;
> -- 
> 1.7.2.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
