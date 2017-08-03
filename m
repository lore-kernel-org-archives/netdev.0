From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 4/4] ibmvnic: Implement .get_channels
Date: Wed, 2 Aug 2017 20:07:42 -0700
Message-ID: <20170802200742.065bb833@xeon-e3>
References: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
        <68feac4e-73d3-a689-6199-d42c72785c14@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: John Allen <jallen@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35758 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdHCDHp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 23:07:45 -0400
Received: by mail-pg0-f49.google.com with SMTP id v189so876067pgd.2
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 20:07:45 -0700 (PDT)
In-Reply-To: <68feac4e-73d3-a689-6199-d42c72785c14@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Aug 2017 16:47:17 -0500
John Allen <jallen@linux.vnet.ibm.com> wrote:

> +static void ibmvnic_get_channels(struct net_device *netdev,
> +				 struct ethtool_channels *channels)
> +{
> +	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
> +
> +	channels->max_rx = adapter->max_rx_queues;
> +	channels->max_tx = adapter->max_tx_queues;
> +	channels->max_other = 0;
> +	channels->max_combined = 0;
> +	channels->rx_count = adapter->req_rx_queues;
> +	channels->tx_count = adapter->req_tx_queues;
> +	channels->other_count = 0;
> +	channels->combined_count = 0;
> +}

Minor nit, since the structure is already initialized to zero by caller,
you don't need to fill in the values that are zero.

static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
						   void __user *useraddr)
{
	struct ethtool_channels channels = { .cmd = ETHTOOL_GCHANNELS };  << all unspecifed fields are zero'd

	if (!dev->ethtool_ops->get_channels)
		return -EOPNOTSUPP;

	dev->ethtool_ops->get_channels(dev, &channels);
