From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 13:44:30 +0400
Message-ID: <20070711094430.GA9672@2ka.mipt.ru>
References: <4694A363.2070406@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44690 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760466AbXGKJog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 05:44:36 -0400
Content-Disposition: inline
In-Reply-To: <4694A363.2070406@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Wed, Jul 11, 2007 at 01:31:15PM +0400, Pavel Emelianov (xemul@openvz.org) wrote:
> Veth stands for Virtual ETHernet. It is a simple tunnel driver
> that works at the link layer and looks like a pair of ethernet
> devices interconnected with each other.
> 
> Mainly it allows to communicate between network namespaces but
> it can be used as is as well.

I have minor comment about flags used in veth. It looks like you only
set LLTX bit, but check for other flags in the code, so why not to
include another performance features?

> +static void veth_setup(struct net_device *dev)
> +{
> +	ether_setup(dev);
> +
> +	dev->hard_start_xmit = veth_xmit;
> +	dev->get_stats = veth_get_stats;
> +	dev->open = veth_open;
> +	dev->stop = veth_close;
> +	dev->ethtool_ops = &veth_ethtool_ops;
> +	dev->features |= NETIF_F_LLTX;
> +	dev->init = veth_dev_init;
> +	dev->destructor = veth_dev_free;
> +	netif_carrier_off(dev);
> +}

Don't you want to include NETIF_F_SG, NETIF_F_NO_CSUM, NETIF_F_FRAGLIST,
NETIF_F_HIGHDMA and probably TSO fancy flags also to reduce cpu usage more?

-- 
	Evgeniy Polyakov
