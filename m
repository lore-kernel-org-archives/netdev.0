From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.17 4/9] NetXen: intr routines and niu handling
Date: Fri, 18 Aug 2006 08:22:06 -0700
Message-ID: <20060818082206.54f193ff@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.64.0608180713480.6875@dut39>
	<Pine.LNX.4.64.0608180801340.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, sanjeev@netxen.com,
	unmproj@linsyssoft.com, rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21683 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751282AbWHRPWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 11:22:37 -0400
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0608180801340.6875@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> + * netxen_nic_get_stats - Get System Network Statistics
> + * @netdev: network interface device structure
> + */
> +struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
> +{
> +	struct netxen_port *port = netdev_priv(netdev);
> +	struct net_device_stats *stats = &port->net_stats;
> +
> +	memset(stats, 0, sizeof(*stats));
> +
> +	/* total packets received   */
> +	stats->rx_packets = port->stats.no_rcv;
> +	/* total packets transmitted    */
> +	stats->tx_packets = port->stats.xmitedframes + port->stats.xmitfinished;
> +	/* total bytes received     */
> +	stats->rx_bytes = port->stats.rxbytes;
> +	/* total bytes transmitted  */
> +	stats->tx_bytes = port->stats.txbytes;
> +	/* bad packets received     */
> +	stats->rx_errors = port->stats.rcvdbadskb;
> +	/* packet transmit problems */
> +	stats->tx_errors = port->stats.nocmddescriptor;
> +	/* no space in linux buffers    */
> +	stats->rx_dropped = port->stats.updropped;
> +	/* no space available in linux  */
> +	stats->tx_dropped = port->stats.txdropped;
> +
> +	return stats;
> +}

Why keep track of statistics in one structure then copy out to net_device
format? Instead just use original format.

