From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 01/11] ipv6: skb_put_zero() used to optimize
 code
Date: Wed, 14 Jun 2017 08:44:34 -0700
Message-ID: <20170614084434.3342671d@xeon-e3>
References: <1497451026-3923-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35213 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbdFNPom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 11:44:42 -0400
Received: by mail-pg0-f52.google.com with SMTP id k71so1902127pgd.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 08:44:41 -0700 (PDT)
In-Reply-To: <1497451026-3923-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 22:37:06 +0800
yuan linyu <cugyly@163.com> wrote:

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> ---
>  net/ipv6/mcast.c |  3 +--
>  net/ipv6/ndisc.c | 13 ++-----------
>  2 files changed, 3 insertions(+), 13 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 07403fa..b186c67 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -2008,8 +2008,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
>  
>  	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
>  
> -	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct mld_msg));
> -	memset(hdr, 0, sizeof(struct mld_msg));
> +	hdr = (struct mld_msg *) skb_put_zero(skb, sizeof(struct mld_msg));

Why does skb_put_zero return char * instead of void *?
If returned void * it would save having to add lots of casts.

One could even go farther by making skb_put_zero a macro and
use typeof().
