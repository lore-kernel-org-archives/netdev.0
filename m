From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 04/14] net: add ndo_fcoe_ddp_target() to support
 FCoE DDP in target mode
Date: Tue, 08 Mar 2011 02:43:22 +0000
Message-ID: <1299552202.3967.2.camel@localhost>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1299551108-23663-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Yi Zou <yi.zou@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Kiran Patil <kiran.patil@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16245 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab1CHCn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 21:43:29 -0500
In-Reply-To: <1299551108-23663-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-07 at 18:24 -0800, Jeff Kirsher wrote:
> From: Yi Zou <yi.zou@intel.com>
> 
> The Fiber Channel over Ethernet (FCoE) Direct Data Placement (DDP) can also be
> used for FCoE target, where the DDP used for read I/O on an initiator can be
> used on an FCoE target to speed up the write I/O to the target from the initiator.
> The added ndo_fcoe_ddp_target() works in the similar way as the existing
> ndo_fcoe_ddp_setup() to allow the underlying hardware set up the DDP context
> accordingly when it gets called from the FCoE target implementation on top
> the existing Open-FCoE fcoe/libfc protocol stack so without losing the ability
> to provide DDP for read I/O as an initiator, it can also provide DDP offload
> to the write I/O coming from the initiator as a target.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  include/linux/netdevice.h |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 71563e7..6bd5d46 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -871,6 +871,10 @@ struct net_device_ops {
>  						      unsigned int sgc);
>  	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
>  						     u16 xid);
> +	int			(*ndo_fcoe_ddp_target)(struct net_device *dev,
> +						       u16 xid,
> +						       struct scatterlist *sgl,
> +						       unsigned int sgc);

This should be described in the comment heading net_device_ops.
(Really, all the existing FCoE operations ought to have been described
as well.)

Ben.

>  #define NETDEV_FCOE_WWNN 0
>  #define NETDEV_FCOE_WWPN 1
>  	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

