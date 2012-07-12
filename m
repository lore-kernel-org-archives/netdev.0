From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-07-12
Date: Thu, 12 Jul 2012 14:15:40 -0400
Message-ID: <20120712181539.GB25494@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44934 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877Ab2GLSdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 14:33:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 38a00840638b4932152bca48098dbfa069d942a2

Dave,

Here is another batch of updates intended for 3.6.

Several drivers see updates: mwifiex, ath9k, iwlwifi, brcmsmac,
wlcore/wl12xx/wl18xx, and a handful of others.  The bcma bus got a
lot of attention from Hauke Mehrtens.  The cfg80211 component gets
a flurry of patches for multi-channel support, and the mac80211
component gets the first few VHT (11ac) and 60GHz (11ad) patches.
This also includes the removal of the iwmc3200 drivers, since the
hardware never became available to normal people.

Additionally, the NFC subsystem gets a series of updates.  According to
Samuel, "Here are the interesting bits:

- A better error management for the HCI stack.
- An LLCP "late" binding implementation for a better NFC SAP usage. SAPs are
  now reserved only when there's a client for it.
- Support for Sony RC-S360 (a.k.a. PaSoRi) pn533 based dongle. We can read =
and
  write NFC tags and also establish a p2p link with this dongle now.
- A few LLCP fixes."

Finally, this includes another pull of the fixes from the wireless
tree in order to resolve some merge issues.

Please let me know if there problems!

Thanks,

John

P.S.  This includes the bcma fix for the build issue on MIPS mentioned
in response to the previous pull request.

---

The following changes since commit 391e5c22f5f4e55817f8ba18a08ea717ed2d4a1f:

  ipv4: Remove tb_peers from fib_table. (2012-07-12 09:39:28 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 38a00840638b4932152bca48098dbfa069d942a2:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-07-12 13:44:50 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: add set_antenna handler support

Arend van Spriel (1):
      brcmsmac: fix brcms_c_regd_init() which crashed after 11ad patch

Arik Nemtsov (9):
      wlcore/wl12xx/wl18xx: check min FW version
      wlcore: don't stop tx queue via watermark if already stopped
      wlcore: remove recover cmd from testmode
      wlcore: avoid debug prints during intended FW recovery
      wlcore: always clear recovery flag during recovery_work
      wlcore: don't set SDIO_FAILED flag when driver state is off
      wlcore: define number of supported bands internally
      wl12xx/wl18xx: use a dynamic PS timeout of 1.5sec
      wlcore: determine AP extra rates correctly

Avinash Patil (6):
      mwifiex: pass cfg80211_beacon_data to mwifiex_set_mgmt_ie()
      mwifiex: separate IE parsing for Head/Tail IEs and beacon_ies etc
      mwifiex: overwrite earlier IE buffers for new set IE request
      mwifiex: add change_beacon cfg80211 handler
      mwifiex: advertise WPS probe response offload support to cfg80211
      mwifiex: parse WPS IEs from beacon_data

Christian Lamparter (2):
      carl9170: import 1.9.6 firmware headers
      carl9170: fix HT peer BA session corruption

Dan Carpenter (1):
      wlcore: fix a couple small memory leaks

Eliad Peller (6):
      mac80211: flush queues before deauth/disassoc
      mac80211: don't require associated->beacon_ies for ps
      mac80211: allow calling ieee80211_ap_probereq_get() during auth/assoc
      mac80211: always set in_reconfig=3Dfalse on wakeup
      wlcore: implement .flush callback
      wlcore: check ssid length against the correct element

Emmanuel Grumbach (2):
      iwlwifi: configure the queues from the op_mode
      iwlwifi: disable the watchdog for queues by default

Eric Lapuyade (15):
      NFC: Prepare asynchronous error management for driver and shdlc
      NFC: Removed addressed shdlc TODOs
      NFC: Handle SHDLC RSET frames from an SHDLC connected chip
      NFC: Remove an impossible HCI error case
      NFC: Implement HCP reaggregation allocation error case
      NFC: Changed HCI cmd execution completion result to std linux errno
      NFC: Driver failure API
      NFC: Factorize HCI cmd completion
      NFC: Implement HCI driver or internal error management
      NFC: Core must test the device polling state inside the device lock
      NFC: nfc_targets_found() should accept zero target found
      NFC: nfc_driver_failure() implementation
      NFC: Error management documentation
      NFC: update PN544 HCI driver state when opened/closed
      NFC: Allow HCI driver to pre-open pipes to some gates

Gabor Juhos (20):
      ath9k: define DEVID for QCA955x
      ath9k: define MAC version for AR9550
      ath9k: set MAC version for AR9550
      ath9k: add platform_device_id for AR9550
      ath9k: add BB name string for AR9550
      ath9k: clear pciexpress flag for AR9550
      ath9k: enable TX/RX data byte swap for AR9550
      ath9k: add initvals for AR9550
      ath9k: add mode register initialization code for AR9550
      ath9k: read spur frequency information from eeprom for AR9550
      ath9k: fix XPABIASLEVEL settings for AR9550
      ath9k: fix antenna control configuration for AR9550
      ath9k: fix PAPRD settings for AR9550
      ath9k: fix RF channel frequency configuration for AR9550
      ath9k: disable SYNC_HOST1_FATAL interrupts for AR9550
      ath9k: skip internal regulator configuration for AR9550
      ath9k: fix PLL initialization for AR9550
      ath9k: enable PLL workaround for AR9550
      ath9k: set 4ADDRESS bit in RX filter for AR9550
      ath9k: enable support for AR9550

Hauke Mehrtens (28):
      bcma: extend workaround for bcm4331
      bcma: add constants for chip ids
      bcma: remove fix for 4329b0 bad LPOM is detection
      bcma: add PCI ID for BCM43224
      bcma: complete workaround for BCMA43224 and BCM4313
      bcma: remove bcma_pmu_{pll,swreg}_init()
      bcma: remove chip ids doing nothing from PMU initialization.
      bcma: add bcma_pmu_spuravoid_pllupdate()
      bcma: add mdelay bcma_pmu_resources_init()
      brcmsmac: remove PCIE() macro
      brcmsmac: remove PCI_FORCEHT() macro
      brcmsmac: remove ai_get_buscore{type,rev}()
      brcmsmac: use container_of instead of cast
      brcmsmac: remove ai_findcore()
      brcmsmac: remove si_pmu_init() and si_pmu_res_init()
      brcmsmac: remove si_pmu_spuravoid_pllupdate()
      brcmsmac: remove some redundant chip common workarounds
      brcmsmac: use core id constants from bcma
      brcmsmac: use chip and package id constants from bcma
      brcmsmac: remove some unnessessacry casts and void pointer
      brcmsmac: add a conditions for core rev 17 again
      brcmsmac: add some workarounds for other chips again
      brcmsmac: extend xmtfifo_sz array
      brcmsmac: fix DMA on SoCs
      brcmsmac: extend brcms_c_chipmatch() to also handle non PCIe devices
      brcmsmac: fix read in write_phy_reg
      brcmsmac: handle non PCI devices in the phy code
      bcma: add PMU clock support for BCM4706

Ido Yariv (1):
      wlcore: Prevent processing of work items during op_stop

Johannes Berg (17):
      iwlwifi: bump trace message limit
      iwlwifi: use __get_str in tracing
      iwlwifi: limit dwell time more strictly
      mac80211: make __ieee80211_recalc_idle static
      cfg80211: don't allow WoWLAN support without CONFIG_PM
      mac80211: don't expose ieee80211_add_srates_ie()
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      iwlwifi: add trailing newline to some messages
      iwlwifi: fix debug message level
      mac80211: remove tx_frags driver callback
      mac80211_hwsim: fix NUM_BANDS usage
      mac80211: add TX prepare API
      iwlwifi: remove unneeded NULL check
      cfg80211: fix locking regression in monitor channel tracking
      mac80211: fix debugfs default key links
      mac80211: fix crash with single-queue drivers
      mac80211_hwsim: add testmode code to stop/wake queues

John W. Linville (7):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.sipsolutions.net/mac80211-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      iwmc3200wifi: remove driver for unavailable hardware
      i2400m: remove SDIO device support
      iwmc3200top: remove driver for unavailable hardware
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Luciano Coelho (1):
      wl12xx/wlcore: increase FW filename version

Luis R. Rodriguez (1):
      ath5k: replace modparam_all_channels with CONFIG_ATH5K_TEST_CHANNELS

Mahesh Palivela (3):
      wireless: add VHT (802.11ac) definitions
      cfg80211: allow advertising VHT capabilities
      mac80211: include VHT capability IE in probe requests

Michal Kazior (13):
      cfg80211: introduce cfg80211_stop_ap
      cfg80211: .stop_ap when interface is going down
      cfg80211: add channel tracking for AP and mesh
      cfg80211: track ibss fixed channel
      cfg80211: introduce cfg80211_get_chan_state
      cfg80211: track monitor interfaces count
      mac80211: refactor virtual monitor code
      cfg80211: refuse to .set_monitor_channel when non-monitors are present
      cfg80211: track monitor channel
      cfg80211: set initial monitor channel
      cfg80211/mac80211: remove .get_channel
      cfg80211: add channel checking for iface combinations
      cfg80211: respect iface combinations when starting operation

Mohammed Shafi Shajakhan (3):
      ath9k: Fix clearing of BTCOEX flags
      ath9k: Fix MCI cleanup
      ath9k: Stop the BTCOEX timers before disabling BTCOEX

Oskar Schirmer (1):
      net/wireless: remove macro defined twice with same value

Rafa=C5=82 Mi=C5=82ecki (3):
      b43: N-PHY: fix RSSI calibration
      bcma: use custom printing functions
      bcma: fix CC driver compilation on MIPS

Rajkumar Manoharan (6):
      ath9k_hw: start noisefloor calibration after MCI reset
      ath9k_hw: do not load noise floor readings when it is running
      ath9k: fix fullsleep power consumption when BTCOEX is enabled
      ath9k: fix power consumption on network sleep when BTCOEX is enabled
      ath9k_hw: fix AR9462 2g5g switch on full reset
      ath9k_hw: remove debugging masks from AR_MCI_INTERRUPT_RX_MSG_DEFAULT

Richard A. Griffiths (1):
      iwlwifi: disallow log_event access if interface down

Samuel Ortiz (18):
      NFC: Add modules alias for NFC sockets
      NFC: Add netlink module alias for NFC
      NFC: Update LLCP socket target index when getting a connection
      NFC: Fix LLCP getname socket op
      NFC: Build LLCP general bytes upon request
      NFC: Close listening LLCP sockets when the device is gone
      NFC: Release LLCP SAP when the owner is released
      NFC: Forbid LLCP service name reusing
      NFC: Forbid SSAP binding to a not well known LLCP service
      NFC: LLCP late binding
      NFC: Handle LLCP Disconnected Mode frames
      NFC: Remove warning from nfc_llcp_local_put
      NFC: Do not return EBUSY when stopping a poll that's already stopped
      NFC: Dereference LLCP bind socket address after checking for it to be=
 NULL
      NFC: Add initial Sony RC-S360 support to pn533
      NFC: Use communicate thru only for PaSoRi when trying to read Felica =
tags
      NFC: Add ISO 14443 type B protocol
      NFC: Check for llcp_sock and its device from llcp_sock_getname

Stanislaw Gruszka (3):
      rt2x00pci: small 3290 changes cleanup
      rt2800lib: merge same defines
      rt2x00: remove unused argument

Thomas Huehn (2):
      mac80211: reduce IEEE80211_TX_MAX_RATES
      ath9k: fixing register bit shift values of control packets to support=
 TPC

Victor Goldenshtein (1):
      wlcore: enable sched scan while connected

Vladimir Kondratiev (5):
      cfg80211: add 802.11ad (60gHz band) support
      wireless: regulatory for 60g
      wireless: 60g protocol constants
      {nl,cfg}80211: support high bitrates
      cfg80211: bitrate calculation for 60g

Yoni Divinsky (2):
      wlcore: add probe request templates for sched and one-shot scans
      wlcore: change the wait for event mechanism

 Documentation/nfc/nfc-hci.txt                      |   33 +
 MAINTAINERS                                        |    8 -
 drivers/bcma/bcma_private.h                        |    9 +
 drivers/bcma/core.c                                |   10 +-
 drivers/bcma/driver_chipcommon.c                   |    5 +-
 drivers/bcma/driver_chipcommon_pmu.c               |  369 +++--
 drivers/bcma/driver_mips.c                         |   24 +-
 drivers/bcma/driver_pci_host.c                     |   18 +-
 drivers/bcma/host_pci.c                            |    5 +-
 drivers/bcma/main.c                                |   19 +-
 drivers/bcma/scan.c                                |   24 +-
 drivers/bcma/sprom.c                               |   26 +-
 drivers/misc/Kconfig                               |    1 -
 drivers/misc/Makefile                              |    1 -
 drivers/misc/iwmc3200top/Kconfig                   |   20 -
 drivers/misc/iwmc3200top/Makefile                  |   29 -
 drivers/misc/iwmc3200top/debugfs.c                 |  137 --
 drivers/misc/iwmc3200top/debugfs.h                 |   58 -
 drivers/misc/iwmc3200top/fw-download.c             |  358 ----
 drivers/misc/iwmc3200top/fw-msg.h                  |  113 --
 drivers/misc/iwmc3200top/iwmc3200top.h             |  205 ---
 drivers/misc/iwmc3200top/log.c                     |  348 ----
 drivers/misc/iwmc3200top/log.h                     |  171 --
 drivers/misc/iwmc3200top/main.c                    |  662 --------
 drivers/net/wimax/i2400m/Kconfig                   |   22 -
 drivers/net/wimax/i2400m/Makefile                  |    8 -
 drivers/net/wimax/i2400m/driver.c                  |    3 +-
 drivers/net/wimax/i2400m/fw.c                      |    3 +-
 drivers/net/wimax/i2400m/i2400m-sdio.h             |  157 --
 drivers/net/wimax/i2400m/i2400m.h                  |   13 +-
 drivers/net/wimax/i2400m/sdio-debug-levels.h       |   22 -
 drivers/net/wimax/i2400m/sdio-fw.c                 |  210 ---
 drivers/net/wimax/i2400m/sdio-rx.c                 |  301 ----
 drivers/net/wimax/i2400m/sdio-tx.c                 |  177 --
 drivers/net/wimax/i2400m/sdio.c                    |  602 -------
 drivers/net/wireless/Kconfig                       |    1 -
 drivers/net/wireless/Makefile                      |    2 -
 drivers/net/wireless/ath/ath5k/Kconfig             |    8 +
 drivers/net/wireless/ath/ath5k/base.c              |   17 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    2 +
 drivers/net/wireless/ath/ath9k/ahb.c               |    4 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   13 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    7 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   87 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   18 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   72 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    6 +-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   | 1284 +++++++++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +
 drivers/net/wireless/ath/ath9k/gpio.c              |   25 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   46 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/ath9k/mac.c               |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |   16 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +
 drivers/net/wireless/ath/ath9k/reg.h               |   16 +-
 drivers/net/wireless/ath/carl9170/carl9170.h       |   11 +
 drivers/net/wireless/ath/carl9170/fw.c             |    3 +
 drivers/net/wireless/ath/carl9170/fwdesc.h         |    3 +
 drivers/net/wireless/ath/carl9170/main.c           |    6 +
 drivers/net/wireless/ath/carl9170/rx.c             |   49 +
 drivers/net/wireless/ath/carl9170/tx.c             |   69 +-
 drivers/net/wireless/ath/carl9170/version.h        |    8 +-
 drivers/net/wireless/b43/phy_n.c                   |   17 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |  128 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |   16 -
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   17 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |   15 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    3 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   87 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |   22 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |  140 +-
 drivers/net/wireless/brcm80211/brcmsmac/pmu.c      |  172 +-
 drivers/net/wireless/brcm80211/brcmsmac/pmu.h      |    3 -
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |    2 +-
 drivers/net/wireless/brcm80211/include/soc.h       |   62 -
 drivers/net/wireless/iwlegacy/3945-rs.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |   40 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |    6 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   16 -
 drivers/net/wireless/iwlwifi/dvm/main.c            |   56 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |   37 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |   37 +
 drivers/net/wireless/iwlwifi/iwl-debug.c           |    5 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   27 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    3 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    3 -
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   36 +-
 drivers/net/wireless/iwmc3200wifi/Kconfig          |   39 -
 drivers/net/wireless/iwmc3200wifi/Makefile         |   10 -
 drivers/net/wireless/iwmc3200wifi/bus.h            |   57 -
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |  882 ----------
 drivers/net/wireless/iwmc3200wifi/cfg80211.h       |   31 -
 drivers/net/wireless/iwmc3200wifi/commands.c       | 1002 ------------
 drivers/net/wireless/iwmc3200wifi/commands.h       |  509 ------
 drivers/net/wireless/iwmc3200wifi/debug.h          |  123 --
 drivers/net/wireless/iwmc3200wifi/debugfs.c        |  488 ------
 drivers/net/wireless/iwmc3200wifi/eeprom.c         |  234 ---
 drivers/net/wireless/iwmc3200wifi/eeprom.h         |  127 --
 drivers/net/wireless/iwmc3200wifi/fw.c             |  416 -----
 drivers/net/wireless/iwmc3200wifi/fw.h             |  100 --
 drivers/net/wireless/iwmc3200wifi/hal.c            |  470 ------
 drivers/net/wireless/iwmc3200wifi/hal.h            |  237 ---
 drivers/net/wireless/iwmc3200wifi/iwm.h            |  367 -----
 drivers/net/wireless/iwmc3200wifi/lmac.h           |  484 ------
 drivers/net/wireless/iwmc3200wifi/main.c           |  847 ----------
 drivers/net/wireless/iwmc3200wifi/netdev.c         |  191 ---
 drivers/net/wireless/iwmc3200wifi/rx.c             | 1701 ----------------=
----
 drivers/net/wireless/iwmc3200wifi/rx.h             |   60 -
 drivers/net/wireless/iwmc3200wifi/sdio.c           |  509 ------
 drivers/net/wireless/iwmc3200wifi/sdio.h           |   64 -
 drivers/net/wireless/iwmc3200wifi/trace.c          |    3 -
 drivers/net/wireless/iwmc3200wifi/trace.h          |  283 ----
 drivers/net/wireless/iwmc3200wifi/tx.c             |  529 ------
 drivers/net/wireless/iwmc3200wifi/umac.h           |  789 ---------
 drivers/net/wireless/libertas/host.h               |    1 -
 drivers/net/wireless/mac80211_hwsim.c              |   12 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   76 +-
 drivers/net/wireless/mwifiex/fw.h                  |   21 +
 drivers/net/wireless/mwifiex/ie.c                  |  185 ++-
 drivers/net/wireless/mwifiex/ioctl.h               |    5 +
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   37 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   30 +
 drivers/net/wireless/p54/txrx.c                    |    6 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   29 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    8 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   10 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    5 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   20 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   26 +-
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |   14 +
 drivers/net/wireless/ti/wl18xx/main.c              |   27 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |    7 +
 drivers/net/wireless/ti/wlcore/boot.c              |   55 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   22 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    6 +-
 drivers/net/wireless/ti/wlcore/init.c              |   16 +
 drivers/net/wireless/ti/wlcore/io.c                |    6 +
 drivers/net/wireless/ti/wlcore/io.h                |   13 +-
 drivers/net/wireless/ti/wlcore/main.c              |   77 +-
 drivers/net/wireless/ti/wlcore/scan.c              |   11 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |    6 -
 drivers/net/wireless/ti/wlcore/spi.c               |    6 -
 drivers/net/wireless/ti/wlcore/testmode.c          |   13 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   25 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   16 +-
 drivers/nfc/nfcwilink.c                            |    7 +-
 drivers/nfc/pn533.c                                |  224 ++-
 drivers/nfc/pn544_hci.c                            |   37 +-
 include/linux/bcma/bcma.h                          |   30 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   37 +
 include/linux/ieee80211.h                          |  160 +-
 include/linux/nfc.h                                |   14 +-
 include/linux/nl80211.h                            |   17 +
 include/net/cfg80211.h                             |   40 +-
 include/net/mac80211.h                             |   44 +-
 include/net/nfc/hci.h                              |   19 +-
 include/net/nfc/nfc.h                              |    2 +
 net/mac80211/cfg.c                                 |   24 +-
 net/mac80211/debugfs_key.c                         |   16 +-
 net/mac80211/driver-ops.h                          |   22 +-
 net/mac80211/ieee80211_i.h                         |   11 +-
 net/mac80211/iface.c                               |  258 ++-
 net/mac80211/main.c                                |   17 +-
 net/mac80211/mesh_plink.c                          |    4 +-
 net/mac80211/mlme.c                                |   28 +-
 net/mac80211/trace.h                               |    7 +
 net/mac80211/tx.c                                  |   16 +-
 net/mac80211/util.c                                |   49 +-
 net/nfc/core.c                                     |   38 +-
 net/nfc/hci/command.c                              |   26 +-
 net/nfc/hci/core.c                                 |  104 +-
 net/nfc/hci/hci.h                                  |   12 +-
 net/nfc/hci/shdlc.c                                |   38 +-
 net/nfc/llcp/llcp.c                                |  342 ++--
 net/nfc/llcp/llcp.h                                |    5 +
 net/nfc/llcp/sock.c                                |   31 +-
 net/nfc/nci/core.c                                 |    5 +-
 net/nfc/nci/ntf.c                                  |    5 +-
 net/nfc/netlink.c                                  |    9 +
 net/wireless/Makefile                              |    2 +-
 net/wireless/ap.c                                  |   46 +
 net/wireless/chan.c                                |   62 +-
 net/wireless/core.c                                |   84 +-
 net/wireless/core.h                                |   64 +-
 net/wireless/ibss.c                                |   11 +
 net/wireless/mesh.c                                |   30 +-
 net/wireless/mlme.c                                |   17 +
 net/wireless/nl80211.c                             |   65 +-
 net/wireless/reg.c                                 |    5 +-
 net/wireless/util.c                                |  156 +-
 net/wireless/wext-compat.c                         |    9 +-
 198 files changed, 4692 insertions(+), 15819 deletions(-)
 delete mode 100644 drivers/misc/iwmc3200top/Kconfig
 delete mode 100644 drivers/misc/iwmc3200top/Makefile
 delete mode 100644 drivers/misc/iwmc3200top/debugfs.c
 delete mode 100644 drivers/misc/iwmc3200top/debugfs.h
 delete mode 100644 drivers/misc/iwmc3200top/fw-download.c
 delete mode 100644 drivers/misc/iwmc3200top/fw-msg.h
 delete mode 100644 drivers/misc/iwmc3200top/iwmc3200top.h
 delete mode 100644 drivers/misc/iwmc3200top/log.c
 delete mode 100644 drivers/misc/iwmc3200top/log.h
 delete mode 100644 drivers/misc/iwmc3200top/main.c
 delete mode 100644 drivers/net/wimax/i2400m/i2400m-sdio.h
 delete mode 100644 drivers/net/wimax/i2400m/sdio-debug-levels.h
 delete mode 100644 drivers/net/wimax/i2400m/sdio-fw.c
 delete mode 100644 drivers/net/wimax/i2400m/sdio-rx.c
 delete mode 100644 drivers/net/wimax/i2400m/sdio-tx.c
 delete mode 100644 drivers/net/wimax/i2400m/sdio.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar955x_1p0_initvals.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/Kconfig
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/Makefile
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/bus.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/cfg80211.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/cfg80211.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/commands.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/commands.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/debug.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/debugfs.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/eeprom.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/eeprom.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/fw.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/fw.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/hal.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/hal.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/iwm.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/lmac.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/main.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/netdev.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/rx.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/rx.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/sdio.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/sdio.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/trace.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/trace.h
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/tx.c
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/umac.h
 create mode 100644 net/wireless/ap.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP/xRLAAoJEJctW/TcYTgG+44P/2TWf+VQwzAcmFlxCgEXkdFu
IQT6Zvb3c2i+ZPke5gHczDrT8WkwoOQSoIfOfouI5vIeeYRFDlrhGTcE/jYKAX2I
hx8DkcDcg5H3C84UDu00FnwHyCKP/ToiHNlj2YyuxrD0aMfrM+DSYotl/Ps7Aq9s
idFzDYSGOJt7o5lo+IG73V07wWNFRkXWYyAynkP4UEYNuD1cdPsY3ZqlMRw6RXVI
gHz2gvfFQmqmqg9OWFAnj5fXZbwk6I4I43ogPnE7uBRBVOYSYKtB4tuyxN5zlcZD
T85xgP/mchT0TUjKMczYVNfUBlEVvI4ISmThtTasmM65fHk5pTxZjBN5qrnDkww0
01BWP3XGhl7wCV2L2dDQKKfYhlZWEQLjoOmA3Qp0fKtrm1TYjkytGCNbktcxJjZe
cVHC9lqmnOuGADkL6QdZNDjT4fzbjU2aFnDjwgbkC2lwxZ8QlnWaVbw4TRmoVXzA
b3YTNguRDqj9WU946OBUblmKvUavJvxFaQShf79S0MDZyBtGmgVE9lUOOZjUIZ4l
Kbnd4pOZMFO9QaRK9bDiGR4Hzra08Gj7nkdNVpSZ5DtlRl3fVps2A22+W19jz2l3
GgScUDIJxuQWlK0b7h0JH0sMrcSP/wpirToKj1LhVlYGhBcFTvFZhA9roVkPBdNz
U7bRNLRFKV/KYE61wYFA
=ypk7
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--
