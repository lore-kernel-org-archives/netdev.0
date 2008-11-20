From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v3 PATCH 1/5] ixgbe: this patch adds support for DCB
 to the kernel and ixgbe driver
Date: Thu, 20 Nov 2008 00:44:00 -0800 (PST)
Message-ID: <20081120.004400.244258277.davem@davemloft.net>
References: <20081118010033.7105.88061.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752902AbYKTIoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:44:00 -0500
In-Reply-To: <20081118010033.7105.88061.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Nov 2008 17:00:43 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This adds support for Data Center Bridging (DCB) features in the ixgbe driver and adds an rtnetlink interface for configuring DCB to the kernel.  The DCB feature support included are Priority Grouping (PG) - which allows bandwidth guarantees to be allocated to groups to traffic based on the 802.1q priority, and Priority Based Flow Control (PFC) - which introduces a new MAC control PAUSE frame which works at granularity of the 802.1p priority instead of the link (IEEE 802.3x).
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

I appreciate your effort Jeff, but the idea was to minimize the
number of ifdefs in *.c files, not increase them.

Please make it so that stuff like this isn't scattered all over existing
driver source files.

> @@ -2271,15 +2333,39 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
>  {
>  	int nrq = 1, ntq = 1;
>  	int feature_mask = 0, rss_i, rss_m;
> +#ifdef CONFIG_IXGBE_DCBNL
> +	int dcb_i, dcb_m;
> +#endif
>  
>  	/* Number of supported queues */
>  	switch (adapter->hw.mac.type) {
>  	case ixgbe_mac_82598EB:

And all of the cases like the following is really needing a fixup:

> +#ifdef CONFIG_IXGBE_DCBNL
> +static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
> +#else
>  static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
> +#endif

Thanks :-)
