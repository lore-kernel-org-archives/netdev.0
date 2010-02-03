From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 02 Feb 2010 17:41:46 -0800 (PST)
Message-ID: <20100202.174146.268117027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Besides the usual trickle of wired and wireless driver fixes.
we have:

1) bond_open() doesn't return sane error return values, from Stephem
   Hemminger.

2) Off-by-one and expectation masking netfilter fixes from
   Patrick McHardy.

3) The connector's notification code was buggy, it's hard to fix
   but since nobody uses it simply kill it off.  Fix from Evgeniy Polyakov.

I anticipate two more bug fixes coming my way which we really should
get into 2.6.33-final:

1) netfilter conntrack namespace handling is bugged and this
   kills KVM folks using libvirt, problem is fully diagnosed and
   patch should be in the works as I type this

2) sky2 transmit DMA mapping bug causes IOMMU mapping exhaustion
   and other nasties, fix posted I just want it to cook for
   another day or two

Please pull, thanks a lot!

The following changes since commit ab658321f32770b903a4426e2a6fae0392757755:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../tiwai/sound-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: Bug fix to support newer generation of BE ASIC

Alexander Duyck (1):
      igbvf: fix issue w/ mapped_as_page being left set after unmap

Andrei Emeltchenko (2):
      Bluetooth: Remove double free of SKB pointer in L2CAP
      Bluetooth: Fix memory leak in L2CAP

Bastien Nocera (1):
      Bluetooth: Use the control channel for raw HID reports

Ben Hutchings (2):
      starfire: clean up properly if firmware loading fails
      cdc_ether: Partially revert "usbnet: Set link down initially ..."

Choi, David (1):
      drivers/net: ks8851_mll ethernet network driver

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      be2net: Fix memset() arg ordering.
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6

Evgeniy Polyakov (1):
      connector: Delete buggy notification code.

Felix Fietkau (2):
      ath9k: fix beacon slot/buffer leak
      ath9k: fix eeprom INI values override for 2GHz-only cards

Johannes Berg (1):
      iwlwifi: fix pointer signedness warning

John Fastabend (2):
      ixgbe: set the correct DCB bit for pg tx settings
      ixgbe: if ixgbe_copy_dcb_cfg is going to fail learn about it early

Mike Frysinger (1):
      Bluetooth: Redo checks in IRQ handler for shared IRQ support

Patrick McHardy (2):
      netfilter: nf_conntrack_sip: fix off-by-one in compact header parsing
      netfilter: ctnetlink: fix expectation mask dump

Sathya Perla (1):
      be2net: use eq-id to calculate cev-isr reg offset

Shan Wei (1):
      ipv6: conntrack: Add member of user to nf_ct_frag6_queue structure

Vikram Kandukuri (1):
      Bluetooth: Add DFU driver for Atheros Bluetooth chipset AR3011

Zhu Yi (1):
      mac80211: fix NULL pointer dereference when ftrace is enabled

stephen hemminger (1):
      bonding: bond_open error return value

 drivers/bluetooth/Kconfig               |   13 ++-
 drivers/bluetooth/Makefile              |    1 +
 drivers/bluetooth/ath3k.c               |  187 +++++++++++++++++++++++++++++++
 drivers/bluetooth/bluecard_cs.c         |    4 +-
 drivers/bluetooth/bt3c_cs.c             |    4 +-
 drivers/bluetooth/btuart_cs.c           |    4 +-
 drivers/bluetooth/dtl1_cs.c             |    4 +-
 drivers/connector/connector.c           |  175 -----------------------------
 drivers/net/benet/be.h                  |    5 +
 drivers/net/benet/be_cmds.h             |    3 +-
 drivers/net/benet/be_main.c             |   27 ++++-
 drivers/net/bonding/bond_main.c         |    2 +-
 drivers/net/igbvf/netdev.c              |    1 +
 drivers/net/ixgbe/ixgbe_dcb_nl.c        |   16 +--
 drivers/net/ks8851_mll.c                |    4 +-
 drivers/net/starfire.c                  |    5 +-
 drivers/net/usb/cdc_ether.c             |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c     |    7 +-
 drivers/net/wireless/ath/ath9k/main.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c  |    4 +-
 include/linux/connector.h               |   32 ------
 net/bluetooth/hidp/core.c               |   70 ++++++------
 net/bluetooth/l2cap.c                   |   14 +--
 net/ipv6/netfilter/nf_conntrack_reasm.c |    1 +
 net/mac80211/driver-trace.h             |    2 +-
 net/netfilter/nf_conntrack_netlink.c    |    3 +-
 net/netfilter/nf_conntrack_sip.c        |    2 +-
 27 files changed, 312 insertions(+), 282 deletions(-)
 create mode 100644 drivers/bluetooth/ath3k.c
