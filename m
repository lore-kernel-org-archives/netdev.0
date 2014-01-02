From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in sit
Date: Wed, 01 Jan 2014 19:43:02 -0800
Message-ID: <1388634182.12212.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388623776-1448-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:44674 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaABDnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:43:04 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so13989135pad.24
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 19:43:03 -0800 (PST)
In-Reply-To: <1388623776-1448-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 08:49 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when read/write the 64bit data, the correct lock should be hold.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/sit.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 366fbba..1e33d77 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -702,8 +702,10 @@ static int ipip6_rcv(struct sk_buff *skb)
>  		}
>  
>  		tstats = this_cpu_ptr(tunnel->dev->tstats);
> +		u64_stats_update_begin(&tstats->syncp);
>  		tstats->rx_packets++;
>  		tstats->rx_bytes += skb->len;
> +		u64_stats_update_end(&tstats->syncp);
>  
>  		netif_rx(skb);
>  

Fixes: 87b6d218f3adb ("tunnel: implement 64 bits statistics")
Cc: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Eric Dumazet <edumazet@google.com>

Thats a candidate for net and stable trees.
