From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 08 Nov 2009 21:32:08 -0800 (PST)
Message-ID: <20091108.213208.159291731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34341
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742AbZKIFbm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 00:31:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Wireless fixes, including a revert for something that added as
   many bugs as it fixed.  Via John Linville.

2) Rose and DecNET leaks device references.  CAN protocol doesn't
   lock device list accesses properly.  All from Eric Dumazet.

3) TX of ixgbe can hang with ioatdma loded, fix from Don Skidmore.

4) be2net fixes for flow control programming on resume, the timing
   of sending configuration commands to the chip, and a broken
   status shift macro define, from Ajit Khaparde and Sathya Perla.

5) A queue of ISDN fixes via Andrew Morton.

6) Two netfilter bug fixes (Patrick McHardy has been offline for a mont=
h
   or so these are the only two netfilter fixes that have gone in in
   that time), from Jan Engelhardt and Jozsef Kadlecsik.

7) When PMTU discovery is off, we handle DF packets improperly in
   IPIP tunnel driver.  Fix from Herbert Xu.

8) fsl_pq_mdio is missing MODULE_LICENSE() tag, from Sebastian Siewior.

9) virtio_net section mismatch fix from Uwe Kleine-K=F6nig.

10) IXGBE uses wrong gso_max_size on 82599 chips when DCB is enabled.
    It also checks TXOFF status incorrectly when DCB is enabled.  Both=09
    fixed from Yi Zou.

11) CAN protocol needs to provide ->get_size() operation otherwise
    netlink SKBs aren't sized for it correctly.  From Wolfgang
    Grandegger.

Please pull, thanks a lot.

The following changes since commit 7c9abfb884b8737f0afdc8a88bcea77526f0=
da87:
  Linus Torvalds (1):
        Merge branch 'kvm-updates/2.6.32' of git://git.kernel.org/pub/s=
cm/virt/kvm/kvm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (2):
      be2net: fix to set proper flow control on resume
      be2net: Bug fix to send config commands to hardware after netdev_=
register

Dan Carpenter (1):
      misdn: Fix reversed 'if' in st_own_ctrl

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Don Skidmore (1):
      ixgbe: fix traffic hangs on Tx with ioatdma loaded

Eric Dumazet (3):
      rose: device refcount leak
      decnet: netdevice refcount leak
      can: should not use __dev_get_by_index() without locks

=46inn Thain (1):
      macsonic: fix crash on PowerBook 520

Herbert Xu (1):
      ipip: Fix handling of DF packets when pmtudisc is OFF

Jan Engelhardt (1):
      netfilter: xt_connlimit: fix regression caused by zero family val=
ue

Jiri Slaby (4):
      isdn: hisax: Fix lock imbalance.
      isdn: eicon: Use offsetof
      isdn: eicon: Return on error
      NET: cassini, fix lock imbalance

Joe Perches (1):
      MAINTAINERS: Add git net-next-2.6

John W. Linville (1):
      Revert "ipw2200: fix oops on missing firmware"

Jozsef Kadlecsik (1):
      netfilter: nf_nat: fix NAT issue in 2.6.30.4+

Larry Finger (1):
      rtl8187: Fix kernel oops when device is removed when LEDS enabled

Martin Michlmayr (1):
      hisax: remove bad udelay call to fix build error on ARM

Roel Kluin (2):
      isdn: hisax: Fix test in waitforxfw
      isdn: hfc_usb: Fix read buffer overflow

Ron Mercer (2):
      qlge: Fix early exit from mbox cmd complete wait.
      qlge: Set PCIe reset type for EEH to fundamental.

Sathya Perla (1):
      be2net: Fix CQE_STATUS_EXTD_SHIFT define

Sean Cross (1):
      rt2x00: Don't queue ieee80211 work after USB removal

Sebastian Haas (1):
      ems_usb: Fix byte order issues on big endian machines

Sebastian Siewior (1):
      net/fsl_pq_mdio: add module license GPL

Stephen Hemminger (1):
      bridge: prevent bridging wrong device

Tonyliu (1):
      DaVinci EMAC: correct param for ISR

Torgny Johansson (1):
      cdc_ether: additional Ericsson MBM PID's to the whitelist

Uwe Kleine-K=F6nig (1):
      virtio_net: rename driver struct to please modpost

Wolfgang Grandegger (1):
      can: fix WARN_ON dump in net/core/rtnetlink.c:rtmsg_ifinfo()

Yi Zou (2):
      ixgbe: Fix gso_max_size for 82599 when DCB is enabled
      ixgbe: Fix checking TFCS register for TXOFF status when DCB is en=
abled

 MAINTAINERS                                  |    1 +
 drivers/isdn/hardware/eicon/maintidi.c       |    5 +-
 drivers/isdn/hardware/eicon/message.c        |   18 ++--
 drivers/isdn/hisax/amd7930_fn.c              |    1 +
 drivers/isdn/hisax/diva.c                    |    2 +-
 drivers/isdn/hisax/elsa_ser.c                |   22 +++---
 drivers/isdn/hisax/hfc_usb.c                 |    4 +-
 drivers/isdn/hisax/hscx_irq.c                |    2 +-
 drivers/isdn/hisax/icc.c                     |    1 +
 drivers/isdn/mISDN/stack.c                   |    2 +-
 drivers/net/benet/be.h                       |    2 +
 drivers/net/benet/be_cmds.h                  |    2 +-
 drivers/net/benet/be_ethtool.c               |    8 +-
 drivers/net/benet/be_main.c                  |   28 ++++---
 drivers/net/can/dev.c                        |   17 ++++
 drivers/net/can/usb/ems_usb.c                |    5 +-
 drivers/net/cassini.c                        |    5 +-
 drivers/net/davinci_emac.c                   |    2 +-
 drivers/net/fsl_pq_mdio.c                    |    1 +
 drivers/net/ixgbe/ixgbe_main.c               |   84 +++++++++++++++++-=
-
 drivers/net/macsonic.c                       |  117 +++++++++++++-----=
--------
 drivers/net/qlge/qlge_main.c                 |    2 +
 drivers/net/qlge/qlge_mpi.c                  |    2 +-
 drivers/net/usb/Kconfig                      |    2 +-
 drivers/net/usb/cdc_ether.c                  |   42 +++++++++-
 drivers/net/virtio_net.c                     |    6 +-
 drivers/net/wireless/ipw2x00/ipw2100.c       |    5 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |    2 -
 drivers/net/wireless/ipw2x00/libipw.h        |    1 -
 drivers/net/wireless/ipw2x00/libipw_module.c |   14 +--
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    4 +-
 drivers/net/wireless/rt2x00/rt2x00link.c     |   11 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.c      |    9 ++-
 drivers/net/wireless/rtl818x/rtl8187_leds.c  |    4 +-
 include/net/netfilter/nf_conntrack.h         |    8 +-
 include/net/netfilter/nf_nat_helper.h        |    4 +
 net/bridge/br_if.c                           |    6 +-
 net/can/bcm.c                                |   19 +++--
 net/decnet/sysctl_net_decnet.c               |    7 +-
 net/ipv4/ipip.c                              |   32 ++++----
 net/ipv4/netfilter/nf_nat_core.c             |    3 +
 net/ipv4/netfilter/nf_nat_helper.c           |   34 +++++---
 net/netfilter/nf_conntrack_core.c            |    8 ++
 net/netfilter/nf_conntrack_proto_tcp.c       |   64 ++++++--------
 net/netfilter/xt_connlimit.c                 |   10 +--
 net/rose/rose_route.c                        |   16 ++--
 46 files changed, 407 insertions(+), 237 deletions(-)
