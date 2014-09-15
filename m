From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 5/9] net: pxa168_eth: get and set the mac address on
 the Ethernet controller
Date: Mon, 15 Sep 2014 15:35:45 -0400 (EDT)
Message-ID: <20140915.153545.2175311588825407387.davem@davemloft.net>
References: <1410789713-15341-1-git-send-email-antoine.tenart@free-electrons.com>
	<1410789713-15341-6-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbaIOTfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:35:51 -0400
In-Reply-To: <1410789713-15341-6-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 15 Sep 2014 16:01:49 +0200

> +static void pxa168_eth_get_mac_address(struct net_device *dev,
> +				       unsigned char *addr)
> +{
> +	struct pxa168_eth_private *pep = netdev_priv(dev);
> +	unsigned int mac_h = rdl(pep, MAC_ADDR_HIGH);
> +	unsigned int mac_l = rdl(pep, MAC_ADDR_LOW);
> +
> +	addr[0] = (mac_h >> 24) & 0xff;
> +	addr[1] = (mac_h >> 16) & 0xff;
> +	addr[2] = (mac_h >> 8) & 0xff;
> +	addr[3] = mac_h & 0xff;
> +	addr[4] = (mac_l >> 8) & 0xff;
> +	addr[5] = mac_l & 0xff;
> +}

This function is not used in this patch and thus will result in a compile
warning.

The tree must be fully functional and compile with no new warnings after
each patch in a patch series.

Therefore you must add this new function in the first patch which actually
makes use of the new function.
