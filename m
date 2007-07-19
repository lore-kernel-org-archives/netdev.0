From: Ragner Magalhaes <ragner.magalhaes@indt.org.br>
Subject: Re: [PATCH 2/4] ibmveth: Implement ethtool hooks to enable/disable
 checksum offload
Date: Thu, 19 Jul 2007 12:08:32 -0400
Message-ID: <469F8C80.7070302@indt.org.br>
References: <1184860086366-patch-mail.ibm.com> <200707191548.l6JFmEYM020387@d03av04.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: ext Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([131.228.20.172]:44834 "EHLO
	mgw-ext13.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S940244AbXGSQ41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:56:27 -0400
In-Reply-To: <200707191548.l6JFmEYM020387@d03av04.boulder.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ext Brian King wrote:

> +
> +static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
> +{
> +	struct ibmveth_adapter *adapter = dev->priv;
> +

Why do not to do

	if ((data && adapter->rx_csum) || (!data && !adapter->rx_csum))
		return 0;
less two lines.

> +	if (data && adapter->rx_csum)
> +		return 0;
> +	if (!data && !adapter->rx_csum)
> +		return 0;
> +
> +	return ibmveth_set_csum_offload(dev, data, ibmveth_set_rx_csum_flags);
> +}
> +
> +static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
> +{
> +	struct ibmveth_adapter *adapter = dev->priv;
> +	int rc = 0;
> +

here also, as above ...
> +	if (data && (dev->features & NETIF_F_IP_CSUM))
> +		return 0;
> +	if (!data && !(dev->features & NETIF_F_IP_CSUM))
> +		return 0;
> +
> +	if (data && !adapter->rx_csum)
> +		rc = ibmveth_set_csum_offload(dev, data, ibmveth_set_tx_csum_flags);
> +	else
> +		ibmveth_set_tx_csum_flags(dev, data);
> +
> +	return rc;
> +}
> +
Best regards,
Ragner
