From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 27/27] HFI: hf ethtool support
Date: Wed, 02 Mar 2011 21:52:42 +0000
Message-ID: <1299102762.4277.4.camel@localhost>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	 <1299100213-8770-27-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:4138 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756074Ab1CBVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 16:52:50 -0500
In-Reply-To: <1299100213-8770-27-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 16:10 -0500, dykmanj@linux.vnet.ibm.com wrote:
[...]
> +static int hf_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return ARRAY_SIZE(hf_ethtool_stats_keys);
> +	default:
> +		return -EOPNOTSUPP;

The error code should be -EINVAL, I think.

> +	}
> +}
> +
> +static void hf_get_ethtool_stats(struct net_device *netdev,
> +		struct ethtool_stats *stats, u64 *data)
> +{
> +	struct hf_net	*net = netdev_priv(netdev);
> +	struct hf_if	*net_if = &(net->hfif);
> +
> +	memcpy(data, &(net_if->eth_stats), sizeof(struct hf_ethtool_stats));
[...]

This may result in word tearing, particularly if this driver can be
built for a 32-bit system.  Since the stats appear to be updated
asynchronously in the data path, you may have to declare them as
unsigned long and then extend them to 64-bit in hf_get_ethtool_stats().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

