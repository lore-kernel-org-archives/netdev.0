From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 05/14] vlan: add support to ndo_fcoe_ddp_target()
Date: Tue, 08 Mar 2011 02:44:27 +0000
Message-ID: <1299552267.3967.3.camel@localhost>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1299551108-23663-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Yi Zou <yi.zou@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Kiran Patil <kiran.patil@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16285 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab1CHCob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 21:44:31 -0500
In-Reply-To: <1299551108-23663-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-07 at 18:24 -0800, Jeff Kirsher wrote:
> From: Yi Zou <yi.zou@intel.com>
> 
> Add the new target ddp offload support ndo_fcoe_ddp_target().
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  net/8021q/vlan_dev.c |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index be73753..ae610f0 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -625,6 +625,19 @@ static int vlan_dev_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
>  		rc = ops->ndo_fcoe_get_wwn(real_dev, wwn, type);
>  	return rc;
>  }
> +
> +static int vlan_dev_fcoe_ddp_target(struct net_device *dev, u16 xid,
> +				    struct scatterlist *sgl, unsigned int sgc)
> +{
> +	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
> +	const struct net_device_ops *ops = real_dev->netdev_ops;
> +	int rc = 0;
> +
> +	if (ops->ndo_fcoe_ddp_target)
> +		rc = ops->ndo_fcoe_ddp_target(real_dev, xid, sgl, sgc);
> +
> +	return rc;
> +}

I can't see a caller or any documentation for this operation, so I don't
know what the semantics are supposed to be.  But shouldn't the return
value be -EOPNOTSUPP if real_dev does not implement the operation?

Ben.

>  #endif
>  
>  static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
> @@ -858,6 +871,7 @@ static const struct net_device_ops vlan_netdev_ops = {
>  	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
>  	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
>  	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
> +	.ndo_fcoe_ddp_target	= vlan_dev_fcoe_ddp_target,
>  #endif
>  };
>  

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

