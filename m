From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 6/8] qlcnic: add driver debug support
Date: Thu, 01 Apr 2010 16:02:17 -0700 (PDT)
Message-ID: <20100401.160217.56174682.davem@davemloft.net>
References: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
	<1270037026-9062-7-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48803
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756638Ab0DAXCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 19:02:16 -0400
In-Reply-To: <1270037026-9062-7-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed, 31 Mar 2010 05:03:44 -0700

> @@ -998,6 +998,20 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
>  	return 0;
>  }
>  
> +static u32 qlcnic_get_msglevel(struct net_device *netdev)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(netdev);
> +
> +	return adapter->msglvl;
> +}
> +
> +static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(netdev);
> +
> +	adapter->msglvl = !!msglvl;
> +}
> +

The values used by these interfaces are not something you
can interpret any way you want.

They have defined values (from linux/netdevice.h):

enum {
	NETIF_MSG_DRV		= 0x0001,
	NETIF_MSG_PROBE		= 0x0002,
	NETIF_MSG_LINK		= 0x0004,
	NETIF_MSG_TIMER		= 0x0008,
	NETIF_MSG_IFDOWN	= 0x0010,
	NETIF_MSG_IFUP		= 0x0020,
	NETIF_MSG_RX_ERR	= 0x0040,
	NETIF_MSG_TX_ERR	= 0x0080,
	NETIF_MSG_TX_QUEUED	= 0x0100,
	NETIF_MSG_INTR		= 0x0200,
	NETIF_MSG_TX_DONE	= 0x0400,
	NETIF_MSG_RX_STATUS	= 0x0800,
	NETIF_MSG_PKTDATA	= 0x1000,
	NETIF_MSG_HW		= 0x2000,
	NETIF_MSG_WOL		= 0x4000,
};

And you must respect them in your debug logging macros.

You should also use netdev->msg_enable which is there exactly
for this purpose, and then you can use the netif_msg_*()
helper macros.

Look at how any other driver implements these interfaces.  It's always
better to look at the most popular drivers to see how interfaces are
meant to be used, rather than looking at an interface and trying
to figure out what clever things specific to your driver you can
do with it. :-)

Please either fix this up or eliminate this patch from your
patch set.  Please resubmit this entire set once you've
fixed this problem.

Thanks.
