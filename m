From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] vlan: rename __vlan_find_dev_deep() to  __vlan_find_dev_deep_rcu_rcu()
Date: Fri, 9 May 2014 10:19:50 +0800
Message-ID: <536C3B46.9050605@huawei.com>
References: <536AEC02.7050202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <536AEC02.7050202@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/5/8 10:29, Ding Tianhong wrote:
> The __vlan_find_dev_deep should always called in RCU, according
> David's suggestion, rename to __vlan_find_dev_deep_rcu looks more
> reasonable.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Self Nacked, I make this patch from net repository, and could not applied
to net-next, I will fix this and resend for net-next repository, sorry for the noise.

Ding


> ---
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |  2 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  2 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 +-
>  drivers/net/usb/cdc_mbim.c                         |  2 +-
>  drivers/s390/net/qeth_l3_main.c                    | 10 +++++-----
>  include/linux/if_vlan.h                            |  4 ++--
>  net/8021q/vlan_core.c                              |  6 +++---
>  net/bridge/br_netfilter.c                          |  2 +-
>  8 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> index c0a9dd5..b0cbb2b 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> @@ -185,7 +185,7 @@ static struct net_device *get_iff_from_mac(struct adapter *adapter,
>  		if (ether_addr_equal(dev->dev_addr, mac)) {
>  			rcu_read_lock();
>  			if (vlan && vlan != VLAN_VID_MASK) {
> -				dev = __vlan_find_dev_deep(dev, htons(ETH_P_8021Q), vlan);
> +				dev = __vlan_find_dev_deep_rcu(dev, htons(ETH_P_8021Q), vlan);
>  			} else if (netif_is_bond_slave(dev)) {
>  				struct net_device *upper_dev;
>  
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 24e16e3..05ce66e 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4061,7 +4061,7 @@ static int update_root_dev_clip(struct net_device *dev)
>  
>  	/* Parse all bond and vlan devices layered on top of the physical dev */
>  	for (i = 0; i < VLAN_N_VID; i++) {
> -		root_dev = __vlan_find_dev_deep(dev, htons(ETH_P_8021Q), i);
> +		root_dev = __vlan_find_dev_deep_rcu(dev, htons(ETH_P_8021Q), i);
>  		if (!root_dev)
>  			continue;
>  
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 7e55e88..076aa5e 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -4122,7 +4122,7 @@ void qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
>  
>  	rcu_read_lock();
>  	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
> -		dev = __vlan_find_dev_deep(netdev, htons(ETH_P_8021Q), vid);
> +		dev = __vlan_find_dev_deep_rcu(netdev, htons(ETH_P_8021Q), vid);
>  		if (!dev)
>  			continue;
>  		qlcnic_config_indev_addr(adapter, dev, event);
> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
> index 13f7705..5b5a0a4 100644
> --- a/drivers/net/usb/cdc_mbim.c
> +++ b/drivers/net/usb/cdc_mbim.c
> @@ -206,7 +206,7 @@ static void do_neigh_solicit(struct usbnet *dev, u8 *buf, u16 tci)
>  	/* need to send the NA on the VLAN dev, if any */
>  	rcu_read_lock();
>  	if (tci) {
> -		netdev = __vlan_find_dev_deep(dev->net, htons(ETH_P_8021Q),
> +		netdev = __vlan_find_dev_deep_rcu(dev->net, htons(ETH_P_8021Q),
>  					      tci);
>  		if (!netdev) {
>  			rcu_read_unlock();
> diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
> index 3524d34..403889a 100644
> --- a/drivers/s390/net/qeth_l3_main.c
> +++ b/drivers/s390/net/qeth_l3_main.c
> @@ -1659,7 +1659,7 @@ static void qeth_l3_add_vlan_mc(struct qeth_card *card)
>  	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
>  		struct net_device *netdev;
>  
> -		netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q),
> +		netdev = __vlan_find_dev_deep_rcu(card->dev, htons(ETH_P_8021Q),
>  					      vid);
>  		if (netdev == NULL ||
>  		    !(netdev->flags & IFF_UP))
> @@ -1721,7 +1721,7 @@ static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
>  	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
>  		struct net_device *netdev;
>  
> -		netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q),
> +		netdev = __vlan_find_dev_deep_rcu(card->dev, htons(ETH_P_8021Q),
>  					      vid);
>  		if (netdev == NULL ||
>  		    !(netdev->flags & IFF_UP))
> @@ -1766,7 +1766,7 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
>  
>  	QETH_CARD_TEXT(card, 4, "frvaddr4");
>  
> -	netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q), vid);
> +	netdev = __vlan_find_dev_deep_rcu(card->dev, htons(ETH_P_8021Q), vid);
>  	if (!netdev)
>  		return;
>  	in_dev = in_dev_get(netdev);
> @@ -1796,7 +1796,7 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
>  
>  	QETH_CARD_TEXT(card, 4, "frvaddr6");
>  
> -	netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q), vid);
> +	netdev = __vlan_find_dev_deep_rcu(card->dev, htons(ETH_P_8021Q), vid);
>  	if (!netdev)
>  		return;
>  	in6_dev = in6_dev_get(netdev);
> @@ -2089,7 +2089,7 @@ static int qeth_l3_verify_vlan_dev(struct net_device *dev,
>  		struct net_device *netdev;
>  
>  		rcu_read_lock();
> -		netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q),
> +		netdev = __vlan_find_dev_deep_rcu(card->dev, htons(ETH_P_8021Q),
>  					      vid);
>  		rcu_read_unlock();
>  		if (netdev == dev) {
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 13bbbde..8c0fb7f 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -106,7 +106,7 @@ struct vlan_pcpu_stats {
>  
>  #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
>  
> -extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
> +extern struct net_device *__vlan_find_dev_deep_rcu(struct net_device *real_dev,
>  					       __be16 vlan_proto, u16 vlan_id);
>  extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
>  extern u16 vlan_dev_vlan_id(const struct net_device *dev);
> @@ -199,7 +199,7 @@ extern void vlan_vids_del_by_dev(struct net_device *dev,
>  extern bool vlan_uses_dev(const struct net_device *dev);
>  #else
>  static inline struct net_device *
> -__vlan_find_dev_deep(struct net_device *real_dev,
> +__vlan_find_dev_deep_rcu(struct net_device *real_dev,
>  		     __be16 vlan_proto, u16 vlan_id)
>  {
>  	return NULL;
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 3c32bd2..9012b1c 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -63,7 +63,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
>  }
>  
>  /* Must be invoked with rcu_read_lock. */
> -struct net_device *__vlan_find_dev_deep(struct net_device *dev,
> +struct net_device *__vlan_find_dev_deep_rcu(struct net_device *dev,
>  					__be16 vlan_proto, u16 vlan_id)
>  {
>  	struct vlan_info *vlan_info = rcu_dereference(dev->vlan_info);
> @@ -81,13 +81,13 @@ struct net_device *__vlan_find_dev_deep(struct net_device *dev,
>  
>  		upper_dev = netdev_master_upper_dev_get_rcu(dev);
>  		if (upper_dev)
> -			return __vlan_find_dev_deep(upper_dev,
> +			return __vlan_find_dev_deep_rcu(upper_dev,
>  						    vlan_proto, vlan_id);
>  	}
>  
>  	return NULL;
>  }
> -EXPORT_SYMBOL(__vlan_find_dev_deep);
> +EXPORT_SYMBOL(__vlan_find_dev_deep_rcu);
>  
>  struct net_device *vlan_dev_real_dev(const struct net_device *dev)
>  {
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 80e1b0f..adc5708 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -535,7 +535,7 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
>  	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
>  		return br;
>  
> -	vlan = __vlan_find_dev_deep(br, skb->vlan_proto,
> +	vlan = __vlan_find_dev_deep_rcu(br, skb->vlan_proto,
>  				    vlan_tx_tag_get(skb) & VLAN_VID_MASK);
>  
>  	return vlan ? vlan : br;
> 
