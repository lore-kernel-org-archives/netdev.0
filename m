From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] netlink: reset skb->peeked when reuse orphan skb for
 next broadcast
Date: Fri, 10 Jul 2015 15:13:19 +0300
Message-ID: <559FB6DF.1000108@yandex-team.ru>
References: <20150710115145.13008.14667.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:53745 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753724AbbGJMPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 08:15:06 -0400
In-Reply-To: <20150710115145.13008.14667.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.07.2015 14:51, Konstantin Khlebnikov wrote:
> This patch clears skb->peeked set by previous recipient of broadcast.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: add05ad4e9f5 ("unix/dgram: peek beyond 0-sized skbs")
> ---
>   net/netlink/af_netlink.c |    1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 921e0d8dfe3a..4e5c298c88b5 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1967,6 +1967,7 @@ static void do_one_broadcast(struct sock *sk,
>   			 * delivered to a previous socket.
>   			 */
>   			skb_orphan(p->skb2);
> +			skb->peeked = 0;
>   		}
>   	}
>   	if (p->skb2 == NULL) {
>

Oops, sorry. Please ignore it.

-- 
Konstantin
