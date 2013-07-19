From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net: enic: Move ethtool code to a
 separate file
Date: Fri, 19 Jul 2013 13:38:12 -0700
Message-ID: <1374266292.2059.11.camel@joe-AO722>
References: <20130719202817.13313.56725.stgit@savbu-picasso-lnx1.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neel Patel <neepatel@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33057 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751518Ab3GSUiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jul 2013 16:38:14 -0400
In-Reply-To: <20130719202817.13313.56725.stgit@savbu-picasso-lnx1.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-19 at 13:28 -0700, Neel Patel wrote:
> From: Neel Patel <neepatel@cisco.com>

Hi Neel.

> This patch moves all enic ethtool hooks from enic_main.c to a new file
> enic_ethtool.c

These comments aren't for new issues and are trivial.

> diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
[]
> +struct enic_stat {
> +	char name[ETH_GSTRING_LEN];
> +	unsigned int offset;
> +};

Offset is really an index, so use index

> +#define ENIC_TX_STAT(stat)	\
> +	{ .name = #stat, .offset = offsetof(struct vnic_tx_stats, stat) / 8 }
> +#define ENIC_RX_STAT(stat)	\
> +	{ .name = #stat, .offset = offsetof(struct vnic_rx_stats, stat) / 8 }

index = offsetof(struct, stat) / sizeof(struct.stat)
to avoid use of 8?

> +static void enic_get_ethtool_stats(struct net_device *netdev,
> +	struct ethtool_stats *stats, u64 *data)
> +{
[]
> +	for (i = 0; i < enic_n_tx_stats; i++)
> +		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].offset];
> +	for (i = 0; i < enic_n_rx_stats; i++)
> +		*(data++) = ((u64 *)&vstats->rx)[enic_rx_stats[i].offset];

s/offset/index/ ?
