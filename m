From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 1/3] ipv4: call __ip_options_echo() in
 cookie_v4_check()
Date: Wed, 15 Oct 2014 21:15:45 -0700
Message-ID: <1413432945.28798.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55139 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaJPEPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 00:15:46 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so2619027pac.35
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 21:15:46 -0700 (PDT)
In-Reply-To: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-15 at 14:33 -0700, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
> 
> commit 971f10eca186cab238c49da ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> missed that cookie_v4_check() still calls ip_options_echo() which uses
> IPCB(). It should use TCPCB() at TCP layer, so call __ip_options_echo()
> instead.
> 
> Fixes: commit 971f10eca186cab238c49da ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Cc: Eric Dumazet <edumazet@google.com>
> Reported-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Tested-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/syncookies.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index 0431a8f..7e7401c 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -321,7 +321,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
>  		int opt_size = sizeof(struct ip_options_rcu) + opt->optlen;
>  
>  		ireq->opt = kmalloc(opt_size, GFP_ATOMIC);
> -		if (ireq->opt != NULL && ip_options_echo(&ireq->opt->opt, skb)) {
> +		if (ireq->opt != NULL && __ip_options_echo(&ireq->opt->opt, skb, opt)) {
>  			kfree(ireq->opt);
>  			ireq->opt = NULL;
>  		}

Signed-off-by: Eric Dumazet <edumazet@google.com>
