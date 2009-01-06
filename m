From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 05 Jan 2009 18:31:06 -0800 (PST)
Message-ID: <20090105.183106.252630446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbZAFCbF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 21:31:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Largely there are healthy chunks of driver bug fixes and sparse
warning cures here.  But, otherwise:

1) TCP splice receive non-block semantic cures from Lennert Buytenhek.

2) GRO enhancements from Herbert Xu.

3) IPV6 routing cache entry creation needs to run a quick
   garbage collection when the neighbour table overflows,
   otherwise we'll fail unnecessarily and give bogus
   -EINVAL errors to sendmsg() calls when sending to multicast
   groups.

4) U32 packet classifier locking fix from Jarek Poplawski.

5) Some of the remaining net driver firmware conversions.
   Other than these the e100 is the only one pending with
   a patch that I am aware of, and Intel folks are testing
   that one out before I apply it.

Please pull, thanks a lot!

The following changes since commit fe0bdec68b77020281dc814805edfe594ae8=
9e0f:
  Linus Torvalds (1):
        Merge branch 'audit.b61' of git://git.kernel.org/.../viro/audit=
-current

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Baruch Siach (1):
      enc28j60: fix RX buffer overflow

Brice Goglin (1):
      myri10ge: print MAC and serial number on probe failure

Bruce Allan (1):
      e100: cosmetic cleanup

David S. Miller (4):
      ipv6: Fix sporadic sendmsg -EINVAL when sending to multicast grou=
ps.
      tcp: Kill extraneous SPLICE_F_NONBLOCK checks.
      Revert "net: Fix for initial link state in 2.6.28"

=46rank Blaschka (1):
      qeth: do not spin for SETIP ip assist command

Gerrit Renker (4):
      tun: Eliminate sparse signedness warning
      dccp: Lockless integration of CCID congestion-control plugins
      dccp: Clean up ccid.c after integration of CCID plugins
      dccp: Integrate the TFRC library with DCCP

Heiko Carstens (2):
      qeth: get rid of extra argument after printk to dev_* conversion
      iucv: fix cpu hotplug

Hendrik Brueckner (2):
      af_iucv: New error return codes for connect()
      af_iucv: Free iucv path/socket in path_pending callback

Herbert Xu (2):
      gro: Use gso_size to store MSS
      gro: Add page frag support

Ilpo J=E4rvinen (1):
      ipv6: IPV6_PKTINFO relied userspace providing correct length

Jarek Poplawski (1):
      pkt_sched: cls_u32: Fix locking in u32_change()

Jaswinder Singh (1):
      firmware: convert acenic driver to request_firmware()

Jaswinder Singh Rajput (2):
      firmware: convert tg3 driver to request_firmware()
      starfire: use request_firmware()

Klaus-Dieter Wacker (2):
      qeth: HiperSockets mcl string conversion (pre z9 mach)
      qeth: No large send using EDDP for HiperSockets.

Lennert Buytenhek (1):
      tcp: don't mask EOF and socket errors on nonblocking splice recei=
ve

Michael Marineau (1):
      net: Fix for initial link state in 2.6.28

Oliver Hartkopp (1):
      can: update can-bcm for hrtimer hardirq callbacks

Roel Kluin (2):
      isdn: capi: &&/|| typos
      DCB: fix kfree(skb)

Ron Mercer (10):
      qlge: bugfix: Add missing pci_mapping_err checking.
      qlge: bugfix: Add missing pci_unmap_page call in receive path.
      qlge: bugfix: Fix shadow register endian issue.
      qlge: bugfix: Fix ring length setting for rx ring, large/small
      qlge: bugfix: Fix register access error checking.
      qlge: Fix sparse warnings for byte swapping in qlge_ethool.c
      qlge: Fix sparse endian warning for inbound packet control block =
flags.
      qlge: Fix sparse endian warning in ql_hw_csum_setup().
      qlge: Fix sparse warning regarding rx buffer queues.
      qlge: Fix sparse warnings for tx ring indexes.

Simon Holm Th=F8gersen (1):
      net/rfkill/rfkill.c: fix unused rfkill_led_trigger() warning

Stephen Rothwell (1):
      net/ehea: bitops work on unsigned longs

Ursula Braun (3):
      qeth: exploit source MAC address for inbound layer3 packets
      qeth: avoid crash in case of layer mismatch for VSWITCH
      af_iucv: avoid left over IUCV connections from failing connects

 drivers/isdn/capi/capidrv.c           |    4 +-
 drivers/net/acenic.c                  |  117 +-
 drivers/net/acenic.h                  |    4 +
 drivers/net/e100.c                    |  268 +-
 drivers/net/ehea/ehea.h               |    3 +-
 drivers/net/ehea/ehea_main.c          |    2 +-
 drivers/net/enc28j60.c                |    4 +-
 drivers/net/myri10ge/myri10ge.c       |    6 +-
 drivers/net/qlge/qlge.h               |   57 +-
 drivers/net/qlge/qlge_dbg.c           |   13 +-
 drivers/net/qlge/qlge_ethtool.c       |    8 +-
 drivers/net/qlge/qlge_main.c          |  116 +-
 drivers/net/starfire.c                |   54 +-
 drivers/net/starfire_firmware.h       |  346 ---
 drivers/net/starfire_firmware.pl      |   31 -
 drivers/net/tg3.c                     |  792 +-----
 drivers/net/tg3.h                     |    4 +
 drivers/net/tun.c                     |    2 +-
 drivers/s390/net/qeth_core.h          |    1 -
 drivers/s390/net/qeth_core_main.c     |   57 +-
 drivers/s390/net/qeth_l2_main.c       |    8 +-
 drivers/s390/net/qeth_l3_main.c       |   26 +-
 firmware/Makefile                     |   11 +
 firmware/WHENCE                       |   49 +
 firmware/acenic/tg1.bin.ihex          | 4573 +++++++++++++++++++++++++=
++++++
 firmware/acenic/tg2.bin.ihex          | 4844 +++++++++++++++++++++++++=
++++++++
 firmware/adaptec/starfire_rx.bin.ihex |   53 +
 firmware/adaptec/starfire_tx.bin.ihex |   53 +
 firmware/tigon/tg3.bin.ihex           |  175 ++
 firmware/tigon/tg3_tso.bin.ihex       |  446 +++
 firmware/tigon/tg3_tso5.bin.ihex      |  252 ++
 include/linux/netdevice.h             |   16 +-
 include/net/ndisc.h                   |    4 +-
 net/can/bcm.c                         |  208 +-
 net/core/dev.c                        |   93 +-
 net/core/skbuff.c                     |   15 +-
 net/dcb/dcbnl.c                       |   14 +-
 net/dccp/Kconfig                      |    4 -
 net/dccp/Makefile                     |   15 +-
 net/dccp/ackvec.h                     |   49 -
 net/dccp/ccid.c                       |  254 +--
 net/dccp/ccid.h                       |   14 +-
 net/dccp/ccids/Kconfig                |   79 +-
 net/dccp/ccids/Makefile               |    9 -
 net/dccp/ccids/ccid2.c                |   22 +-
 net/dccp/ccids/ccid3.c                |   23 +-
 net/dccp/ccids/lib/Makefile           |    3 -
 net/dccp/ccids/lib/loss_interval.c    |    3 -
 net/dccp/ccids/lib/packet_history.c   |    9 -
 net/dccp/ccids/lib/tfrc.c             |   19 +-
 net/dccp/ccids/lib/tfrc.h             |   11 +-
 net/dccp/ccids/lib/tfrc_equation.c    |    4 -
 net/dccp/dccp.h                       |    2 -
 net/dccp/feat.c                       |    6 +-
 net/dccp/input.c                      |    2 -
 net/dccp/proto.c                      |    7 +
 net/ipv4/tcp.c                        |    9 +-
 net/ipv6/ipv6_sockglue.c              |    2 +-
 net/ipv6/route.c                      |   52 +-
 net/iucv/af_iucv.c                    |   28 +-
 net/iucv/iucv.c                       |   18 +-
 net/rfkill/rfkill.c                   |    4 +-
 net/sched/cls_u32.c                   |    3 +-
 63 files changed, 11470 insertions(+), 1910 deletions(-)
 delete mode 100644 drivers/net/starfire_firmware.h
 delete mode 100644 drivers/net/starfire_firmware.pl
 create mode 100644 firmware/acenic/tg1.bin.ihex
 create mode 100644 firmware/acenic/tg2.bin.ihex
 create mode 100644 firmware/adaptec/starfire_rx.bin.ihex
 create mode 100644 firmware/adaptec/starfire_tx.bin.ihex
 create mode 100644 firmware/tigon/tg3.bin.ihex
 create mode 100644 firmware/tigon/tg3_tso.bin.ihex
 create mode 100644 firmware/tigon/tg3_tso5.bin.ihex
 delete mode 100644 net/dccp/ccids/Makefile
 delete mode 100644 net/dccp/ccids/lib/Makefile

