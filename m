From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:05:19 -0800
Message-ID: <20141218230519.2c2a3717@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42578 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbaLSHFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:05:30 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so633341pab.5
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:05:30 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +static void
> +lio_get_ethtool_stats(struct net_device *netdev,
> +		      struct ethtool_stats *stats, u64 *data)
> +{
> +	struct lio *lio = GET_LIO(netdev);
> +	struct octeon_device *oct_dev = lio->oct_dev;
> +	int i = 0, j;
> +
> +	data[i++] = jiffies;
> +	data[i++] = lio->stats.tx_packets;
> +	data[i++] = lio->stats.tx_bytes;
> +	data[i++] = lio->stats.rx_packets;
> +	data[i++] = lio->stats.rx_bytes;
> +	data[i++] = lio->stats.tx_errors;
> +	data[i++] = lio->stats.tx_dropped;
> +	data[i++] = lio->stats.rx_dropped;
> +

Do not mirror existing netdevice statistics in ethtool.
The purpose of ethtool stats is to provide device specific information.
