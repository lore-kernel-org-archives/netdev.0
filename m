From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 08 May 2008 17:14:08 -0700 (PDT)
Message-ID: <20080508.171408.94456716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754794AbYEIAOP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:14:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are some networking fixes and enhancements:

1) Bonding bug fixes from Pavel Emelyanov and Jay Vosburgh.

2) Support for some newer PHY chips in E1000E, from Bruce Allan.

3) TCP FRTO SACK fix when in newreno mode from Ilpo.

4) Fix can_send() handling when dev_queue_xmit() fails, from
   Oliver Hartkopp.

5) macvlan leak/oops fix from Patrick McHardy.

6) Two netfilter fixes from Patrick McHardy.

7) fs_enet leak fix from Scott Wood.

8) Namespace network device corruption fix from Pavel Emelyanov.

9) Several other device driver fixes from Jeff Garzik's tree.

Please pull, thanks a lot!

The following changes since commit 9d1045ad68fcccfaf1393cc463ab6357693e=
8d1d:
  Jamal Hadi Salim (1):
        net_cls_act: act_simple dont ignore realloc code

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Cox (1):
      cxgb3: Use CAP_SYS_RAWIO for firmware

Andy Fleming (3):
      gianfar: Fix a locking bug in gianfar's sysfs code
      phylib: Fix some sparse warnings
      ucc_geth: Fix a bunch of sparse warnings

Anton Vorontsov (2):
      uli526x: initialize the hardware prior to requesting interrupts
      uli526x: fix endianness issues in the setup frame

Ben Hutchings (1):
      net: Added ASSERT_RTNL() to dev_open() and dev_close().

Bruce Allan (1):
      e1000e: Add support for BM PHYs on ICH9

Bruce Robson (1):
      [netdrvr] eexpress: IPv6 fails - multicast problems

David S. Miller (1):
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/n=
etdev-2.6

Don Fry (1):
      pcnet32: delete non NAPI code from driver.

Gunnar Larisch (1):
      3c980-TX needs EXTRA_PREAMBLE

Ilpo J=C3=A4rvinen (1):
      tcp FRTO: SACK variant is errorneously used with NewReno

J.H.M. Dassen (Ray) (1):
      net/ipv4: correct RFC 1122 section reference in comment

Jay Vosburgh (2):
      bonding: fix error unwind in bonding_store_bonds
      bonding: fix enslavement error unwinds

Jeff Garzik (2):
      fix warning in drivers/net/appletalk/cops.c
      Merge branch 'for-2.6.26' of git://git.farnsworth.org/dale/linux-=
2.6-mv643xx_eth into upstream

Joakim Tjernlund (1):
      ucc_geth: Don't use RX clock as TX clock.

Kok, Auke (1):
      e1000e: don't return half-read eeprom on error

Lennert Buytenhek (5):
      mv643xx_eth: get rid of static variables, allow multiple instance=
s
      mv643xx_eth: mbus decode window support
      mv643xx_eth: configurable t_clk
      mv643xx_eth: shorten shared platform driver name
      mv643xx_eth: inter-mv643xx SMI port sharing

Oliver Hartkopp (1):
      can: Fix can_send() handling on dev_queue_xmit() failures

Patrick McHardy (3):
      macvlan: Fix memleak on device removal/crash on module removal
      netfilter: nf_conntrack_sip: restrict RTP expect flushing on erro=
r to last request
      netfilter: Kconfig: default DCCP/SCTP conntrack support to the pr=
otocol config values

Paulius Zaleckas (1):
      3c59x: use netstats in net_device structure

Pavel Emelyanov (3):
      bonding: Do not call free_netdev for already registered device.
      bonding: Deadlock between bonding_store_bonds and bond_destroy_sy=
sfs.
      netns: Fix arbitrary net_device-s corruptions on net_ns stop.

Scott Wood (1):
      fs_enet: Fix a memory leak in fs_enet_mdio_probe

 arch/arm/mach-orion5x/common.c             |    2 +
 arch/powerpc/platforms/chrp/pegasos_eth.c  |    4 +
 arch/powerpc/sysdev/mv64x60_dev.c          |    2 +
 arch/ppc/syslib/mv64x60.c                  |    3 +
 drivers/net/3c59x.c                        |   73 +++---
 drivers/net/Kconfig                        |   14 --
 drivers/net/appletalk/cops.c               |   16 +-
 drivers/net/bonding/bond_main.c            |   24 ++-
 drivers/net/bonding/bond_sysfs.c           |   16 +-
 drivers/net/cxgb3/cxgb3_main.c             |    4 +-
 drivers/net/e1000e/defines.h               |   10 +
 drivers/net/e1000e/e1000.h                 |    7 +-
 drivers/net/e1000e/ethtool.c               |   45 +++-
 drivers/net/e1000e/hw.h                    |   22 ++
 drivers/net/e1000e/ich8lan.c               |   83 +++++++-
 drivers/net/e1000e/netdev.c                |  330 ++++++++++++++++++++=
+++++++-
 drivers/net/e1000e/phy.c                   |  278 ++++++++++++++++++++=
+++
 drivers/net/eexpress.c                     |   11 +-
 drivers/net/fs_enet/mii-fec.c              |    3 +-
 drivers/net/gianfar.c                      |    5 +-
 drivers/net/gianfar.h                      |    3 +
 drivers/net/gianfar_sysfs.c                |   10 +-
 drivers/net/macvlan.c                      |    2 +-
 drivers/net/mv643xx_eth.c                  |  160 +++++++++++---
 drivers/net/pcnet32.c                      |   61 +-----
 drivers/net/phy/phy.c                      |    2 +-
 drivers/net/tulip/uli526x.c                |   38 ++--
 drivers/net/ucc_geth.c                     |  278 ++++++++++++--------=
---
 drivers/net/ucc_geth.h                     |   48 +++--
 drivers/net/ucc_geth_ethtool.c             |    6 -
 drivers/net/ucc_geth_mii.c                 |    4 +-
 include/linux/mv643xx_eth.h                |   16 ++-
 include/linux/netfilter/nf_conntrack_sip.h |    1 +
 include/linux/phy.h                        |    5 +
 net/can/af_can.c                           |   16 +-
 net/core/dev.c                             |   12 +-
 net/ipv4/ip_input.c                        |    2 +-
 net/ipv4/tcp_input.c                       |   13 +-
 net/netfilter/Kconfig                      |    4 +
 net/netfilter/nf_conntrack_sip.c           |   22 +-
 40 files changed, 1242 insertions(+), 413 deletions(-)
