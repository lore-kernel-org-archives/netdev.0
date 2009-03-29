From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ni5010: convert to net_device_ops
Date: Sat, 28 Mar 2009 19:36:04 -0700 (PDT)
Message-ID: <20090328.193604.230866790.davem@davemloft.net>
References: <20090329022613.GA30897@orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756239AbZC2CgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:36:16 -0400
In-Reply-To: <20090329022613.GA30897@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Sun, 29 Mar 2009 06:26:13 +0400

> @@ -189,6 +189,14 @@ static void __init trigger_irq(int ioaddr)
>  		outb(MM_EN_XMT|MM_MUX, IE_MMODE); /* Start transmission */
>  }
>  
> +static const struct net_device_ops ni5010_netdev_ops = {
> +	.ndo_open		= ni5010_open,
> +	.ndo_stop		= ni5010_close,
> +	.ndo_start_xmit		= ni5010_send_packet,
> +	.ndo_set_multicast_list	= ni5010_set_multicast_list,
> +	.ndo_tx_timeout		= ni5010_timeout,
> +};

Missing:

	.ndo_change_mtu		= eth_change_mtu,
	.ndo_set_mac_address 	= eth_mac_addr,
	.ndo_validate_addr	= eth_validate_addr,

as would have been initialized to dev->foo by alloc_etherdev().
