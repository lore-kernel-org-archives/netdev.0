From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 3/3] liquidio: ethtool support for switchdev
 ports
Date: Thu, 26 Oct 2017 15:03:33 -0700
Message-ID: <20171026150333.7aa11cc3@cakuba.netronome.com>
References: <20171026053641.GA17861@felix-thinkpad.cavium.com>
        <20171026053735.GA17901@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:51490 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdJZWDk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 18:03:40 -0400
Received: by mail-wm0-f46.google.com with SMTP id b9so246833wmh.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 15:03:39 -0700 (PDT)
In-Reply-To: <20171026053735.GA17901@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Oct 2017 22:37:35 -0700, Felix Manlunas wrote:
> +static const char lio_vf_rep_stats_strings[][ETH_GSTRING_LEN] = {
> +	"rx_packets",
> +	"tx_packets",
> +	"rx_bytes",
> +	"tx_bytes",
> +	"rx_dropped",
> +	"tx_dropped",
> +};
> +
> [...]
> +
> +static void
> +lio_vf_rep_get_ethtool_stats(struct net_device *ndev,
> +			     struct ethtool_stats *stats,
> +			     u64 *data)
> +{
> +	struct rtnl_link_stats64 *stats_ptr, net_stats;
> +	int i = 0;
> +
> +	stats_ptr = dev_get_stats(ndev, &net_stats);
> +
> +	data[i++] = stats_ptr->rx_packets;
> +	data[i++] = stats_ptr->tx_packets;
> +	data[i++] = stats_ptr->rx_bytes;
> +	data[i++] = stats_ptr->tx_bytes;
> +	data[i++] = stats_ptr->rx_dropped;
> +	data[i++] = stats_ptr->tx_dropped;
> +}

Duplicating basic netdev stats in ethtool is discouraged these days.
