From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 06 Apr 2009 17:57:52 -0700 (PDT)
Message-ID: <20090406.175752.236260059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751035AbZDGA6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 20:58:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) E1000 multicast packet loss fix from Jesse Brandeburg.

2) Two request_firmware() conversions (myri_sbus and bnx2)

3) Two B44 DMA fixes from Michael Buesch.  These could explain a bunch
   of strange bugs actually.

4) Use percpu_add() instead of by hand expansion, from Eric Dumazet.

5) vxge build fix from Alexander Beregalov.

6) virtio_net MAC setting fix from Alex Willaimson.

7) IPSEC ipv6 tunnel fragmentation bug fix from Steffen Klassert.

8) gigaset driver bug fixes from Tilman Schmidt.

9) axnet_cs PHY detection bug fixes from Ken Kawasaki.

10) Missing MODULE_LICENSE in fddi module.

Please pull, thanks a lot!

The following changes since commit 6bb597507f9839b13498781e481f5458aea33620:
  Linus Torvalds (1):
        Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      net/802/fddi.c: add MODULE_LICENSE

Alex Williamson (1):
      virtio_net: Set the mac config only when VIRITO_NET_F_MAC

Alexander Beregalov (1):
      vxge: should include tcp.h

Ed Swierk (1):
      forcedeth: Fix resume from hibernation regression.

Eric Dumazet (1):
      socket: use percpu_add() while updating sockets_in_use

Huang Weiyi (1):
      smsc911x: remove unused #include <linux/version.h>

Jaswinder Singh Rajput (1):
      myri_sbus: use request_firmware

Jean Delvare (1):
      ibm_newemac: Fix dangerous struct assumption

Jesse Brandeburg (1):
      e1000: fix loss of multicast packets

Ken Kawasaki (1):
      axnet_cs: fix phy_id detection for bogus Asix chip.

Michael Buesch (2):
      b44: Fix sizes passed to b44_sync_dma_desc_for_{device,cpu}()
      b44: Use kernel DMA addresses for the kernel DMA API

Michael Chan (1):
      bnx2: Use request_firmware()

Steffen Klassert (1):
      xfrm: fix fragmentation on inter family tunnels

Tilman Schmidt (3):
      bas_gigaset: use tasklet_hi_schedule for timing critical tasklets
      gigaset: in file ops, check for device disconnect before anything else
      gigaset: documentation update

 Documentation/isdn/README.gigaset         |   52 +-
 drivers/isdn/gigaset/bas-gigaset.c        |    4 +-
 drivers/isdn/gigaset/interface.c          |   58 +-
 drivers/net/Kconfig                       |    2 +-
 drivers/net/b44.c                         |    8 +-
 drivers/net/bnx2.c                        |  351 ++-
 drivers/net/bnx2.h                        |   71 +-
 drivers/net/bnx2_fw.h                     | 4378 +----------------------
 drivers/net/bnx2_fw2.h                    | 4547 ----------------------
 drivers/net/e1000/e1000_main.c            |   34 +-
 drivers/net/forcedeth.c                   |    3 +
 drivers/net/ibm_newemac/core.c            |    2 +-
 drivers/net/myri_code.h                   | 5006 -------------------------
 drivers/net/myri_sbus.c                   |   37 +-
 drivers/net/pcmcia/axnet_cs.c             |    9 +-
 drivers/net/smsc911x.c                    |    1 -
 drivers/net/virtio_net.c                  |   10 +-
 drivers/net/vxge/vxge-main.c              |    1 +
 firmware/Makefile                         |    5 +
 firmware/WHENCE                           |   30 +
 firmware/bnx2/bnx2-mips-06-4.6.16.fw.ihex | 5805 ++++++++++++++++++++++++++++
 firmware/bnx2/bnx2-mips-09-4.6.17.fw.ihex | 5816 +++++++++++++++++++++++++++++
 firmware/bnx2/bnx2-rv2p-06-4.6.16.fw.ihex |  441 +++
 firmware/bnx2/bnx2-rv2p-09-4.6.15.fw.ihex |  490 +++
 firmware/myricom/lanai.bin.ihex           | 4771 +++++++++++++++++++++++
 net/802/fddi.c                            |    2 +
 net/ipv6/xfrm6_output.c                   |    1 +
 net/socket.c                              |    6 +-
 28 files changed, 17751 insertions(+), 14190 deletions(-)
 delete mode 100644 drivers/net/bnx2_fw2.h
 delete mode 100644 drivers/net/myri_code.h
 create mode 100644 firmware/bnx2/bnx2-mips-06-4.6.16.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-mips-09-4.6.17.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-06-4.6.16.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-09-4.6.15.fw.ihex
 create mode 100644 firmware/myricom/lanai.bin.ihex
