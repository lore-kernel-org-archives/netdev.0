From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-05-24
Date: Tue, 24 May 2011 17:04:01 -0400
Message-ID: <20110524210400.GA8864@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the last (belated) batch of new wireless bits intended for
2.6.40.  I had intended to send this over the weekend, but there was
a dust-up over some merge confusion that had to get settled first.
In the meantime, this got a few more days to cook in -next. :-)

There isn't anything Earth-shattering here -- mostly just some
last-minute bits posted a bit before the release.  Some of them are
fixes for bugs in other new code.  There is also the addition of a
generic GPIO-based rfkill driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 557eed603159b4e007c57d97fad1333ecebd=
3c2e:

  Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/jgarzik/libata-dev (2011-05-20 14:31:27 -0700)

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-ne=
xt-2.6.git for-davem

Alexey Dobriyan (1):
      airo: correct proc entry creation interfaces

Christian Lamparter (2):
      p54usb: add zoom 4410 usbid
      carl9170: advertise interface combinations

Daniel Halperin (1):
      iwlwifi: remove unused parameter from iwl_hcmd_queue_reclaim

=46elix Fietkau (3):
      ath9k: fix ad-hoc mode beacon selection
      ath9k: fix ad-hoc nexttbtt calculation
      ath9k: implement .tx_last_beacon()

Javier Cardona (2):
      mac80211: Deactivate mesh path timers when freeing nodes
      mac80211: Don't sleep when growing the mesh path

Johannes Berg (10):
      iwlagn: prepare for multi-TB commands
      iwlagn: clean up TXQ indirection
      iwlagn: remove unused pad argument
      iwlagn: support multiple TBs per command
      iwlagn: remove set but unused vars
      iwlagn: change default beacon interval
      mac80211: verify IBSS in interface combinations
      mac80211: add missing rcu_barrier
      mac80211: fix and simplify mesh locking
      mac80211: annotate and fix RCU in mesh code

John W. Linville (2):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge ssh://master.kernel.org/.../linville/wireless-next-2.6 into=
 for-davem

Jouni Malinen (1):
      cfg80211: Use consistent BSS matching between scan and sme

Larry Finger (1):
      rtlwifi: rtl8192c-common: rtl8192ce: Fix for HT40 regression

Luciano Coelho (1):
      nl80211: remove some stack variables in trigger_scan and start_sc=
hed_scan

Marc Yang (5):
      mwifiex: reduce CPU usage by tracking tx_pkts_queued
      mwifiex: reduce CPU usage by tracking highest_queued_prio
      mwifiex: check mwifiex_wmm_lists_empty() before dequeue
      mwifiex: CPU mips optimization with NO_PKT_PRIO_TID
      mwifiex: adjust high/low water marks for tx_pending queue

Mohammed Shafi Shajakhan (2):
      ath_hw: Fix bssid mask documentation
      ath9k: use PS wakeup before REG_READ

Rafa=C5=82 Mi=C5=82ecki (8):
      b43: rename b43_wldev's field with ssb_device to sdev
      bcma: add PCI ID of the card found in Thinkpad X120e
      b43: add helpers for block R/W ops
      b43: make b43_wireless_init less bus specific
      b43: dma: cache translation (routing bits)
      b43: add helper for finding GPIO device
      b43: separate ssb core reset
      b43: read PHY info only when needed (for PHY-A)

Rajkumar Manoharan (2):
      mac80211: abort scan_work immediately when the device goes down
      ath9k: Fix power save wrappers in debug ops

Randy Dunlap (2):
      wireless: fix cfg80211.h new kernel-doc warnings
      wireless: fix fatal kernel-doc error + warning in mac80211.h

Rhyland Klein (1):
      net: rfkill: add generic gpio rfkill driver

Sujith Manoharan (9):
      ath9k_htc: Fix mode selection
      ath9k_htc: Fix station flags
      ath9k_htc: Recalculate the BSSID mask on interface
      ath9k_htc: Fix RX filter calculation
      ath9k_htc: Fix BSSID calculation
      ath9k_htc: Fix max subframe handling
      ath9k_htc: Change credit limit for UB94/95
      ath9k_htc: Fix packet timeout
      ath9k: Drag the driver to the year 2011

Wey-Yi Guy (8):
      iwlagn: more ucode error log info
      iwlagn: add testmode trace command
      iwlagn: add eeprom command to testmode
      iwlagn: add testmode set fixed rate command
      iwlagn: clear STATUS_HCMD_ACTIVE bit if fail enqueue
      iwlagn: alwasy send RXON with disassociate falge before associate
      iwlagn: remove unused old_assoc parameter
      iwlagn: dbg_fixed_rate only used when CONFIG_MAC80211_DEBUGFS ena=
bled

 drivers/bcma/host_pci.c                            |    1 +
 drivers/net/wireless/airo.c                        |   33 +--
 drivers/net/wireless/ath/ath9k/ahb.c               |    2 +-
 drivers/net/wireless/ath/ath9k/ani.c               |    2 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    2 +-
 drivers/net/wireless/ath/ath9k/ar5008_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9001_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    2 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   16 +
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    5 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   48 ++-
 drivers/net/wireless/ath/ath9k/btcoex.c            |    2 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    2 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    2 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    2 +-
 drivers/net/wireless/ath/ath9k/common.c            |    2 +-
 drivers/net/wireless/ath/ath9k/common.h            |    2 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   10 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    2 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    4 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   25 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    9 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   79 +++--
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    6 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h           |    2 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    2 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +-
 drivers/net/wireless/ath/ath9k/init.c              |    2 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   42 +++-
 drivers/net/wireless/ath/ath9k/pci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/phy.h               |    2 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/ath9k/rc.h                |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 +-
 drivers/net/wireless/ath/carl9170/carl9170.h       |    4 +
 drivers/net/wireless/ath/carl9170/fw.c             |   19 +-
 drivers/net/wireless/ath/carl9170/main.c           |   10 +-
 drivers/net/wireless/ath/hw.c                      |   10 +-
 drivers/net/wireless/b43/b43.h                     |   24 +-
 drivers/net/wireless/b43/dma.c                     |   37 +-
 drivers/net/wireless/b43/leds.c                    |    4 +-
 drivers/net/wireless/b43/lo.c                      |    4 +-
 drivers/net/wireless/b43/main.c                    |  194 ++++++-----
 drivers/net/wireless/b43/phy_a.c                   |   16 +-
 drivers/net/wireless/b43/phy_common.c              |    8 +-
 drivers/net/wireless/b43/phy_g.c                   |   48 ++--
 drivers/net/wireless/b43/phy_lp.c                  |   22 +-
 drivers/net/wireless/b43/phy_n.c                   |   24 +-
 drivers/net/wireless/b43/pio.c                     |   30 +-
 drivers/net/wireless/b43/rfkill.c                  |    6 +-
 drivers/net/wireless/b43/sdio.c                    |    4 +-
 drivers/net/wireless/b43/sysfs.c                   |    4 +-
 drivers/net/wireless/b43/tables_lpphy.c            |    4 +-
 drivers/net/wireless/b43/wa.c                      |    4 +-
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   86 +++--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  250 +++---------=
--
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   10 -
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   66 +++--
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   58 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   12 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |  177 ++++++++++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   34 ++
 drivers/net/wireless/iwlwifi/iwl-tx.c              |  364 ++++++++++++=
++------
 drivers/net/wireless/iwmc3200wifi/rx.c             |    4 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    4 +
 drivers/net/wireless/mwifiex/main.h                |    9 +-
 drivers/net/wireless/mwifiex/txrx.c                |    4 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   59 +++-
 drivers/net/wireless/p54/p54usb.c                  |    1 +
 drivers/net/wireless/rndis_wlan.c                  |    3 +-
 drivers/net/wireless/rtlwifi/ps.c                  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |   69 ++++
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    1 +
 drivers/staging/ath6kl/os/linux/cfg80211.c         |    2 +-
 drivers/staging/brcm80211/brcmfmac/wl_cfg80211.c   |    4 +-
 drivers/staging/wlan-ng/cfg80211.c                 |    2 +-
 fs/proc/generic.c                                  |    1 +
 include/linux/rfkill-gpio.h                        |   43 +++
 include/net/cfg80211.h                             |    8 +-
 include/net/mac80211.h                             |    3 +-
 net/mac80211/iface.c                               |    4 +-
 net/mac80211/main.c                                |   22 +-
 net/mac80211/mesh.h                                |    7 +-
 net/mac80211/mesh_pathtbl.c                        |  204 +++++++----
 net/mac80211/scan.c                                |    5 +
 net/rfkill/Kconfig                                 |    9 +
 net/rfkill/Makefile                                |    1 +
 net/rfkill/rfkill-gpio.c                           |  227 ++++++++++++
 net/wireless/core.h                                |    5 +-
 net/wireless/nl80211.c                             |   12 +-
 net/wireless/sme.c                                 |   19 +-
 net/wireless/util.c                                |    2 +-
 143 files changed, 1822 insertions(+), 977 deletions(-)
 create mode 100644 include/linux/rfkill-gpio.h
 create mode 100644 net/rfkill/rfkill-gpio.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-05-24.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
