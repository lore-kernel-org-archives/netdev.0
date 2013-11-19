From: wangweidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net] net: sctp: fix copying sk_v6_rcv_saddr in sctp_v6_create_accept_sk
Date: Tue, 19 Nov 2013 19:08:11 +0800
Message-ID: <528B469B.3060702@huawei.com>
References: <1384858284-2246-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:64305 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab3KSLIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 06:08:30 -0500
In-Reply-To: <1384858284-2246-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/19 18:51, Daniel Borkmann wrote:
> Wang reported an issue that lksctp's test_getname_v6 seems to fail.
> 
> The issue is that we do not copy sk_v6_rcv_saddr over to the new
> socket, although the comment above says so regarding rcv_saddr.
> 
> Commit 914e1c8b6980 ("sctp: Inherit all socket options from parent
> correctly.") originally moved that over to sctp_copy_sock(), but
> after commit efe4208f47f9 ("ipv6: make lookups simpler and faster")
> this no longer holds and the actual value of sk_v6_rcv_saddr was
> no longer being migrated.
> 
> With this patch, the lksctp test suite passes again for IPv6.
> 
> Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/sctp/ipv6.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 7567e6f..be08592 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -661,6 +661,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
>  	 * and getpeername().
>  	 */
>  	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
> +	newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
>  
>  	sk_refcnt_debug_inc(newsk);
> 

Acked-by: Wang Weidong <wangweidong1@huawei.com>
 
> 
