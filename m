From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 18 Dec 2014 16:39:11 -0500 (EST)
Message-ID: <20141218.163911.458380841299798040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix NBMA tunnel mac header handling in GRE, from Timo Ter=E4s.

2) Fix a NAPI race in the fec driver, from Nimrod Andy.

3) The new IFF_VNET_LE bit is outside the size of the flags
   member it is stored in (which is 16-bits), store the state
   locally in the drivers.  From Michael S. Tsirkin.

4) We are kicking the tires with the new wireless maintainership
   situation.  Bluetooth fixes via Johan Hedberg, and mac80211
   fixes from Johannes Berg.

5) Fix locking and leaks in geneve driver, from Jesse Gross.

6) Make netlink TX mmap code always copy, so we don't have to
   be potentially exposed to the user changing the underlying
   contents from underneath us.

Please pull, thank a lot!

The following changes since commit 67e2c3883828b39548cee2091b3665678777=
5d95:

  Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/=
jmorris/linux-security (2014-12-14 20:36:37 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 86c8fc4bbe14b8950e62d379bb57722427ad3d67=
:

  Merge tag 'mac80211-for-davem-2014-12-18' of git://git.kernel.org/pub=
/scm/linux/kernel/git/jberg/mac80211 (2014-12-18 15:33:49 -0500)

----------------------------------------------------------------

Andreas M=FCller (1):
      mac80211: fix multicast LED blinking and counter

Arik Nemtsov (2):
      cfg80211: avoid mem leak on driver hint set
      cfg80211: correctly check ad-hoc channels

Asaf Vertz (1):
      cirrus: cs89x0: fix time comparison

Brian Norris (1):
      brcmsmac: don't leak kernel memory via printk()

Cyrille Pitchen (2):
      net/macb: fix misplaced call of free_netdev() in macb_remove()
      net/macb: remove useless calls of devm_free_irq()

David Miller (1):
      netlink: Always copy on mmap TX.

David S. Miller (8):
      Merge branch 'mlx4'
      Merge branch 'macb'
      Merge branch 'fixed_phy'
      Merge branch 'vnet_le'
      net: Allow FIXED_PHY to be modular.
      Merge tag 'master-2014-12-15' of git://git.kernel.org/.../linvill=
e/wireless
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge tag 'mac80211-for-davem-2014-12-18' of git://git.kernel.org=
/.../jberg/mac80211

David Vrabel (2):
      xen-netfront: use napi_complete() correctly to prevent Rx stallin=
g
      xen-netback: support frontends without feature-rx-notify again

Duan Jiong (1):
      fib_trie.txt: fix typo

Emmanuel Grumbach (2):
      mac80211: update the channel context after channel switch
      cfg80211: don't WARN about two consecutive Country IE hint

=46engguang Wu (1):
      Bluetooth: fix err_cast.cocci warnings

=46lorian Fainelli (3):
      net: bcmgenet: always select FIXED_PHY
      net: systemport: always select FIXED_PHY
      net: dsa: bcm_sf2: always select FIXED_PHY

Geert Uytterhoeven (2):
      net: stmmac: sti: Fix uninitialized pointer dereference if !OF
      rds: Fix min() warning in rds_message_inc_copy_to_user()

Hariprasad Shenai (1):
      cxgb4: Fix decoding QSA module for ethtool get settings

Ido Shamay (1):
      net/mlx4: Cache line CQE/EQE stride fixes

Jaganath Kanakkassery (2):
      Bluetooth: Fix missing hci_dev_lock/unlock in mgmt req_complete()
      Bluetooth: Fix missing hci_dev_lock/unlock in hci_event

Janne Heikkinen (1):
      Bluetooth: Add USB device 04ca:3010 as Atheros AR3012

Jes Sorensen (1):
      mac80211: avoid using uninitialized stack data

Jesse Gross (2):
      geneve: Remove socket and offload handlers at destruction.
      geneve: Fix races between socket add and release.

Jiri Benc (1):
      bnx2x: fix typos in "configure"

Johan Hedberg (5):
      Bluetooth: Fix calling hci_conn_put too early
      Bluetooth: Fix incorrect pending cmd removal in pairing_complete(=
)
      Bluetooth: Fix notifying mgmt power off before flushing connectio=
n list
      Bluetooth: Fix enabling BR/EDR SC when powering on
      Bluetooth: Fix mgmt response status when removing adapter

Johannes Berg (1):
      mac80211: free management frame keys when removing station

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth-next
      MAINTAINERS: changes for wireless

Jouni Malinen (1):
      cfg80211: Fix 160 MHz channels with 80+80 and 160 MHz drivers

Julia Lawall (3):
      zd1211rw: fix misspelling of current function in string
      hostap_cs: fix misspelling of current function in string
      rtlwifi: rtl8821ae: fix misspelling of current function in string

Larry Finger (1):
      rtlwifi: rtl8192ce: Set fw_ready flag

Luciano Coelho (1):
      nl80211: check matches array length before acessing it

Marcel Holtmann (5):
      Bluetooth: Check for force_lesc_support when enabling SMP over BR=
/EDR
      Bluetooth: Check for force_lesc_support before rejecting SMP over=
 BR/EDR
      Bluetooth: Fix generation of non-resolvable private addresses
      Bluetooth: Fix check for support for page scan related commands
      Bluetooth: Fix bug with filter in service discovery optimization

Matan Barak (1):
      net/mlx4_core: Fixed memory leak and incorrect refcount in mlx4_l=
oad_one

Michael S. Tsirkin (5):
      macvtap: fix uninitialized access on TUNSETIFF
      if_tun: add TUNSETVNETLE/TUNGETVNETLE
      tun: drop broken IFF_VNET_LE
      macvtap: drop broken IFF_VNET_LE
      if_tun: drop broken IFF_VNET_LE

Nimrod Andy (1):
      net: fec: Fix NAPI race

Or Gerlitz (2):
      net/mlx4_core: Avoid double dumping of the PF device capabilities
      net: Disallow providing non zero VLAN ID for NIC drivers FDB add =
flow

Sriharsha Basavapatna (1):
      be2net: Fix incorrect setting of tunnel offload flag in netdev fe=
atures

Thomas Graf (3):
      ip_tunnel: Add sanity checks to ip_tunnel_encap_add_ops()
      ip_tunnel: Add missing validation of encap type to ip_tunnel_enca=
p_setup()
      netlink: Don't reorder loads/stores before marking mmap netlink f=
rame as available

Timo Ter=E4s (1):
      gre: fix the inner mac header in nbma tunnel xmit path

Tobias Klauser (1):
      net: smc91x: Fix build without gpiolib

Wei Yongjun (1):
      rtlwifi: rtl8192cu: Fix sparse non static symbol warning

 Documentation/networking/fib_trie.txt            |  4 +--
 MAINTAINERS                                      | 19 ++++++--------
 drivers/bluetooth/ath3k.c                        |  2 ++
 drivers/bluetooth/btusb.c                        |  1 +
 drivers/net/dsa/Kconfig                          |  2 +-
 drivers/net/ethernet/broadcom/Kconfig            |  4 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  4 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |  4 +--
 drivers/net/ethernet/cadence/macb.c              | 25 +++++++---------=
--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c       |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h    |  2 +-
 drivers/net/ethernet/cirrus/cs89x0.c             | 27 ++++++++++------=
----
 drivers/net/ethernet/emulex/benet/be_main.c      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c        | 19 ++++++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  5 ++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 11 ++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.c          | 30 ++++++++++++----=
------
 drivers/net/ethernet/mellanox/mlx4/fw.h          |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c        | 62 ++++++++++++++++=
++++++++---------------------
 drivers/net/ethernet/smsc/Kconfig                |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c  | 10 ++++----
 drivers/net/macvtap.c                            | 30 ++++++++++++++++=
+-----
 drivers/net/phy/Kconfig                          |  4 +--
 drivers/net/phy/Makefile                         |  2 +-
 drivers/net/phy/{fixed.c =3D> fixed_phy.c}         |  0
 drivers/net/tun.c                                | 26 ++++++++++++++++=
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c   |  2 +-
 drivers/net/wireless/hostap/hostap_cs.c          | 15 ++++-------
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c      |  2 ++
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c      |  2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c      | 11 ++++----
 drivers/net/wireless/zd1211rw/zd_chip.c          |  6 ++---
 drivers/net/xen-netback/common.h                 |  4 ++-
 drivers/net/xen-netback/interface.c              |  4 ++-
 drivers/net/xen-netback/netback.c                | 27 ++++++++++------=
----
 drivers/net/xen-netback/xenbus.c                 | 12 ++++++---
 drivers/net/xen-netfront.c                       | 11 +++-----
 include/linux/phy_fixed.h                        |  2 +-
 include/uapi/linux/if_tun.h                      |  3 ++-
 net/bluetooth/hci_conn.c                         |  2 +-
 net/bluetooth/hci_core.c                         | 60 ++++++++++++++++=
++++++++++------------------
 net/bluetooth/hci_event.c                        | 20 +++++++++++++++
 net/bluetooth/l2cap_core.c                       |  5 ++--
 net/bluetooth/mgmt.c                             | 99 ++++++++++++++++=
++++++++++++++++++++++++++++++++++----------------------
 net/bluetooth/smp.c                              |  5 ++--
 net/core/rtnetlink.c                             |  5 ++++
 net/ipv4/geneve.c                                | 30 ++++++++++++++++=
+-----
 net/ipv4/ip_gre.c                                |  9 ++++---
 net/ipv4/ip_tunnel.c                             |  9 +++++++
 net/mac80211/chan.c                              |  4 +++
 net/mac80211/key.c                               |  2 +-
 net/mac80211/mlme.c                              |  1 +
 net/mac80211/rx.c                                | 11 ++++----
 net/netlink/af_netlink.c                         | 54 +++++++++++++---=
-----------------------
 net/rds/message.c                                |  3 ++-
 net/wireless/chan.c                              |  9 ++++---
 net/wireless/nl80211.c                           |  2 +-
 net/wireless/reg.c                               | 20 +++++++++------
 58 files changed, 454 insertions(+), 297 deletions(-)
 rename drivers/net/phy/{fixed.c =3D> fixed_phy.c} (100%)
