From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 30 Jun 2011 02:40:23 -0700 (PDT)
Message-ID: <20110630.024023.1470581259069660124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab1F3Jk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 05:40:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Bridge flooding fix from Herbert Xu.

2) ip_rt_bug can trigger in certain TPROXY situations, fix
   from Julian Anastasov.

3) Fix bluetooth L2CAP security check, from Luiz Augusto von Dentz.

4) zlib inflate buffer alloc can result in order-4 allocation, use
   vmalloc instead.

5) ipv6 UDP checks wrong variable for non-blocking condition, fix
   from Xufeng Zhang.

6) If UDP recvmsg ends up retrying, we need to clear the MSG_TRUNC
   flag as the next packet we're going to try might fit.  Fix
   from Xufeng Zhang.

7) Fix OOPS in rionet_remove, from Yinglin Luan.

8) Packet length calculation fixes in the ipv4 output path from
   Steffen Klassert.

9) Fix Kconfig deps for netconsole, from Randy Dunlap.

10) CAN Kconfig files were using "default Y" instead of "default y",
    fix from marc Kleine-Budde.

Please pull, thanks a lot!

The following changes since commit ca56a95eedcc95f8fea7b49c87565cd961d74fe2:

  Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6 (2011-06-29 18:18:48 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Dan Carpenter (1):
      net/usb/kalmia: signedness bug in kalmia_bind()

Dave Jones (1):
      usbnet: Remove over-broad module alias from zaurus.

David S. Miller (2):
      Merge branch 'davem.r8169' of git://git.kernel.org/.../romieu/netdev-2.6
      net+crypto: Use vmalloc for zlib inflate buffers.

Francois Romieu (1):
      r8169: fix wrong register use.

Herbert Xu (1):
      bridge: Only flood unregistered groups to routers

Ilia Kolomisnky (1):
      Bluetooth: Fix L2CAP connection establishment

Johan Hedberg (1):
      Bluetooth: Fix accepting connect requests for defer_setup

John (Jay) Hernandez (1):
      cxgb3: skb_record_rx_queue now records the queue index relative to the net_device.

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Julian Anastasov (1):
      netfilter: Fix ip_route_me_harder triggering ip_rt_bug

Larry Finger (2):
      rtlwifi: rtl8192se: Handle duplicate PCI ID 0x10ec:0x8192 conflict with r8192e_pci
      rtl8192cu: Fix missing firmware load

Luiz Augusto von Dentz (1):
      Bluetooth: Fix L2CAP security check

Marc Kleine-Budde (1):
      net/can: activate bit-timing calculation and netlink based drivers by default

Marius B. Kotsbak (1):
      net/usb: kalmia: Various fixes for better support of non-x86 architectures.

Mike Frysinger (2):
      MAINTAINERS: mark socketcan-core lists as subscribers-only
      MAINTAINERS: drop Michael from bfin_mac driver

Randy Dunlap (1):
      netconsole: fix build when CONFIG_NETCONSOLE_DYNAMIC is turned on

Ron Mercer (1):
      qlge: Add maintainer.

Steffen Klassert (2):
      ipv4: Fix packet size calculation in __ip_append_data
      ipv4: Fix IPsec slowpath fragmentation problem

Sven Eckelmann (1):
      MAINTAINERS: Remove Sven Eckelmann from BATMAN ADVANCED

Xufeng Zhang (2):
      ipv6/udp: Use the correct variable to determine non-blocking condition
      udp/recvmsg: Clear MSG_TRUNC flag when starting over for a new packet

Yinglin Luan (1):
      rionet: fix NULL pointer dereference in rionet_remove

 MAINTAINERS                                 |    7 +--
 crypto/deflate.c                            |    7 +--
 crypto/zlib.c                               |    7 +--
 drivers/net/Kconfig                         |    3 +-
 drivers/net/bnx2x/bnx2x_main.c              |    6 +-
 drivers/net/can/Kconfig                     |    4 +-
 drivers/net/cxgb3/sge.c                     |    4 +-
 drivers/net/ppp_deflate.c                   |    5 +-
 drivers/net/r8169.c                         |    2 +-
 drivers/net/rionet.c                        |   28 +++++++------
 drivers/net/usb/kalmia.c                    |   42 +++++++++++--------
 drivers/net/usb/zaurus.c                    |   10 ----
 drivers/net/wireless/rtlwifi/pci.c          |   13 +++++-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c |   20 +++++++++
 net/bluetooth/hci_conn.c                    |    6 +-
 net/bluetooth/l2cap_core.c                  |   21 +++++++---
 net/bridge/br_multicast.c                   |    5 ++-
 net/ipv4/ip_output.c                        |   17 +++----
 net/ipv4/netfilter.c                        |   60 ++++++++++-----------------
 net/ipv4/netfilter/ipt_REJECT.c             |   14 ++----
 net/ipv4/udp.c                              |    3 +
 net/ipv6/udp.c                              |    5 ++-
 22 files changed, 155 insertions(+), 134 deletions(-)
