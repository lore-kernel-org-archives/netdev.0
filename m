From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 10/11] ipv6: move route updating for redirect to ndisc layer
Date: Fri, 13 Sep 2013 00:04:35 +0200
Message-ID: <20130912220435.GC2101@order.stressinduktion.org>
References: <52319A6E.6090503@cn.fujitsu.com> <52319CC5.10902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54405 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab3ILWEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 18:04:37 -0400
Content-Disposition: inline
In-Reply-To: <52319CC5.10902@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 06:51:49PM +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> And when dealing with redirect message, the err shoud
> be assigned to 0.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv6/raw.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index 58916bb..6138199 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -336,7 +336,7 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
>  		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
>  	}
>  	if (type == NDISC_REDIRECT)
> -		ip6_sk_redirect(skb, sk);
> +		err = 0;
>  	if (np->recverr) {
>  		u8 *payload = skb->data;
>  		if (!inet->hdrincl)

Hm, I don't like the cirumstance that we first call icmpv6_err_convert at
first and get back a bogus error value and later on convert it to something
meaningful.

Either:
a) Don't call icmpv6_err_convert at all for redirects. Then we could
   place a WARN_ON(type == NDISC_REDIRECT) into this function to find future
   missuse of this function with redirects or

b) handle the update of the NDISC_REDIRECT error code directly in
   icmpv6_err_convert.

Also that you used the same headings for some commits shows that you could
perhaps squash them into one patch.

Otherwise I'm fine with the changes, thanks.

Greetings,

  Hannes
