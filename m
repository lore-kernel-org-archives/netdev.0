From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Tue, 07 Oct 2014 12:05:34 -0400 (EDT)
Message-ID: <20141007.120534.1798634446901746809.davem@davemloft.net>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
	<CA+FuTSfwTBtZLu7CXh4bPxUtVubOvpCPo+O38BsnSiLdvV_KEA@mail.gmail.com>
	<DFDF335405C17848924A094BC35766CF0A953308@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, john.fastabend@gmail.com, dborkman@redhat.com,
	fw@strlen.de, gerlitz.or@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com
To: danny.zhou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314AbaJGQFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:05:39 -0400
In-Reply-To: <DFDF335405C17848924A094BC35766CF0A953308@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zhou, Danny" <danny.zhou@intel.com>
Date: Tue, 7 Oct 2014 15:21:15 +0000

> Once qpairs split-off is done, the user space driver, as a slave
> driver, will re-initialize those queues completely in user space by
> using paddr(in the case of DPDK, vaddr of DPDK used huge pages are
> translated to paddr) to fill in the packet descriptors.  As of
> security concern raised in previous discussion, the reason we
> think(BTW, correct me if I am wrong) af_packet is most suitable is
> because only user application with root permission is allowed to
> successfully split-off queue pairs and mmap a small window of PCIe
> I/O space to user space, so concern regarding "device can DMA
> from/to any arbitrary physical memory." is not that big. As all user
> space device drivers based on UIO mechanism has the same concern
> issue, VFIO adds protection but it is based on IOMMU which is
> specific to Intel silicons.

Wait a second.

If there is no memory protection performed I'm not merging this.

I thought the user has to associate a fixed pool of memory to the
queueus, the kernel attaches that memory, and then the user cannot
modify the addresses _AT_ _ALL_.

If the user can modify the addresses in the descriptors and make
the chip crap on random memory, this is a non-starter.

Sorry.
