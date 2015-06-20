From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: nf_queue: Don't recompute the hook_list
 head
Date: Sat, 20 Jun 2015 12:58:39 +0200
Message-ID: <20150620105839.GB3439@salvia>
References: <87381ne3rq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35684 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbbFTKxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 06:53:17 -0400
Content-Disposition: inline
In-Reply-To: <87381ne3rq.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2015 at 05:23:37PM -0500, Eric W. Biederman wrote:
> 
> If someone sends packets from one of the netdevice ingress hooks to
> the a userspace queue, and then userspace later accepts the packet,
> the netfilter code can enter an infinite loop as the list head will
> never be found.
> 
> Pass in the saved list_head to avoid this.

There is no userspace queueing for netdevice yet, so this can be route
through nf-next. Thanks.

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/netfilter/nf_queue.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
> index cd60d397fe05..8a8b2abc35ff 100644
> --- a/net/netfilter/nf_queue.c
> +++ b/net/netfilter/nf_queue.c
> @@ -213,7 +213,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
>  
>  	if (verdict == NF_ACCEPT) {
>  	next_hook:
> -		verdict = nf_iterate(&nf_hooks[entry->state.pf][entry->state.hook],
> +		verdict = nf_iterate(entry->state.hook_list,
>  				     skb, &entry->state, &elem);
>  	}
>  
> -- 
> 2.2.1
> 
