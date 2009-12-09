From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ixgbe: Fix TX stats accounting
Date: Tue, 08 Dec 2009 20:10:43 -0800 (PST)
Message-ID: <20091208.201043.00804865.davem@davemloft.net>
References: <20091208172125.19464.29177.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, eric.dumazet@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756647AbZLIEKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:10:38 -0500
In-Reply-To: <20091208172125.19464.29177.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 08 Dec 2009 09:22:03 -0800

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Here is an updated version, because ixgbe_get_ethtool_stats()
> needs to call dev_get_stats() or "ethtool -S" wont give
> correct tx_bytes/tx_packets values.
> 
> Several cpus can update netdev->stats.tx_bytes & netdev->stats.tx_packets
> in parallel. In this case, TX stats are under estimated and false sharing
> takes place.
> 
> After a pktgen session sending exactly 200000000 packets :
> # ifconfig fiber0 | grep TX
>           TX packets:198501982 errors:0 dropped:0 overruns:0 carrier:0
> 
> 
> Multi queue devices should instead use txq->tx_bytes & txq->tx_packets
> in their xmit() method (appropriate txq lock already held by caller, no
> cache line miss), or use appropriate locking.
> 
> After patch, same pktgen session gives :
> 
> # ifconfig fiber0 | grep TX
>           TX packets:200000000 errors:0 dropped:0 overruns:0 carrier:0
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
