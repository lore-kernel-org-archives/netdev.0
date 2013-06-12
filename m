From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 12 Jun 2013 14:14:43 -0700 (PDT)
Message-ID: <20130612.141443.1482509052798358708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Small fixes in various spots, and the ath9k changes that should make
your Pixel's wireless behave better:

1) Fix dump iterator in nfnl_acct_dump() and ctnl_timeout_dump() to
   dump all objects properly, from Pablo Neira Ayuso.

2) xt_TCPMSS must use the default MSS of 536 when no MSS TCP option is
   present.  Fix from Phil Oester.

3) qdisc_get_rtab() looks for an existing matching rate table and uses =
that
   instead of creating a new one.  However, it's key matching is incomp=
lete,
   it fails to check to make sure the ->data[] array is identical too. =
 Fix
   from Eric Dumazet.

4) ip_vs_dest_entry isn't fully initialized before copying back to user=
space,
   fix from Dan Carpenter.

5) Fix ubuf reference counting regression in vhost_net, from Jason Wang=
=2E

6) When sock_diag dumps a socket filter back to userspace, we have to t=
ranslate
   it out of the kernel's internal representation first.  From Nicolas
   Dichtel.

7) davinci_mdio holds a spinlock while calling pm_runtime, which sleeps=
=2E  Fix
   from Sebastian Siewior.

8) Timeout check in sh_eth_check_reset is off by one, from Sergei Shtyl=
yov.

9) If sctp socket init fails, we can NULL deref during cleanup.  Fix fr=
om
   Daniel Borkmann.

10) netlink_mmap() does not propagate errors properly, from Patrick McH=
ardy.

11) Disable powersave and use minstrel by default in ath9k.  From
    Sujith Manoharan.

12) Fix a regression in that SOCK_ZEROCOPY is not set on tuntap sockets=
 which
    prevents vhost from being able to use zerocopy.  From Jason Wang.

13) Fix race between port lookup and TX path in team driver, from Jiri =
Pirko.

14) Missing length checks in bluetooth L2CAP packet parsing, from
    Johan Hedberg.

15) rtlwifi fails to connect to networking using any encryption method =
other
    than WPA2.  Fix from Larry Finger.

16) Fix iwlegacy build due to incorrect CONFIG_* ifdeffing for power
    management stuff.  From Yijing Wang.

Please pull, thanks a lot!

The following changes since commit 1612e111e4e565422242727efb59499cce87=
38e4:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-0=
6-06 18:09:05 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 090adb893137ff3c672a644413edc174b0a75706=
:

  Merge branch 'wireless' (2013-06-12 13:35:24 -0700)

----------------------------------------------------------------

Bing Zhao (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8897

Bj=F8rn Mork (1):
      qmi_wwan/cdc_ether: let qmi_wwan handle the Huawei E1820

Dan Carpenter (1):
      ipvs: info leak in __ip_vs_get_dest_entries()

Daniel Borkmann (1):
      net: sctp: fix NULL pointer dereference in socket destruction

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'wireless'

Eliad Peller (1):
      wl12xx/wl18xx: scan all 5ghz channels

Eric Dumazet (1):
      net_sched: qdisc_get_rtab() must check data[] array

=46elix Fietkau (1):
      Revert "ath9k_hw: Update rx gain initval to improve rx sensitivit=
y"

Jason Wang (3):
      vhost_net: clear msg.control for non-zerocopy case during tx
      tuntap: fix a possible race between queue selection and changing =
queues
      tuntap: set SOCK_ZEROCOPY flag during open

Jiri Pirko (3):
      team: check return value of team_get_port_by_index_rcu() for NULL
      team: move add to port list before port enablement
      team: fix checks in team_get_first_port_txable_rcu()

Johan Hedberg (3):
      Bluetooth: Fix checks for LE support on LE-only controllers
      Bluetooth: Fix missing length checks for L2CAP signalling PDUs
      Bluetooth: Fix mgmt handling of power on failures

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Kees Cook (1):
      b43: stop format string leaking into error msgs

Larry Finger (2):
      rtlwifi: rtl8192cu: Fix problem in connecting to WEP or WPA(1) ne=
tworks
      rtlwifi: Fix a false leak indication for PCI devices

Luciano Coelho (2):
      wl12xx: fix minimum required firmware version for wl127x multirol=
e
      wl12xx: increase minimum singlerole firmware version required

Mark A. Greer (1):
      mwifiex: debugfs: Fix out of bounds array access

Michael S. Tsirkin (2):
      vhost: check owner before we overwrite ubuf_info
      vhost: fix ubuf_info cleanup

Nicolas Dichtel (1):
      sock_diag: fix filter code sent to userspace

Pablo Neira Ayuso (3):
      netfilter: nfnetlink_acct: fix incomplete dumping of objects
      netfilter: nfnetlink_cttimeout: fix incomplete dumping of objects
      netfilter: nfnetlink_queue: fix missing HW protocol

Patrick McHardy (1):
      netlink: fix error propagation in netlink_mmap()

Phil Oester (1):
      netfilter: xt_TCPMSS: Fix violation of RFC879 in absence of MSS o=
ption

Sebastian Siewior (1):
      net/ti davinci_mdio: don't hold a spin lock while calling pm_runt=
ime

Sergei Shtylyov (1):
      sh_eth: fix result of sh_eth_check_reset() on timeout

Sujith Manoharan (2):
      ath9k: Disable PowerSave by default
      ath9k: Use minstrel rate control by default

Yijing Wang (1):
      net: wireless: iwlegacy: fix build error for il_pm_ops

 drivers/bluetooth/Kconfig                            |   4 +--
 drivers/bluetooth/btmrvl_sdio.c                      |  28 +++++++++++=
+++++
 drivers/net/ethernet/renesas/sh_eth.c                |   4 +--
 drivers/net/ethernet/ti/davinci_mdio.c               |   5 ++-
 drivers/net/team/team.c                              |   2 +-
 drivers/net/team/team_mode_random.c                  |   2 ++
 drivers/net/team/team_mode_roundrobin.c              |   2 ++
 drivers/net/tun.c                                    |   4 ++-
 drivers/net/usb/cdc_ether.c                          |   6 ++++
 drivers/net/usb/qmi_wwan.c                           |   1 +
 drivers/net/wireless/ath/ath9k/Kconfig               |  10 ++++--
 drivers/net/wireless/ath/ath9k/Makefile              |   2 +-
 drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h |  10 +++---
 drivers/net/wireless/ath/ath9k/init.c                |   7 +---
 drivers/net/wireless/ath/ath9k/rc.h                  |   2 +-
 drivers/net/wireless/b43/main.c                      |   2 +-
 drivers/net/wireless/iwlegacy/common.h               |   6 ++--
 drivers/net/wireless/mwifiex/debugfs.c               |  22 +++++++++--=
-
 drivers/net/wireless/rtlwifi/pci.c                   |   1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c          | 134 +++++++++++=
++++++++++++++++++++++++++++++++++++++++++++-------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h          |   4 ---
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c         |  18 +++++++++-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c          |   4 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h          |   3 ++
 drivers/net/wireless/rtlwifi/usb.c                   |  13 ++++++++
 drivers/net/wireless/rtlwifi/wifi.h                  |   4 +++
 drivers/net/wireless/ti/wl12xx/scan.c                |   2 +-
 drivers/net/wireless/ti/wl12xx/wl12xx.h              |   6 ++--
 drivers/net/wireless/ti/wl18xx/scan.c                |   2 +-
 drivers/vhost/net.c                                  |  29 ++++++++---=
-----
 drivers/vhost/vhost.c                                |   8 ++++-
 drivers/vhost/vhost.h                                |   1 +
 include/linux/filter.h                               |   1 +
 include/linux/if_team.h                              |   4 +--
 include/net/bluetooth/hci_core.h                     |   1 +
 include/net/bluetooth/mgmt.h                         |   1 +
 net/bluetooth/hci_core.c                             |   6 +++-
 net/bluetooth/l2cap_core.c                           |  70 +++++++++++=
++++++++++++++++++----------
 net/bluetooth/mgmt.c                                 |  23 +++++++++++=
+-
 net/bluetooth/smp.c                                  |   4 +--
 net/core/filter.c                                    |   2 +-
 net/core/sock_diag.c                                 |   9 +++--
 net/netfilter/ipvs/ip_vs_ctl.c                       |   1 +
 net/netfilter/nfnetlink_acct.c                       |   7 ++--
 net/netfilter/nfnetlink_cttimeout.c                  |   7 ++--
 net/netfilter/nfnetlink_queue_core.c                 |   6 ++--
 net/netfilter/xt_TCPMSS.c                            |   6 ++++
 net/netlink/af_netlink.c                             |   2 +-
 net/sched/sch_api.c                                  |  11 +++---
 net/sctp/socket.c                                    |   6 ++++
 50 files changed, 378 insertions(+), 137 deletions(-)
