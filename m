From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH v5 1/2] net: implement mechanism for HW
 based QOS
Date: Thu, 06 Jan 2011 18:20:15 +0000
Message-ID: <1294338015.11825.26.camel@bwh-desktop>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jarkao2@gmail.com, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58893 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab1AFSUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:20:19 -0500
In-Reply-To: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 10:56 -0800, John Fastabend wrote:
[...]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0f6b1c9..ae51323 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -646,6 +646,14 @@ struct xps_dev_maps {
>      (nr_cpu_ids * sizeof(struct xps_map *)))
>  #endif /* CONFIG_XPS */
>  
> +#define TC_MAX_QUEUE	16
> +#define TC_BITMASK	15
> +/* HW offloaded queuing disciplines txq count and offset maps */
> +struct netdev_tc_txq {
> +	u16 count;
> +	u16 offset;
> +};
> +
>  /*
>   * This structure defines the management hooks for network devices.
>   * The following hooks can be defined; unless noted otherwise, they are
> @@ -1146,6 +1154,9 @@ struct net_device {
>  	/* Data Center Bridging netlink ops */
>  	const struct dcbnl_rtnl_ops *dcbnl_ops;
>  #endif
> +	u8 num_tc;
> +	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
> +	u8 prio_tc_map[TC_BITMASK+1];
[...]

I'm still concerned by the addition of all this state to every
net_device.  From previous discussion, Eric wanted this, citing 'false
sharing' while Stephen thought it should be accessed indirectly.

Eric, when you refer to 'false sharing' do you mean that the TC state
might end up sharing a cache line with some other data?  That seems
quite unlikely as the allocation size will be 128 bytes, and it could be
padded to fill a cache line if that's still a concern.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

