From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] igb: Expose RSS indirection table for ethtool
Date: Fri, 2 Aug 2013 13:52:44 +0200
Message-ID: <1375444364.24371.30.camel@deadeye.wl.decadent.org.uk>
References: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
	 <1375260212-19351-2-git-send-email-laura.vasilescu@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <carolyn.wyborny@intel.com>,
	<anjali.singhai@intel.com>, <jeffrey.t.kirsher@intel.com>,
	<alexander.h.duyck@intel.com>
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24755 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab3HBLwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 07:52:49 -0400
In-Reply-To: <1375260212-19351-2-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 11:43 +0300, Laura Mihaela Vasilescu wrote:
[...]
> +static int igb_set_rxfh_indir(struct net_device *netdev, const u32 *indir)
> +{
> +	struct igb_adapter *adapter = netdev_priv(netdev);
> +	struct e1000_hw *hw = &adapter->hw;
> +	int i;
> +	u32 num_queues;
> +
> +	num_queues = adapter->rss_queues;
> +
> +	switch (hw->mac.type) {
> +	case e1000_82576:
> +		/* 82576 supports 2 RSS queues for SR-IOV */
> +		if (adapter->vfs_allocated_count)
> +			num_queues = 2;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	/* Verify user input. */
> +	for (i = 0; i < IGB_RETA_SIZE; i++)
> +		if (indir[i] > num_queues)
> +			return -EINVAL;
[...]

Surely the comparison should be >= ?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
