From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 03 Feb 2009 23:27:29 -0800 (PST)
Message-ID: <20090203.232729.194305460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751122AbZBDH1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 02:27:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) pcnet_cs does "if (x = y)" instead of "if (x == y)".  Fix from
   Cord Walter

2) Fix some userland header bogosity in linux/if_tunnel.h

3) Recent changes caused sk->sk_drops to not get incremented for
   ipv4 UDP sockets.  Fix from Eric Dumazet.

4) RDMA sunrpc dependency fix from Randy Dunlap.

5) DCA deadlock fixes from Maciej Sosnowski.

6) Roel Kluin found a bunch of cases where we do (usually when
   polling on a register bit to set or clear):

	while (timeout--) {
		if (bit_changed)
			break;
	}
	if (timeout <= 0)
		throw_error();

   But this throws an error even if we did see the necessary
   end-condition on the final iteration.

   Several drivers have this bug now fixed.

7) e1000 does not honor the need_ioport flag, fix from Karsten Keil.

8) Three qlge bug fixes from Ron Mercer.

9) AF_PACKET mmap() support has bugs because of incorrect operator
   precendence in the end tests.  Fix from Sebastiano Di Paola.

10) SGI xpnet fix, forgot to hook up ->netdev_ops, oops.  Fix from
    Dean Nelson.

Please pull, thanks a lot!

The following changes since commit dcf6a79dda5cc2a2bec183e50d829030c0972aaa:
  Artem Bityutskiy (1):
        write-back: fix nr_to_write counter

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Cord Walter (1):
      pcnet_cs: Fix misuse of the equality operator.

David S. Miller (2):
      net: Fix userland breakage wrt. linux/if_tunnel.h
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6

Dean Nelson (1):
      sgi-xp: link XPNET's net_device_ops to its net_device structure

Eric Dumazet (1):
      udp: increments sk_drops in __udp_queue_rcv_skb()

Filip Aben (1):
      hso: add new device id's

Karsten Keil (1):
      e1000: Fix PCI enable to honor the need_ioport flag

Maciej Sosnowski (1):
      dca: redesign locks to fix deadlocks

Randy Dunlap (1):
      sunrpc: fix rdma dependencies

Roel Kluin (2):
      net: variables reach -1, but 0 tested
      cassini/sungem: limit reaches -1, but 0 tested

Ron Mercer (3):
      qlge: bugfix: Fix endian issue when reading flash.
      qlge: bugfix: Add flash offset for second port.
      qlge: bugfix: Add missing netif_napi_del call.

Sebastiano Di Paola (1):
      net: packet socket packet_lookup_frame fix

 drivers/dca/dca-core.c         |   51 +++++++++++++++++++++++++--------------
 drivers/misc/sgi-xp/xpnet.c    |    3 +-
 drivers/net/cassini.c          |    4 +-
 drivers/net/e1000/e1000_main.c |    2 +-
 drivers/net/ibm_newemac/phy.c  |    4 +-
 drivers/net/pcmcia/pcnet_cs.c  |    2 +-
 drivers/net/qlge/qlge.h        |   10 ++++----
 drivers/net/qlge/qlge_main.c   |   25 +++++++++++++++----
 drivers/net/smc911x.c          |    4 +-
 drivers/net/smsc9420.c         |   12 ++++----
 drivers/net/sungem.c           |    2 +-
 drivers/net/sungem_phy.c       |    2 +-
 drivers/net/sunqe.c            |    2 +-
 drivers/net/tsi108_eth.c       |    2 +-
 drivers/net/tulip/de2104x.c    |    2 +-
 drivers/net/usb/hso.c          |    4 ++-
 include/linux/Kbuild           |    2 +-
 include/linux/if_tunnel.h      |    3 ++
 net/ipv4/udp.c                 |    4 ++-
 net/packet/af_packet.c         |    8 +++---
 net/sunrpc/Kconfig             |    2 +-
 21 files changed, 93 insertions(+), 57 deletions(-)
