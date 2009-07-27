From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in
 network devices
Date: Sun, 26 Jul 2009 18:02:54 -0700 (PDT)
Message-ID: <20090726.180254.202825489.davem@davemloft.net>
References: <20090727003609.GA30438@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752187AbZG0BCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 21:02:47 -0400
In-Reply-To: <20090727003609.GA30438@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Sun, 26 Jul 2009 20:36:09 -0400

> 	Since Network devices dma their memory into a provided DMA
> buffer (which can usually be at an arbitrary location, as they must
> cross potentially several pci busses to reach any memory location),
> I'm postulating that it would increase our receive path efficiency
> to provide a hint to the driver layer as to which node to allocate
> an skb data buffer on.  This hint would be determined by a feedback
> mechanism.  I was thinking that we could provide a callback function
> via the skb, that accepted the skb and the originating net_device.
> This callback can track statistics on which numa nodes consume
> (read: copy data from) skbs that were produced by specific net
> devices.  Then, when in the future that netdevice allocates a new
> skb (perhaps via netdev_alloc_skb), we can use that statistical
> profile to determine if the data buffer should be allocated on the
> local node, or on a remote node instead.

No matter what, you will do an inter-node memory operation.

Unless, the consumer NUMA node is the same as the one the
device is on.

Because since the device is on a NUMA node, if you DMA remotely
you've eaten the NUMA cost already.

If you always DMA to the device's NUMA node (what we try to do now) at
least the is the possibility of eliminating cross-NUMA traffic.

Better to move the application or stack processing towards the NUMA
node the network device is on, I think.
