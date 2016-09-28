From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next v3 1/2] netfilter: Fix potential null pointer
 dereference
Date: Wed, 28 Sep 2016 06:35:35 -0700
Message-ID: <1475069735.28155.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475068368-3109-1-git-send-email-aconole@bytheb.org>
         <1475068368-3109-2-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33916 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752559AbcI1Nfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 09:35:38 -0400
In-Reply-To: <1475068368-3109-2-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 09:12 -0400, Aaron Conole wrote:
> It's possible for nf_hook_entry_head to return NULL.  If two
> nf_unregister_net_hook calls happen simultaneously with a single hook
> entry in the list, both will enter the nf_hook_mutex critical section.
> The first will successfully delete the head, but the second will see
> this NULL pointer and attempt to dereference.
> 
> This fix ensures that no null pointer dereference could occur when such
> a condition happens.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> ---
>  net/netfilter/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 360c63d..e58e420 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -160,7 +160,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  
>  	mutex_lock(&nf_hook_mutex);
>  	hooks_entry = nf_hook_entry_head(net, reg);
> -	if (hooks_entry->orig_ops == reg) {
> +	if (hooks_entry && hooks_entry->orig_ops == reg) {
>  		nf_set_hooks_head(net, reg,
>  				  nf_entry_dereference(hooks_entry->next));
>  		goto unlock;

When was the bug added exactly ?

For all bug fixes, you need to add a Fixes: tag.

Like :

Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")

So that 100 different people in stable teams do not have to do the archeology themselves ...

Thanks.
