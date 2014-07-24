From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_sockopt_find() should return ERESTARTSYS
Date: Thu, 24 Jul 2014 18:19:35 +0100
Message-ID: <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com>
References: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23. Juli 2014 23:53:15 GMT+01:00, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>From: Eric Dumazet <edumazet@google.com>
>
>getsockopt() or setsockopt() sometimes returns -EINTR instead of
>-ENOPROTOOPT, causing headaches to application developers.
>
>This is because unsupported commands might go through nf_sockopt_find()
>and this function returns -EINTR instead of -ERESTARTSYS if
>a signal is pending.
>

I'd propose to simply use the non interruptable mutex functions. We
have many instances where this is really completely unnecessary.

I can take care of this (once my notebook has been repaired).

>Signed-off-by: Eric Dumazet <edumazet@google.com>
>---
> net/netfilter/nf_sockopt.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
>index f042ae521557..37181447715b 100644
>--- a/net/netfilter/nf_sockopt.c
>+++ b/net/netfilter/nf_sockopt.c
>@@ -66,7 +66,7 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct
>sock *sk, u_int8_t pf,
> 	struct nf_sockopt_ops *ops;
> 
> 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
>-		return ERR_PTR(-EINTR);
>+		return ERR_PTR(-ERESTARTSYS);
> 
> 	list_for_each_entry(ops, &nf_sockopts, list) {
> 		if (ops->pf == pf) {
>
>


