From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: avoid array overflow in nf_register_hook
Date: Fri, 23 Aug 2013 09:05:55 -0700
Message-ID: <1377273955.8828.13.camel@edumazet-glaptop>
References: <1377313495-16060-1-git-send-email-yp.fangdong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Dong Fang <yp.fangdong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1377313495-16060-1-git-send-email-yp.fangdong@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-23 at 23:04 -0400, Dong Fang wrote:
> This patch fix the array overflow in nf_register_hook function
> 
> Signed-off-by: Dong Fang <yp.fangdong@gmail.com>
> ---
>  net/netfilter/core.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 2217363..819eee1 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -68,8 +68,11 @@ static DEFINE_MUTEX(nf_hook_mutex);
>  int nf_register_hook(struct nf_hook_ops *reg)
>  {
>  	struct nf_hook_ops *elem;
> -	int err;
> +	int err = -EINVAL;
>  
> +	if (reg->pf >= NFPROTO_NUMPROTO || reg->hooknum >= NF_MAX_HOOKS)
> +		return err;
> +

Thats a bug in the caller.

We want a hard crash so that the poor netfilter guy who made this error
can fix the bug before sending us a buggy patch.


