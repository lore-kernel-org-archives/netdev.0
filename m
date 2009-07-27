From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 27 Jul 2009 13:35:10 -0700 (PDT)
Message-ID: <20090727.133510.149375201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754655AbZG0UfH@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Enable smc91x to work on Nomadik evaluation ARM borads.
   From Alessandro Rubini

2) Build fix, KS8851 needs MII, from Alexander Beregalov

3) WoL got busted in ixgbe, fix from Andy Gospodarek.

4) Fixed-link support in fs_enet/gianfar/ucc_geth/of-mdio was
   broken unintentionally, fix from Anton Vorontsov.

5) irda memcpys into a spinlock, forgets to initialize it,
   lockdep gets angry, fix from Deepak Saxena

6) ixgbe counts UDP checksum errors that aren't due to an errata,
   fix from Don Skidmore

7) Broadcom CNIC driver doesn't handle ISCSI_KEVENT_IF_DOWN messages
   properly, fix from Michael Chan.

8) Turn WoL on by default in skge if supported, from Rafael J. Wysocki.

9) ROSE protocol uses static buffer for computing procfs output
   strings, which doesn't work very well on SMP, fix from Ralf Baechle

10) When bridging's br_add_if fails, we don't release kobjects properly=
,
    fix from Xiaotian Feng

11) Fix WoL for 8169 chips, from Fran=E7ois Romieu.

12) Several out-of-bounds array access fixes from Roel Kluin
    (eepro, fealnx, at1700, tokenring)

13) Netxen driver fix for suspend/resume, wasn't resetting the
    consumer ring pointer properly.  Fix from Dhananjay Phadke.

14) Wireless fixes from John Linville and the wireless crew.

Please pull, thanks a lot!

The following changes since commit e00b95debb9a0f023b61abcd4b1e74f68727=
6b47:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../bp/bp

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: Bug fix in the non-lro path. Size of received packet was =
not updated in statistics properly.

Alan Jenkins (3):
      rfkill: fix rfkill_set_states() to set the hw state
      rfkill: remove too-strict __must_check
      acer-wmi: fix rfkill conversion

Alessandro Rubini (1):
      smc91x.h: add config for Nomadik evaluation kit

Alexander Beregalov (1):
      net: KS8851 needs to depend on MII

Andy Gospodarek (1):
      ixgbe: remove unnecessary call to device_init_wakeup

Andy Whitcroft (1):
      rt2x00: Fix chipset detection for rt2500usb

Anton Vorontsov (4):
      of/mdio: Add support function for Ethernet fixed-link property
      fs_enet: Revive fixed link support
      gianfar: Revive fixed link support
      ucc_geth: Revive fixed link support

Bob Copeland (1):
      ath5k: temporarily disable crypto for AP mode

Christian Lamparter (1):
      cfg80211: double free in __cfg80211_scan_done

Dan Carpenter (1):
      p54spi: fix potential null deref in p54spi.c

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Deepak Saxena (1):
      net: irda: init spinlock after memcpy

Dhananjay Phadke (1):
      netxen: reset ring consumer during cleanup

Don Skidmore (1):
      ixgbe: fix for 82599 errata marking UDP checksum errors

Javier Cardona (1):
      mac80211: use correct address for mesh Path Error

Johannes Berg (4):
      mac80211: disable mesh
      rfkill: allow toggling soft state in sysfs again
      mac80211_hwsim: fix unregistration
      mac80211_hwsim: fix use after free

Larry Finger (1):
      rtl8187: Fix for kernel oops when unloading with LEDs enabled

Lucy Liu (1):
      ixgbe: Don't priority tag control frames in DCB mode

Luis R. Rodriguez (2):
      ath9k: Tune ANI function processing on AP mode during ANI reset
      ath: add support for special 0x8000 regulatory domain

Marek Vasut (1):
      libertas: Fix problem with broken V4 firmware on CF8381

Mark Ware (1):
      net: Rework mdio-ofgpio driver to use of_mdio infrastructure

Michael Chan (1):
      cnic: Fix ISCSI_KEVENT_IF_DOWN message handling.

Niko Jokinen (1):
      nl80211: Memory leak fixed

Pavel Roskin (1):
      mac80211: fix injection in monitor mode

Rafael J. Wysocki (1):
      skge: Enable WoL by default if supported

Ralf Baechle (1):
      NET: ROSE: Don't use static buffer.

Reinette Chatre (2):
      iwlwifi: only show active power level via sysfs
      iwlwifi: only update byte count table during aggregation

Roel Kluin (1):
      eepro: Read buffer overflow

Uwe Kleine-K=F6nig (1):
      register at91_ether using platform_driver_probe

Xiaotian Feng (1):
      net/bridge: use kobject_put to release kobject in br_add_if error=
 path

Yi Zou (1):
      ixgbe: Enable FCoE offload when DCB is enabled for 82599

Zhu Yi (1):
      iwmc3200wifi: fix NULL pointer dereference in iwm_if_free

fran=E7ois romieu (1):
      r8169: WakeOnLan fix for the 8168

roel kluin (3):
      fealnx: Write outside array bounds
      at1700: Read buffer overflow
      tokenring: Read buffer overflow

 drivers/net/Kconfig                         |    1 +
 drivers/net/arm/at91_ether.c                |    3 +-
 drivers/net/at1700.c                        |    2 +-
 drivers/net/benet/be_main.c                 |    8 ++--
 drivers/net/cnic.c                          |   23 +++++++-
 drivers/net/eepro.c                         |    2 +-
 drivers/net/fealnx.c                        |    3 +-
 drivers/net/fs_enet/fs_enet-main.c          |   20 ++++----
 drivers/net/gianfar.c                       |   24 +++------
 drivers/net/ixgbe/ixgbe.h                   |    1 +
 drivers/net/ixgbe/ixgbe_dcb_nl.c            |   24 ++++++++
 drivers/net/ixgbe/ixgbe_main.c              |   52 +++++++++++-------
 drivers/net/netxen/netxen_nic_init.c        |    7 +++
 drivers/net/phy/mdio-gpio.c                 |   77 ++++++++++++-------=
-------
 drivers/net/r8169.c                         |   13 ++++-
 drivers/net/skge.c                          |    4 +-
 drivers/net/smc91x.h                        |    3 +-
 drivers/net/tokenring/ibmtr.c               |    2 +-
 drivers/net/ucc_geth.c                      |   23 +++------
 drivers/net/wireless/ath/ath5k/base.c       |    3 +
 drivers/net/wireless/ath/ath9k/ani.c        |   12 ++++
 drivers/net/wireless/ath/regd.c             |   17 ++++++
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c  |    2 +-
 drivers/net/wireless/libertas/cmd.c         |    8 +++-
 drivers/net/wireless/libertas/defs.h        |    2 +
 drivers/net/wireless/mac80211_hwsim.c       |    6 +-
 drivers/net/wireless/p54/p54spi.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    4 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c |    3 +-
 drivers/of/of_mdio.c                        |   42 +++++++++++++++
 drivers/platform/x86/acer-wmi.c             |    2 +-
 include/linux/of_mdio.h                     |    3 +
 include/linux/rfkill.h                      |    2 +-
 include/net/rose.h                          |    2 +-
 net/bridge/br_if.c                          |    2 +-
 net/irda/irttp.c                            |    1 +
 net/mac80211/Kconfig                        |    1 +
 net/mac80211/mesh_pathtbl.c                 |   11 +++-
 net/mac80211/tx.c                           |    2 +-
 net/rfkill/core.c                           |   31 ++++++++---
 net/rose/af_rose.c                          |   18 +++----
 net/rose/rose_route.c                       |   23 ++++----
 net/wireless/nl80211.c                      |    5 +-
 net/wireless/scan.c                         |    3 +-
 47 files changed, 336 insertions(+), 174 deletions(-)
