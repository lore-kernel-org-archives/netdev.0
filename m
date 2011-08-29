From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 29 Aug 2011 13:33:50 -0400 (EDT)
Message-ID: <20110829.133350.1595381064344998272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The flurry of bluetooth patches are a series of changes which are all
essentially the same bug fix (missing wakeups) in different areas of
the bluetooth code.

Besides that we have:

1) sendmmsg() fix doesn't use uaccess for user pointer accesses,
   whoops, fix from Mathieu Desnoyers.

2) Fix races between wiphy unregistry and suspend/resume resulting in
   OOPS, from Stanislaw Gruszka.

3) Fix USB refcounting in rt2x00 during suspend, also from Stanislaw
   Gruszka.

4) Missing mutex grab in carl9170_op_set_key(), from Alexey Khoroshilov=
=2E

5) Multicast source address selection for listener report is wrong, fix
   from Zheng Yan.

6) In bridge multicasting support, ipv6 checksum validation was using
   potentially old header pointers and was not taking the psuedo-header
   into account in the calculations.  This was causing MLD packets to
   get dropped by the bridge.  Also from Zheng Yan.

7) Fix use after free in icmp6 header parsing, again in bridge multicas=
ting
   support, from Eric Dumazet.

8) Fix RCU lockdep splat in arp_process(), also from Eric Dumazet.

9) ibmveth can leak when getting certain hypervisor errors during SKB
   recycling.  Fix from Anton Blanchard.

10) DP83865 PHY interrupt handler doesn't clear interrupts properly, fi=
x
    from Giuseppe CAVALLARO.

11) Fix compile erro in sh_eth due to missing header, from Yoshihiro Sh=
imoda.

12) Fix uninitialized variables and spinlocks in CAN ti_hecc driver,
    from Abhilash K V.

13) Fix missing index initialization before register access in cassini
    driver, from Francois Romieu.

14) Fix potentially stale skb->data pointer accesses in __netpoll_rx(),
    from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit c6a389f123b9f68d605bb7e0f9b32ec1e3e1=
4132:

  Linux 3.1-rc4 (2011-08-28 21:16:01 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net.git master

Abhilash K V (2):
      can: ti_hecc: Fix unintialized variable
      can: ti_hecc: Fix uninitialized spinlock in probe

Alexey Khoroshilov (1):
      carl9170: Fix mismatch in carl9170_op_set_key mutex lock-unlock

Anton Blanchard (1):
      ibmveth: Fix leak when recycling skb and hypervisor returns error

Chen Ganir (1):
      Bluetooth: Fixed wrong L2CAP Sock timer value

Dan Carpenter (1):
      Bluetooth: unlock if allocation fails in hci_blacklist_add()

David Woodhouse (1):
      bcma: add uevent to the bus, to autoload drivers

Eric Dumazet (3):
      bridge: fix a possible use after free
      arp: fix rcu lockdep splat in arp_process()
      netpoll: fix incorrect access to skb data in __netpoll_rx

Giuseppe CAVALLARO (1):
      net/phy: fix DP83865 phy interrupt handler

Ido Yariv (2):
      wl12xx: Remove obsolete testmode NVS push command
      wl12xx: Fix validation of pm_runtime_get_sync return value

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Luciano Coelho (1):
      wl12xx: add max_sched_scan_ssids value to the hw description

Mathieu Desnoyers (1):
      sendmmsg/sendmsg: fix unsafe user pointer access

Mohammed Shafi Shajakhan (1):
      ath9k: Fix PS wrappers in ath9k_set_coverage_class

Nicolas de Peslo=FCan (1):
      MAINTAINERS: Update GIT trees for network development

Paul Bolle (1):
      Bluetooth: btusb: be quiet on device disconnect

Peter Hurley (15):
      Bluetooth: rfcomm: Remove unnecessary krfcommd event
      Bluetooth: rfcomm: Fix lost wakeups waiting to accept socket
      Bluetooth: Fix lost wakeups waiting for sock state change
      Bluetooth: l2cap: Fix lost wakeups waiting to accept socket
      Bluetooth: sco: Fix lost wakeups waiting to accept socket
      Bluetooth: bnep: Fix lost wakeup of session thread
      Bluetooth: cmtp: Fix lost wakeup of session thread
      Bluetooth: l2cap: Fix lost wakeup waiting for ERTM acks
      Bluetooth: bnep: Fix deadlock in session deletion
      Bluetooth: cmtp: Fix deadlock in session deletion
      Bluetooth: hidp: Fix session cleanup on failed conn add
      Bluetooth: hidp: Fix memory leak of cached report descriptor
      Bluetooth: hidp: Only free input device if failed register
      Bluetooth: hidp: Don't release device ref if never held
      Bluetooth: cmtp: Fix session cleanup on failed conn add

Ricardo Mendoza (1):
      Bluetooth: Add Toshiba laptops AR30XX device ID

Senthil Balasubramanian (1):
      ath9k_hw: Fix STA (AR9485) bringup issue due to incorrect MAC add=
ress

Stanislaw Gruszka (2):
      mac80211: fix suspend/resume races with unregister hw
      rt2x00: do not drop usb dev reference counter on suspend

Szymon Janc (1):
      Bluetooth: Don't use cmd_timer to timeout HCI reset command

Yan, Zheng (2):
      mcast: Fix source address selection for multicast listener report
      bridge: Pseudo-header required for the checksum of ICMPv6

Yoshihiro Shimoda (1):
      net: sh_eth: fix the compile error

fran=E7ois romieu (1):
      cassini: init before use in cas_interruptN.

 MAINTAINERS                                    |    4 +-
 drivers/bcma/main.c                            |   12 ++++++
 drivers/bluetooth/ath3k.c                      |    1 +
 drivers/bluetooth/btusb.c                      |   13 +++++--
 drivers/net/can/ti_hecc.c                      |    3 +-
 drivers/net/cassini.c                          |    3 +-
 drivers/net/ibmveth.c                          |   12 +++++--
 drivers/net/phy/national.c                     |   17 ++++++---
 drivers/net/sh_eth.c                           |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    2 +-
 drivers/net/wireless/ath/ath9k/main.c          |    4 ++
 drivers/net/wireless/ath/carl9170/main.c       |    4 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.c        |   14 +-------
 drivers/net/wireless/wl12xx/main.c             |    1 +
 drivers/net/wireless/wl12xx/sdio.c             |    2 +-
 drivers/net/wireless/wl12xx/testmode.c         |   45 ----------------=
--------
 include/net/cfg80211.h                         |    3 ++
 net/bluetooth/af_bluetooth.c                   |    6 ++--
 net/bluetooth/bnep/bnep.h                      |    1 +
 net/bluetooth/bnep/core.c                      |   13 ++++---
 net/bluetooth/cmtp/capi.c                      |    3 +-
 net/bluetooth/cmtp/cmtp.h                      |    1 +
 net/bluetooth/cmtp/core.c                      |   20 ++++++----
 net/bluetooth/hci_core.c                       |    8 +++--
 net/bluetooth/hidp/core.c                      |   19 +++++-----
 net/bluetooth/l2cap_core.c                     |    6 ++--
 net/bluetooth/l2cap_sock.c                     |   30 ++++++++--------
 net/bluetooth/rfcomm/core.c                    |   17 ++++-----
 net/bluetooth/rfcomm/sock.c                    |   28 +++++++-------
 net/bluetooth/sco.c                            |   28 +++++++-------
 net/bridge/br_multicast.c                      |   21 +++++++----
 net/core/neighbour.c                           |    8 +++-
 net/core/netpoll.c                             |    4 ++-
 net/ipv4/igmp.c                                |    2 +-
 net/ipv6/mcast.c                               |    2 +-
 net/mac80211/main.c                            |    2 +-
 net/socket.c                                   |   10 +++--
 net/wireless/core.c                            |    7 ++++
 net/wireless/sysfs.c                           |    6 ++-
 39 files changed, 200 insertions(+), 183 deletions(-)
