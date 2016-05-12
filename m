From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error
 unwinding
Date: Thu, 12 May 2016 11:47:25 +0200
Message-ID: <20160512094725.GB1777@salvia>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462981273-21676-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 11, 2016 at 05:41:13PM +0200, Florian Westphal wrote:
> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
> index 5baa8e2..9722819 100644
> --- a/net/netfilter/nf_queue.c
> +++ b/net/netfilter/nf_queue.c
> @@ -102,6 +102,13 @@ void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
>  {
>  	const struct nf_queue_handler *qh;
>  
> +	/* netns wasn't initialized, error unwind in progress.
> +	 * Its possible that the nfq netns init function was not even
> +	 * called, in which case nfq pernetns data is in undefined state.
> +	 */
> +	if (!net->list.next)
> +		return;

Thanks Florian.

Question for the netns folks: Is this a stable assumption? My only
concern with this is that it relies on internal the netns
representation, so I'd like to make sure this thing doesn't break
again.

Let me know, thanks.
