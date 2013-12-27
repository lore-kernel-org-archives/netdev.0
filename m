From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 19/20] net: plip: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 07:48:03 -0800
Message-ID: <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52BD22ED.4030302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:60501 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab3L0PsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 10:48:07 -0500
In-Reply-To: <52BD22ED.4030302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-27 at 14:49 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> to instead of memcmp.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/plip/plip.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
> index 7b4ff35..26614df 100644
> --- a/drivers/net/plip/plip.c
> +++ b/drivers/net/plip/plip.c
> @@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
>  
>  	if(*eth->h_dest&1)
>  	{
> -		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
> +		if(ether_addr_equal(eth->h_dest, dev->broadcast))
>  			skb->pkt_type=PACKET_BROADCAST;
>  		else
>  			skb->pkt_type=PACKET_MULTICAST;

What about :

        if (is_multicast_ether_addr(eth->h_dest)) {
                if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
                        skb->pkt_type = PACKET_BROADCAST;
                else
                        skb->pkt_type = PACKET_MULTICAST;
        }
