From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-07-11
Date: Wed, 11 Jul 2012 14:17:22 -0400
Message-ID: <20120711181721.GC1906@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58115 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab2GKSde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 14:33:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c3e7be41a27f507047d40a31462a5ea6d7f52f10

Dave,

Here is another batch of updates intended for 3.6.

Several drivers see updates: mwifiex, ath9k, iwlwifi, and a handful
of others.  The bcma bus got a lot of attention from Hauke Mehrtens.
The cfg80211 component gets a flurry of patches for multi-channel
support, and the mac80211 component gets the first few VHT (11ac)
and 60GHz (11ad) patches.

Additionally, the NFC subsystem gets a series of updates.  According to
Samuel, "Here are the interesting bits:

- A better error management for the HCI stack.
- An LLCP "late" binding implementation for a better NFC SAP usage. SAP=
s are
  now reserved only when there's a client for it.
- Support for Sony RC-S360 (a.k.a. PaSoRi) pn533 based dongle. We can r=
ead and
  write NFC tags and also establish a p2p link with this dongle now.
- A few LLCP fixes."

=46inally, this includes another pull of the fixes from the wireless
tree in order to resolve some merge issues.

Please let me know if there problems!

Thanks,

John

---

The following changes since commit 061a5c316b6526dbc729049a16243ec27937=
cc31:

  Merge branch 'davem-next.r8169' of git://violet.fr.zoreil.com/romieu/=
linux (2012-07-09 16:09:47 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.=
git for-davem

for you to fetch changes up to c3e7be41a27f507047d40a31462a5ea6d7f52f10=
:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/linville/wireless-next into for-davem (2012-07-10 12:29:56 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: add set_antenna handler support

Arend van Spriel (1):
      brcmsmac: fix brcms_c_regd_init() which crashed after 11ad patch

Avinash Patil (6):
      mwifiex: pass cfg80211_beacon_data to mwifiex_set_mgmt_ie()
      mwifiex: separate IE parsing for Head/Tail IEs and beacon_ies etc
      mwifiex: overwrite earlier IE buffers for new set IE request
      mwifiex: add change_beacon cfg80211 handler
      mwifiex: advertise WPS probe response offload support to cfg80211
      mwifiex: parse WPS IEs from beacon_data

Bing Zhao (1):
      mwifiex: fix Coverity SCAN CID 709078: Resource leak (RESOURCE_LE=
AK)

Eliad Peller (5):
      mac80211: flush queues before deauth/disassoc
      mac80211: don't require associated->beacon_ies for ps
      mac80211: allow calling ieee80211_ap_probereq_get() during auth/a=
ssoc
      mac80211: always set in_reconfig=3Dfalse on wakeup
      mac80211: destroy assoc_data correctly if assoc fails

Emmanuel Grumbach (3):
      iwlwifi: configure the queues from the op_mode
      iwlwifi: disable the watchdog for queues by default
      iwlegacy: don't mess up the SCD when removing a key

Eric Lapuyade (15):
      NFC: Prepare asynchronous error management for driver and shdlc
      NFC: Removed addressed shdlc TODOs
      NFC: Handle SHDLC RSET frames from an SHDLC connected chip
      NFC: Remove an impossible HCI error case
      NFC: Implement HCP reaggregation allocation error case
      NFC: Changed HCI cmd execution completion result to std linux err=
no
      NFC: Driver failure API
      NFC: Factorize HCI cmd completion
      NFC: Implement HCI driver or internal error management
      NFC: Core must test the device polling state inside the device lo=
ck
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

Hauke Mehrtens (9):
      bcma: extend workaround for bcm4331
      bcma: add constants for chip ids
      bcma: remove fix for 4329b0 bad LPOM is detection
      bcma: add PCI ID for BCM43224
      bcma: complete workaround for BCMA43224 and BCM4313
      bcma: remove bcma_pmu_{pll,swreg}_init()
      bcma: remove chip ids doing nothing from PMU initialization.
      bcma: add bcma_pmu_spuravoid_pllupdate()
      bcma: add mdelay bcma_pmu_resources_init()

Johannes Berg (17):
      iwlwifi: bump trace message limit
      iwlwifi: use __get_str in tracing
      iwlwifi: limit dwell time more strictly
      mac80211: make __ieee80211_recalc_idle static
      cfg80211: don't allow WoWLAN support without CONFIG_PM
      mac80211: don't expose ieee80211_add_srates_ie()
      Merge remote-tracking branch 'wireless-next/master' into mac80211=
-next
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

John W. Linville (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss
      Merge branch 'for-john' of git://git.sipsolutions.net/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into for-davem

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
      cfg80211: refuse to .set_monitor_channel when non-monitors are pr=
esent
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

Rafa=C5=82 Mi=C5=82ecki (2):
      b43: N-PHY: fix RSSI calibration
      bcma: use custom printing functions

Rajkumar Manoharan (5):
      ath9k_hw: start noisefloor calibration after MCI reset
      ath9k_hw: do not load noise floor readings when it is running
      ath9k: fix fullsleep power consumption when BTCOEX is enabled
      ath9k: fix power consumption on network sleep when BTCOEX is enab=
led
      ath9k_hw: fix AR9462 2g5g switch on full reset

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
      NFC: Do not return EBUSY when stopping a poll that's already stop=
ped
      NFC: Dereference LLCP bind socket address after checking for it t=
o be NULL
      NFC: Add initial Sony RC-S360 support to pn533
      NFC: Use communicate thru only for PaSoRi when trying to read Fel=
ica tags
      NFC: Add ISO 14443 type B protocol
      NFC: Check for llcp_sock and its device from llcp_sock_getname

Sasha Levin (1):
      NFC: Prevent NULL deref when getting socket name

Stanislaw Gruszka (2):
      rt2x00usb: fix indexes ordering on RX queue kick
      iwlegacy: always monitor for stuck queues

Thomas Huehn (3):
      mac80211: reduce IEEE80211_TX_MAX_RATES
      mac80211: correct size the argument to kzalloc in minstrel_ht
      ath9k: fixing register bit shift values of control packets to sup=
port TPC

Vladimir Kondratiev (5):
      cfg80211: add 802.11ad (60gHz band) support
      wireless: regulatory for 60g
      wireless: 60g protocol constants
      {nl,cfg}80211: support high bitrates
      cfg80211: bitrate calculation for 60g

 Documentation/nfc/nfc-hci.txt                      |   33 +
 drivers/bcma/bcma_private.h                        |    9 +
 drivers/bcma/core.c                                |   10 +-
 drivers/bcma/driver_chipcommon.c                   |    5 +-
 drivers/bcma/driver_chipcommon_pmu.c               |  331 +++--
 drivers/bcma/driver_mips.c                         |   24 +-
 drivers/bcma/driver_pci_host.c                     |   18 +-
 drivers/bcma/host_pci.c                            |    5 +-
 drivers/bcma/main.c                                |   19 +-
 drivers/bcma/scan.c                                |   24 +-
 drivers/bcma/sprom.c                               |   26 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    2 +
 drivers/net/wireless/ath/ath9k/ahb.c               |    4 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   13 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    7 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   87 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   18 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   72 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    6 +-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   | 1284 ++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +
 drivers/net/wireless/ath/ath9k/gpio.c              |   25 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   46 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/ath9k/mac.c               |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |   16 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +
 drivers/net/wireless/ath/ath9k/reg.h               |   10 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    6 +-
 drivers/net/wireless/b43/phy_n.c                   |   17 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   17 +-
 drivers/net/wireless/iwlegacy/3945-rs.c            |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    4 +-
 drivers/net/wireless/iwlegacy/common.c             |   14 +-
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
 drivers/net/wireless/libertas/host.h               |    1 -
 drivers/net/wireless/mac80211_hwsim.c              |   12 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   77 +-
 drivers/net/wireless/mwifiex/fw.h                  |   21 +
 drivers/net/wireless/mwifiex/ie.c                  |  185 +--
 drivers/net/wireless/mwifiex/ioctl.h               |    5 +
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   37 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   30 +
 drivers/net/wireless/p54/txrx.c                    |    6 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |    2 +
 drivers/nfc/nfcwilink.c                            |    7 +-
 drivers/nfc/pn533.c                                |  224 +++-
 drivers/nfc/pn544_hci.c                            |   37 +-
 include/linux/bcma/bcma.h                          |   30 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   23 +
 include/linux/ieee80211.h                          |  160 ++-
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
 net/mac80211/iface.c                               |  258 ++--
 net/mac80211/main.c                                |   17 +-
 net/mac80211/mesh_plink.c                          |    4 +-
 net/mac80211/mlme.c                                |   34 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    2 +-
 net/mac80211/trace.h                               |    7 +
 net/mac80211/tx.c                                  |   16 +-
 net/mac80211/util.c                                |   49 +-
 net/nfc/core.c                                     |   38 +-
 net/nfc/hci/command.c                              |   26 +-
 net/nfc/hci/core.c                                 |  104 +-
 net/nfc/hci/hci.h                                  |   12 +-
 net/nfc/hci/shdlc.c                                |   38 +-
 net/nfc/llcp/llcp.c                                |  342 ++++--
 net/nfc/llcp/llcp.h                                |    5 +
 net/nfc/llcp/sock.c                                |   33 +-
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
 net/wireless/util.c                                |  156 ++-
 net/wireless/wext-compat.c                         |    9 +-
 109 files changed, 4013 insertions(+), 1053 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar955x_1p0_initvals.=
h
 create mode 100644 net/wireless/ap.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
