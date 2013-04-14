From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: use htonl when snooping for loopback
 address
Date: Sun, 14 Apr 2013 09:57:39 -0700
Message-ID: <20130414095739.5ddfbe0a@nehalam.linuxnetplumber.net>
References: <1365931299-26240-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:60675 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab3DNQ6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 12:58:06 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so2127531pdj.13
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 09:58:05 -0700 (PDT)
In-Reply-To: <1365931299-26240-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Apr 2013 12:21:39 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> Currently "bridge fdb show dev vxlan0" lists loopback address as
> "1.0.0.127". Using htonl(INADDR_LOOPBACK) rather than passing it
> directly to vxlan_snoop fixes the problem.
> 
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
>  drivers/net/vxlan.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index ee02ecd..725aba3 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -925,7 +925,8 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
>  	__skb_pull(skb, skb_network_offset(skb));
>  
>  	if (dst_vxlan->flags & VXLAN_F_LEARN)
> -		vxlan_snoop(skb->dev, INADDR_LOOPBACK, eth_hdr(skb)->h_source);
> +		vxlan_snoop(skb->dev, htonl(INADDR_LOOPBACK),
> +			    eth_hdr(skb)->h_source);
>  
>  	u64_stats_update_begin(&tx_stats->syncp);
>  	tx_stats->tx_packets++;

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
