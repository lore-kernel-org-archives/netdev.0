From: Jeff Garzik <jgarzik@pobox.com>
Subject: [bk] 2.6.x net driver queue snapshot
Date: Tue, 26 Aug 2003 16:51:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826205136.GA32063@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Snapshot of the current 2.6.x net driver queue.

Notably, collects sis190 fixes.


BK users:

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.6
		or
	bk pull http://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/3c501.c      |   91 +--------
 drivers/net/3c501.h      |    2 
 drivers/net/3c503.c      |   71 +------
 drivers/net/3c505.c      |   96 ++--------
 drivers/net/3c507.c      |   97 ++--------
 drivers/net/3c515.c      |   94 ++-------
 drivers/net/3c523.c      |   73 +------
 drivers/net/3c527.c      |   94 ++-------
 drivers/net/3c59x.c      |   47 +---
 drivers/net/8139cp.c     |  444 ++++++++++++++++++-----------------------------
 drivers/net/Kconfig      |    2 
 drivers/net/sis190.c     |   79 +++++---
 drivers/net/sis900.c     |   43 +---
 drivers/net/tulip/dmfe.c |   62 +-----
 14 files changed, 393 insertions(+), 902 deletions(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/08/26 1.1301)
   [netdrvr] ethtool_ops support for 3c515, 3c523, 3c527, and dmfe

<jgarzik@redhat.com> (03/08/26 1.1300)
   [netdrvr] ethtool_ops support in 3c503, 3c505, 3c507

<jgarzik@redhat.com> (03/08/26 1.1299)
   [netdrvr 3c501] ethtool_ops support

<jgarzik@redhat.com> (03/08/26 1.1298)
   [netdrvr sis190] make driver depend on CONFIG_BROKEN
   
   Until RX path is cleaned up to use PCI DMA API and
   not virt_to_bus.

<jgarzik@redhat.com> (03/08/26 1.1297)
   [netdrvr sis190] convert TX path to use PCI DMA API
   
   Also, minor changes:
   * mark ->hard_start_xmit ETH_ZLEN test as unlikely()
   * use cpu_to_le32() and le32_to_cpu() in TX path
   * fix two leak in error path, in ->hard_start_xmit
   * don't test netif_queue_stopped() in TX completion path,
     netif_wake_queue() already does that.

<jgarzik@redhat.com> (03/08/26 1.1296)
   [netdrvr 8139cp] ethtool_ops support

<jgarzik@redhat.com> (03/08/26 1.1295)
   [netdrvr sis900] ethtool_ops support

<willy@debian.org> (03/08/26 1.1294)
   [netdrvr 3c59x] ethtool_ops support

<romieu@fr.zoreil.com> (03/08/26 1.1293)
   [netdrvr sis190] pass irq argument to synchronize_irq()
   
   Looks like this driver wasn't tested on SMP :)

<bunk@fs.tum.de> (03/08/26 1.1292)
   [netdrvr sis190] fix build with older gcc
   
   older gcc's do not support C99/C++ style of variable declarations.
