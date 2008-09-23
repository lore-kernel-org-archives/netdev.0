From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH]: tcp: Fix queue traversal in tcp_use_frto().
Date: Tue, 23 Sep 2008 22:18:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809232214320.14360@wrl-59.cs.helsinki.fi>
References: <20080923.025542.193703353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53237 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbYIWTSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 15:18:36 -0400
In-Reply-To: <20080923.025542.193703353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008, David Miller wrote:

> 
> One more skb_queue_next() BUG trigger.  I double audited the
> remaining tcp_write_queue_next() cases and they should all
> be good.
> 
> tcp: Fix queue traversal in tcp_use_frto().
> 
> We must check tcp_skb_is_last() before doing a tcp_write_queue_next().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/tcp_input.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index cbfe13d..3b76bce 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1746,6 +1746,8 @@ int tcp_use_frto(struct sock *sk)
>  		return 0;
>  
>  	skb = tcp_write_queue_head(sk);
> +	if (tcp_skb_is_last(sk, skb))
> +		return 1;
>  	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
>  	tcp_for_write_queue_from(skb, sk) {
>  		if (skb == tcp_send_head(sk))
> 

For the record (as you probably know it already), this wasn't actually
a real bug though it hits your BUG_ON since tcp_for_write_queue_from exits
immediately, no garbage gets dereferenced.

-- 
 i.
