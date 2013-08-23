From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netfilter: avoid array overflow in nf_register_hook
Date: Fri, 23 Aug 2013 22:14:39 +0400
Message-ID: <5217A68F.2050302@cogentembedded.com>
References: <1377313651-16096-1-git-send-email-yp.fangdong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Dong Fang <yp.fangdong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1377313651-16096-1-git-send-email-yp.fangdong@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/24/2013 07:07 AM, Dong Fang wrote:

> This patch fix the array overflow in nf_register_hook function

> Signed-off-by: Dong Fang <yp.fangdong@gmail.com>
> ---
>   net/netfilter/core.c |    5 ++++-
>   1 files changed, 4 insertions(+), 1 deletions(-)

> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 2217363..819eee1 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -68,8 +68,11 @@ static DEFINE_MUTEX(nf_hook_mutex);
>   int nf_register_hook(struct nf_hook_ops *reg)
>   {
>   	struct nf_hook_ops *elem;
> -	int err;
> +	int err = -EINVAL;
>
> +	if (reg->pf >= NFPROTO_NUMPROTO || reg->hooknum >= NF_MAX_HOOKS)
> +		return err;

    Why not just return -EINVAL and avoid unneeded 'err' initialization?

> +
>   	err = mutex_lock_interruptible(&nf_hook_mutex);
>   	if (err < 0)
>   		return err;

WBR, Sergei


