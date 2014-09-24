From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: Fix receive statistics under-reporting
Date: Wed, 24 Sep 2014 08:08:53 -0700
Message-ID: <1411571333.15395.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140922090134.3a114531@urahara>
	 <1411569906-31679-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48012 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbaIXPIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 11:08:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id et14so8845542pad.15
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 08:08:49 -0700 (PDT)
In-Reply-To: <1411569906-31679-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 10:45 -0400, Vladislav Yasevich wrote:
> Vlan devices uder-report 14 bytes per packet in the recieve statistics.
> This is because the ETH_HLEN bytes of data has been pulled off the skb
> by the time it gets to the vlan receive code.  When accounting for
> receive butes, add ETH_HLEN back.
> 
> See also https://bugzilla.kernel.org/show_bug.cgi?id=84951
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  net/8021q/vlan_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 90cc2bd..8bc5d46 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -54,7 +54,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
>  
>  	u64_stats_update_begin(&rx_stats->syncp);
>  	rx_stats->rx_packets++;
> -	rx_stats->rx_bytes += skb->len;
> +	rx_stats->rx_bytes += skb->len + ETH_HLEN;
>  	if (skb->pkt_type == PACKET_MULTICAST)
>  		rx_stats->rx_multicast++;
>  	u64_stats_update_end(&rx_stats->syncp);


I do not think this patch is general enough, it doesn't handle GRO for
example.

And should not the vlan tag also be accounted ? 
