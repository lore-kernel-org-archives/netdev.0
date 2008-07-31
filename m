From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:42:47 +0100
Message-ID: <1217500967.3454.140.camel@pmac.infradead.org>
References: <20080731092703.661994657@free-electrons.com>
	 <20080731093221.236840420@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, Matt Mackall <mpm@selenic.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35387 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbYGaKmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:42:51 -0400
In-Reply-To: <20080731093221.236840420@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-31 at 11:27 +0200, Thomas Petazzoni wrote:
> 
> +#else
> +static inline u32 ethtool_op_get_link(struct net_device *dev) { return 0; }
> +static inline u32 ethtool_op_get_tx_csum(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_tx_csum(struct net_device *dev, u32 data) { return 0; }
> +static inline int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data) { return 0; }
> +static inline int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_sg(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_sg(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_tso(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_tso(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_ufo(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_ufo(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_flags(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_flags(struct net_device *dev, u32 data) { return 0; }
> +#endif

It's alleged that these functions are called from 'core' network code in
some places, although I can't actually see any evidence of that anywhere
in Linus' tree except for vlans and bridging.

If that's actually the case, perhaps it makes sense to add a
WARN_ON_ONCE() to these empty functions, so that a developer who
disables CONFIG_ETHTOOL when they shouldn't will see a nasty warning
about it rather than a silent failure?

Btw, I see you've made bridging 'select ETHTOOL'; did you do the same
for vlan support?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



