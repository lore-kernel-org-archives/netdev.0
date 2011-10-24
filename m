From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 7/8 RFC v2] macvtap: Add support to set
 MAC/VLAN filter rtnl link operations
Date: Mon, 24 Oct 2011 07:57:25 +0200
Message-ID: <20111024055725.GD24528@redhat.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
 <20111019062630.7242.99374.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dragos.tatulea@gmail.com,
	arnd@arndb.de, kvm@vger.kernel.org, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111019062630.7242.99374.stgit@savbu-pc100.cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2011 at 11:26:30PM -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> This patch adds support to set MAC and VLAN filter rtnl_link_ops
> on a macvtap interface. It adds support for set_rx_addr_filter and
> set_rx_vlan_filter rtnl link operations. These operations inturn call the
> equivalent operations defined in macvlan
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>
> ---
>  drivers/net/macvtap.c |   22 ++++++++++++++++++----
>  1 files changed, 18 insertions(+), 4 deletions(-)
> 
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 3da5578..8a2cb59 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -273,6 +273,18 @@ static int macvtap_receive(struct sk_buff *skb)
>  	return macvtap_forward(skb->dev, skb);
>  }
>  
> +static int macvtap_set_rx_addr_filter(struct net_device *dev,
> +	struct nlattr *tb[])
> +{
> +	return macvlan_set_rx_addr_filter(dev, tb);
> +}
> +
> +static int macvtap_set_rx_vlan_filter(struct net_device *dev,
> +	struct nlattr *tb[])
> +{
> +	return macvlan_set_rx_vlan_filter(dev, tb);
> +}
> +
>  static int macvtap_newlink(struct net *src_net,
>  			   struct net_device *dev,
>  			   struct nlattr *tb[],


Can use macvlanXXX directly here? Why wrap it?

> @@ -317,10 +329,12 @@ static void macvtap_setup(struct net_device *dev)
>  }
>  
>  static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
> -	.kind		= "macvtap",
> -	.setup		= macvtap_setup,
> -	.newlink	= macvtap_newlink,
> -	.dellink	= macvtap_dellink,
> +	.kind				= "macvtap",
> +	.setup				= macvtap_setup,
> +	.newlink			= macvtap_newlink,
> +	.dellink			= macvtap_dellink,
> +	.set_rx_addr_filter		= macvtap_set_rx_addr_filter,
> +	.set_rx_vlan_filter		= macvtap_set_rx_vlan_filter,
>  };
>  
>  
