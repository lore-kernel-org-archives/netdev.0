From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v3 03/17] net: rename netdev_phys_port_id to
 more generic name
Date: Tue, 25 Nov 2014 10:15:03 -0500
Message-ID: <20141125151503.GD27416@gospo.rtplab.test>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37152 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaKYPPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:15:19 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 11:28:34AM +0100, Jiri Pirko wrote:
> So this can be reused for identification of other "items" as well.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Reviewed-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Still seems fine for v3.  :-)

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
> v1->v2->v3:
> -no change
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 +-
>  drivers/net/ethernet/intel/i40e/i40e_main.c      |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  2 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  2 +-
>  include/linux/netdevice.h                        | 16 ++++++++--------
>  net/core/dev.c                                   |  2 +-
>  net/core/net-sysfs.c                             |  2 +-
>  net/core/rtnetlink.c                             |  6 +++---
>  8 files changed, 17 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index c4bd025..336ef3c 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -12537,7 +12537,7 @@ static int bnx2x_validate_addr(struct net_device *dev)
>  }
>  
>  static int bnx2x_get_phys_port_id(struct net_device *netdev,
> -				  struct netdev_phys_port_id *ppid)
> +				  struct netdev_phys_item_id *ppid)
>  {
>  	struct bnx2x *bp = netdev_priv(netdev);
>  
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 5ed5e40..9ae4270 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -7511,7 +7511,7 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
>  
>  #endif
>  static int i40e_get_phys_port_id(struct net_device *netdev,
> -				 struct netdev_phys_port_id *ppid)
> +				 struct netdev_phys_item_id *ppid)
>  {
>  	struct i40e_netdev_priv *np = netdev_priv(netdev);
>  	struct i40e_pf *pf = np->vsi->back;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index b7c9978..1597fb0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2259,7 +2259,7 @@ static int mlx4_en_set_vf_link_state(struct net_device *dev, int vf, int link_st
>  
>  #define PORT_ID_BYTE_LEN 8
>  static int mlx4_en_get_phys_port_id(struct net_device *dev,
> -				    struct netdev_phys_port_id *ppid)
> +				    struct netdev_phys_item_id *ppid)
>  {
>  	struct mlx4_en_priv *priv = netdev_priv(dev);
>  	struct mlx4_dev *mdev = priv->mdev->dev;
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 3227c80..1aa25b1 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -461,7 +461,7 @@ static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
>  }
>  
>  static int qlcnic_get_phys_port_id(struct net_device *netdev,
> -				   struct netdev_phys_port_id *ppid)
> +				   struct netdev_phys_item_id *ppid)
>  {
>  	struct qlcnic_adapter *adapter = netdev_priv(netdev);
>  	struct qlcnic_hardware_context *ahw = adapter->ahw;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index fab074e..5b491b3 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -754,13 +754,13 @@ struct netdev_fcoe_hbainfo {
>  };
>  #endif
>  
> -#define MAX_PHYS_PORT_ID_LEN 32
> +#define MAX_PHYS_ITEM_ID_LEN 32
>  
> -/* This structure holds a unique identifier to identify the
> - * physical port used by a netdevice.
> +/* This structure holds a unique identifier to identify some
> + * physical item (port for example) used by a netdevice.
>   */
> -struct netdev_phys_port_id {
> -	unsigned char id[MAX_PHYS_PORT_ID_LEN];
> +struct netdev_phys_item_id {
> +	unsigned char id[MAX_PHYS_ITEM_ID_LEN];
>  	unsigned char id_len;
>  };
>  
> @@ -976,7 +976,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
>   *
>   * int (*ndo_get_phys_port_id)(struct net_device *dev,
> - *			       struct netdev_phys_port_id *ppid);
> + *			       struct netdev_phys_item_id *ppid);
>   *	Called to get ID of physical port of this device. If driver does
>   *	not implement this, it is assumed that the hw is not able to have
>   *	multiple net devices on single physical port.
> @@ -1152,7 +1152,7 @@ struct net_device_ops {
>  	int			(*ndo_change_carrier)(struct net_device *dev,
>  						      bool new_carrier);
>  	int			(*ndo_get_phys_port_id)(struct net_device *dev,
> -							struct netdev_phys_port_id *ppid);
> +							struct netdev_phys_item_id *ppid);
>  	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
>  						      sa_family_t sa_family,
>  						      __be16 port);
> @@ -2866,7 +2866,7 @@ void dev_set_group(struct net_device *, int);
>  int dev_set_mac_address(struct net_device *, struct sockaddr *);
>  int dev_change_carrier(struct net_device *, bool new_carrier);
>  int dev_get_phys_port_id(struct net_device *dev,
> -			 struct netdev_phys_port_id *ppid);
> +			 struct netdev_phys_item_id *ppid);
>  struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
>  struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  				    struct netdev_queue *txq, int *ret);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ac48362..0814a56 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5846,7 +5846,7 @@ EXPORT_SYMBOL(dev_change_carrier);
>   *	Get device physical port ID
>   */
>  int dev_get_phys_port_id(struct net_device *dev,
> -			 struct netdev_phys_port_id *ppid)
> +			 struct netdev_phys_item_id *ppid)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 1a24602..26c46f4 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -404,7 +404,7 @@ static ssize_t phys_port_id_show(struct device *dev,
>  		return restart_syscall();
>  
>  	if (dev_isalive(netdev)) {
> -		struct netdev_phys_port_id ppid;
> +		struct netdev_phys_item_id ppid;
>  
>  		ret = dev_get_phys_port_id(netdev, &ppid);
>  		if (!ret)
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index f2a4b38..0fb3a68 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -869,7 +869,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>  	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>  	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> -	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
> +	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
>  }
>  
>  static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
> @@ -953,7 +953,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev,
>  static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
>  {
>  	int err;
> -	struct netdev_phys_port_id ppid;
> +	struct netdev_phys_item_id ppid;
>  
>  	err = dev_get_phys_port_id(dev, &ppid);
>  	if (err) {
> @@ -1197,7 +1197,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>  	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
>  	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
>  	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
> -	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
> +	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>  	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
>  };
>  
> -- 
> 1.9.3
> 
