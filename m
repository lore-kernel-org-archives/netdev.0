From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] net driver fixes
Date: Sat, 8 Nov 2003 12:27:48 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031108172748.GA8186@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: torvalds@osdl.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


Linus, please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.5

This will update the following files:

 drivers/net/b44.c     |   56 ++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/pcnet32.c |    4 +++
 2 files changed, 58 insertions(+), 2 deletions(-)

through these ChangeSets:

<ralf@linux-mips.org> (03/11/08 1.1416)
   [netdrvr pcnet32] add missing pci_dma_sync_single
   
   a patch for the pcnet32.c driver which adds a missing call to
   pci_dma_sync_single.  If a received packet is smaller than rx_copybreak
   the pcnet driver will recycle the receive buffer which requires calling
   pci_dma_sync_single.  Patch is against 2.6 but I it's also needed in 2.4.
   
   Without that call the processor might still have old stale data in
   the data cache when the processor accesses the recycled buffer.
   

<pp@ee.oulu.fi> (03/11/08 1.1415)
   [netdrvr b44] Fix irq enable/disable; fix oops due to lack of SET_NETDEV_DEV() call
   
   Also, add suspend/resume functions.
