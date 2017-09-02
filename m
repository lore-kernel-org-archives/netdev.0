From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/4] net: dsa: change dsa_ptr for a dsa_master
Date: Sat, 2 Sep 2017 17:30:08 +0200
Message-ID: <20170902153008.GA21003@lunn.ch>
References: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
 <20170831183746.2109-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170831183746.2109-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien


> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index f4a5afc4255b..d5b24cd10f79 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -130,11 +130,6 @@ struct dsa_switch_tree {
>  	 */
>  	struct dsa_platform_data	*pd;
>  
> -	/* Copy of tag_ops->rcv for faster access in hot path */
> -	struct sk_buff *	(*rcv)(struct sk_buff *skb,
> -				       struct net_device *dev,
> -				       struct packet_type *pt);
> -
>  	/*
>  	 * The switch port to which the CPU is attached.
>  	 */


> diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
> index fbf9ca954773..7897bbd1a110 100644
> --- a/net/dsa/tag_dsa.c
> +++ b/net/dsa/tag_dsa.c
> @@ -67,7 +67,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
>  			       struct packet_type *pt)
>  {
> -	struct dsa_switch_tree *dst = dev->dsa_ptr;
> +	struct dsa_master *master = dev->dsa_ptr;
> +	struct dsa_switch_tree *dst = master->port->ds->dst;

This is on the hot path. Every frame received comes through here. We
have gone from one dereference to 4 dereference. That is going to
impact performance. 

How about keeping a copy of dst and ds in master?

    Andrew
