From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 18 Feb 2011 13:52:48 -0800 (PST)
Message-ID: <20110218.135248.48512615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The on-stack list_head memory corruption fixes from Linus and Eric
   Dumazet.

2) ISDN hisax doesn't check alloc_skb() failures.

3) ieee80211_reconfig doesn't do necessary locking, fix from Eliad
   Peller.

4) Work around buffer size hw limitation in ixgbe driver, from Amir
   Hanania.

5) Fix crash in ixgbe driver due to NULL ptr deref, from Andy
   Gospodarek.

6) Fix crash in tcp_connect() due to blackhole dst_ops missing
   default_mss() method, fix from Eric Dumazet.

7) Multicast snooping list corruption et al. fixes in bridging from
   Herbert Xu.

8) NETDEV_NOTIFY_PEERS events should send gratuitous ARP unconditionally
   as it's used to trigger fail-over, from Ian Campbell.

9) xfrm_alloc_dst() can OOPS due to mis-coded conditional, from
   Hiroaki SHIMODA.

10) Several NULL deref fixes from Jesper Juhl in DCB, USB Net, USB HSO,
    and ATM Solos driver.

11) Device shutdown races and fixes in e1000e, from Jesse Brandeburg.

12) Fix CAN softing driver Kconfig deps, from Kurt Van Dijck.

13) Fix RCU usage in netfilter nf_iterate, from Patrick McHardy.

14) A cleanup change lost the setting of IPPROT_GRE value in the key
    used to lookup routes in ipgre_tunnel_xmit, fix from Steffen Klassert.

15) RX padding and MAC address loading fixes in pch_gbe driver from
    Toshiharu Okada.

16) If the firmward has control of the tg3 PHY, don't allow ioctl access
    otherwise we'll corrupt state.  Fix from Matt Carlson.

The following changes since commit a5bbef0b2deb7b943f095181309ecc9e1fc91c0f:

  Merge branch 'for-linus/bugfixes' of git://xenbits.xen.org/people/ianc/linux-2.6 (2011-02-18 12:44:41 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amir Hanania (1):
      ixgbe: work around for DDP last buffer size

Andy Gospodarek (1):
      ixgbe: fix panic due to uninitialised pointer

Bao Liang (1):
      Bluetooth: Set conn state to BT_DISCONN to avoid multiple responses

Casey Leedom (4):
      cxgb4vf: Check driver parameters in the right place ...
      cxgb4vf: Behave properly when CONFIG_DEBUG_FS isn't defined ...
      cxgb4vf: Quiesce Virtual Interfaces on shutdown ...
      cxgb4vf: Use defined Mailbox Timeout

Cho, Yu-Chen (1):
      Bluetooth: add Atheros BT AR9285 fw supported

David S. Miller (5):
      hisax: Fix unchecked alloc_skb() return.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      iwlwifi: Delete iwl3945_good_plcp_health.
      isdn: hisax: Use l2headersize() instead of dup (and buggy) func.

Eliad Peller (1):
      mac80211: add missing locking in ieee80211_reconfig

Eric Dumazet (2):
      net: provide default_advmss() methods to blackhole dst_ops
      net: deinit automatic LIST_HEAD

Giuseppe Cavallaro (1):
      stmmac: enable wol via magic frame by default.

Herbert Xu (3):
      bridge: Fix mglist corruption that leads to memory corruption
      bridge: Fix timer typo that may render snooping less effective
      bridge: Replace mp->mglist hlist with a bool

Hiroaki SHIMODA (1):
      xfrm: avoid possible oopse in xfrm_alloc_dst

Ian Campbell (1):
      arp_notify: unconditionally send gratuitous ARP for NETDEV_NOTIFY_PEERS.

Ivan Vecera (1):
      drivers/net: Call netif_carrier_off at the end of the probe

Jesper Juhl (4):
      Don't potentially dereference NULL in net/dcb/dcbnl.c:dcbnl_getapp()
      USB Network driver infrastructure: Fix leak when usb_autopm_get_interface() returns less than zero in kevent().
      Net, USB, Option, hso: Do not dereference NULL pointer
      ATM, Solos PCI ADSL2+: Don't deref NULL pointer if net_ratelimit() and alloc_skb() interact badly.

Jesse Brandeburg (2):
      e1000e: check down flag in tasks
      e1000e: flush all writebacks before unload

John Fastabend (1):
      net: dcb: application priority is per net_device

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6

Kurt Van Dijck (1):
      net/can/softing: make CAN_SOFTING_CS depend on CAN_SOFTING

Linus Torvalds (1):
      net: dont leave active on stack LIST_HEAD

Matt Carlson (1):
      tg3: Restrict phy ioctl access

Patrick McHardy (1):
      netfilter: nf_iterate: fix incorrect RCU usage

Randy Dunlap (1):
      net: fix ifenslave build flags

Stanislaw Gruszka (1):
      iwl3945: remove plcp check

Steffen Klassert (1):
      ip_gre: Add IPPROTO_GRE to flowi in ipgre_tunnel_xmit

Toshiharu Okada (2):
      pch_gbe: Fix the issue that the receiving data is not normal.
      pch_gbe: Fix the MAC Address load issue.

 Documentation/networking/Makefile       |    2 +
 drivers/atm/solos-pci.c                 |    5 +-
 drivers/bluetooth/ath3k.c               |    2 +
 drivers/bluetooth/btusb.c               |    3 +
 drivers/isdn/hisax/isdnl2.c             |   28 ++++-----
 drivers/net/can/softing/Kconfig         |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c      |   80 ++++++++++++++++++------
 drivers/net/cxgb4vf/t4vf_hw.c           |    2 +-
 drivers/net/e1000e/netdev.c             |   52 ++++++++++++---
 drivers/net/forcedeth.c                 |    2 +
 drivers/net/ixgbe/ixgbe_fcoe.c          |   51 +++++++++++++++-
 drivers/net/ixgbe/ixgbe_fcoe.h          |    2 +
 drivers/net/ixgbe/ixgbe_main.c          |    6 +-
 drivers/net/pch_gbe/pch_gbe.h           |    2 +-
 drivers/net/pch_gbe/pch_gbe_main.c      |  104 ++++++++++++++++++------------
 drivers/net/r8169.c                     |    2 +
 drivers/net/stmmac/stmmac_main.c        |    4 +-
 drivers/net/tg3.c                       |    8 ++-
 drivers/net/usb/hso.c                   |   12 ++--
 drivers/net/usb/usbnet.c                |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c |   67 --------------------
 net/bluetooth/l2cap.c                   |    1 +
 net/bridge/br_input.c                   |    2 +-
 net/bridge/br_multicast.c               |   19 +++---
 net/bridge/br_private.h                 |    3 +-
 net/core/dev.c                          |    9 ++-
 net/dcb/dcbnl.c                         |    9 +++-
 net/ipv4/devinet.c                      |   30 ++++++---
 net/ipv4/ip_gre.c                       |    1 +
 net/ipv4/route.c                        |    1 +
 net/ipv6/route.c                        |    1 +
 net/mac80211/util.c                     |    2 +
 net/netfilter/core.c                    |    3 +-
 net/xfrm/xfrm_policy.c                  |    7 ++-
 34 files changed, 327 insertions(+), 201 deletions(-)
