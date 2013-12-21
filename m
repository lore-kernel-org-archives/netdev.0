From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v3 06/16] i40e: Implementation of vxlan ndo's
Date: Fri, 20 Dec 2013 20:41:05 -0500 (EST)
Message-ID: <20131220.204105.425672139698438176.davem@davemloft.net>
References: <CAJZOPZLScxFtDXLFwUE+S1yRv_VJ2TL5kccA5WU_Jn4ROjdnqw@mail.gmail.com>
	<20131220.164915.1182500137355120095.davem@davemloft.net>
	<alpine.LFD.2.03.1312201504460.25549@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com
To: joseph.gasparakis@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab3LUBlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 20:41:07 -0500
In-Reply-To: <alpine.LFD.2.03.1312201504460.25549@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Date: Fri, 20 Dec 2013 15:25:44 -0800 (PST)

> Right now the code in vxlan.h is:
> 
> #if IS_ENABLED(CONFIG_VXLAN)
> void vxlan_get_rx_port(struct net_device *netdev);
> #else
> static inline void vxlan_get_rx_port(struct net_device *netdev)
> {
> }
> #endif
> 
> so the function can be called from drivers whether vxlan is enabled in 
> .config or not. However, the "depends on VXLAN || !VXLAN" is needed when 
> the driver is compiled as a built-in, otherwise we get an undefined 
> reference for the above function. If this is not the right way to fix the 
> dependency please let me know and I will fix it accordingly.

Ok, can you write this with the more canonical:

	(X || X=n)

That's how we write it out to handle the same issue with
IPV6.

Thanks.
