From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] icmp: correct return value of icmp_rcv()
Date: Wed, 07 Dec 2016 06:18:18 -0800
Message-ID: <1481120298.4930.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481093573-5123-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34547 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752117AbcLGOSZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 09:18:25 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so23601368pgc.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 06:18:20 -0800 (PST)
In-Reply-To: <1481093573-5123-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 14:52 +0800, Zhang Shengju wrote:
> Currently, icmp_rcv() always return zero on a packet delivery upcall.
> 
> To make its behavior more compliant with the way this API should be
> used, this patch changes this to let it return NET_RX_SUCCESS when the
> packet is proper handled, and NET_RX_DROP otherwise.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/ipv4/icmp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 691146a..f79d7a8 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -1047,12 +1047,12 @@ int icmp_rcv(struct sk_buff *skb)
>  
>  	if (success)  {
>  		consume_skb(skb);
> -		return 0;
> +		return NET_RX_SUCCESS;
>  	}
>  
>  drop:
>  	kfree_skb(skb);
> -	return 0;
> +	return NET_RX_DROP;
>  csum_error:
>  	__ICMP_INC_STATS(net, ICMP_MIB_CSUMERRORS);
>  error:


I am curious, what external/visible effects do you expect from such a
change ?

We now have a very precise monitoring of where packets are dropped
(consume_skb()/kfree_skb()) 
