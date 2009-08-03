From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 6/7] net: Add vbus_enet driver
Date: Mon, 3 Aug 2009 11:30:30 -0700
Message-ID: <20090803113030.3092d5b0@nehalam>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
	<20090803171801.17268.93846.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46131 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727AbZHCSaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 14:30:35 -0400
In-Reply-To: <20090803171801.17268.93846.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Aug 2009 13:18:02 -0400
Gregory Haskins <ghaskins@novell.com> wrote:

> +
> +static const struct net_device_ops vbus_enet_netdev_ops = {
> +	.ndo_open          = vbus_enet_open,
> +	.ndo_stop          = vbus_enet_stop,
> +	.ndo_set_config    = vbus_enet_config,
> +	.ndo_start_xmit    = vbus_enet_tx_start,
> +	.ndo_change_mtu	   = vbus_enet_change_mtu,
> +	.ndo_tx_timeout    = vbus_enet_timeout,
> +};


Missing 
	.ndo_set_mac_address = eth_mac_addr,
	.ndo_validate_addr   = eth_validate_addr,

Also, should have change_mtu.

Suggest adding ethtool to report link and settings.

For performance this device should do scatter/gather, tso, gso, etc.
