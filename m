From: Joe Eykholt <jeykholt@cisco.com>
Subject: Re: [net-next-2.6 PATCH 4/4] vlan: Add support to	netdev_ops.ndo_fcoe_get_wwn
 for VLAN device
Date: Wed, 28 Oct 2009 22:00:12 -0700
Message-ID: <4AE9215C.2020208@cisco.com>
References: <20091029042339.15957.37676.stgit@localhost.localdomain> <20091029042515.15957.86107.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, Yi Zou <yi.zou@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091029042515.15957.86107.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:
> From: Yi Zou <yi.zou@intel.com>
> 
> Implements the netdev_ops.ndo_fcoe_get_wwn for VLAN device.

How would this arrange for different VLANs to get different WWPNs?
Or does it allow FCoE only on one VLAN per port?
I guess that would be fair because some switches support only one FCoE VLAN.

	Regards,
	Joe

> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  net/8021q/vlan_dev.c |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index e370197..790fd55 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -626,6 +626,17 @@ static int vlan_dev_fcoe_disable(struct net_device *dev)
>  		rc = ops->ndo_fcoe_disable(real_dev);
>  	return rc;
>  }
> +
> +static int vlan_dev_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
> +{
> +	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
> +	const struct net_device_ops *ops = real_dev->netdev_ops;
> +	int rc = -EINVAL;
> +
> +	if (ops->ndo_fcoe_get_wwn)
> +		rc = ops->ndo_fcoe_get_wwn(real_dev, wwn, type);
> +	return rc;
> +}
>  #endif
>  
>  static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
> @@ -791,6 +802,7 @@ static const struct net_device_ops vlan_netdev_ops = {
>  	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
>  	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
>  	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
> +	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
>  #endif
>  };
>  
> @@ -813,6 +825,7 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
>  	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
>  	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
>  	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
> +	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
>  #endif
>  };
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
