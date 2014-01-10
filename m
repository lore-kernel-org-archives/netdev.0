From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-01-10
Date: Fri, 10 Jan 2014 13:38:54 -0500
Message-ID: <20140110183853.GH2131@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56455 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbaAJSpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:45:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--z6Eq5LdranGa6ru8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull these updates for the 3.14 stream!

For the mac80211 bits, Johannes says:

"Felix adds some helper functions for P2P NoA software tracking, Joe
fixes alignment (but as this apparently never caused issues I didn't
send it to 3.13), Kyeyoon/Jouni add QoS-mapping support (a Hotspot 2.0
feature), Weilong fixed a bunch of checkpatch errors and I get to play
fire-fighter or so and clean up other people's locking issues. I also
added nl80211 vendor-specific events, as we'd discussed at the wireless
summit."

For the iwlwifi bits, Emmanuel says:

"I have here a rework of the interrupt handling to meet RT kernel
requirements - basically we don't take any lock in the primary interrupt
handler. This gave me a good reason to clean things up a bit on the way.
There is also a fix of the QoS mapping along with a few workarounds for
hardware / firmware issues that are hard to hit.
Three fixes suggested by static analyzers, and other various stuff.
Most importantly, I update the Copyright note to include the new year."

For the bluetooth bits, Gustavo says:

"More patches to 3.14. The bulk of changes here is the 6LoWPAN support for
Bluetooth LE Devices. The commits that touches net/ieee802154/ are already
acked by David Miller. Other than that we have some RFCOMM fixes and
improvements plus fixes and clean ups all over the tree."

Beyond that, ath9k, brcmfmac, mwifiex, and wil6210 get their usual
level of attention.  The wl1251 driver gets a number of updates,
and there are a handful of other bits here and there.

Please let me know if there are problems!

John

---

The following changes since commit 11b57f90257c1d6a91cee720151b69e0c2020cf6:

  xen-netback: stop vif thread spinning if frontend is unresponsive (2014-0=
1-09 23:05:46 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 235f93922878234f3d99a4205ebe3634ee955919:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-01-10 10:59:40 -0500)

----------------------------------------------------------------

Alexander Aring (9):
      6lowpan: fix/move/cleanup debug functions
      6lowpan: introduce lowpan_push_hc_data function
      6lowpan: udp use lowpan_push_hc_data function
      6lowpan: fix udp compress ordering
      6lowpan: fix udp byte ordering
      6lowpan: add udp warning for elided checksum
      6lowpan: udp use lowpan_fetch_skb function
      6lowpan: udp use subtraction on both conditions
      6lowpan: cleanup udp compress function

Arend van Spriel (14):
      brcmfmac: rework SDIO register access functions
      brcmfmac: cleanup helper functions in sdio remove path
      brcmfmac: cleanup helper functions in sdio probe path
      brcmfmac: correct reporting HT40 support in wiphy htcap
      brcmfmac: add sdio drive strength programming for bcm4334 chipset
      brcmfmac: correct detection of save&restore device capability
      brcmfmac: enable watchdog when bus initialization is complete
      brcmfmac: only disable clock when brcmf_sdio_bus_init() fails
      brcmfmac: inform cfg80211 when changing the CONNECTED state
      brcmfmac: move wiphy_unregister() call to brcmf_cfg80211_detach()
      brcmfmac: call brcmf_cfg80211_detach() after removal of interfaces
      brcmfmac: use custom destructor callback for all netdevice interfaces
      mmc: add SDIO identifiers for Broadcom WLAN devices
      brcmfmac: add support for bcm43362 device

Arik Nemtsov (1):
      iwlwifi: mvm: squash a spurious warning on chnctx change

Bing Zhao (2):
      mwifiex: fix potential buffer overflow in dt configuration
      mwifiex: use a function to replace two copies of a code fragment

Christian Engelmayer (1):
      wireless: cw1200: Fix memory leak in cw1200_wow_suspend()

Claudio Takahasi (2):
      Bluetooth: Fix setting Universal/Local bit
      Bluetooth: Fix 6loWPAN peer lookup

David Gnedt (11):
      wl1251: fix scan behaviour while not associated
      wl1251: retry power save entry
      wl1251: implement hardware ARP filtering
      wl1251: split RX and TX data path initialisation
      wl1251: configure hardware en-/decryption for monitor mode
      wl1251: implement multicast address filtering (fwd)
      wl1251: disable power saving in monitor mode
      wl1251: fix channel switching in monitor mode
      wl1251: enable tx path in monitor mode if necessary for packet inject=
ion
      wl1251: disable retry and ACK policy for injected packets
      wl1251: enforce changed hw encryption support on monitor state change

Emmanuel Grumbach (20):
      iwlwifi: pcie: clean up ICT allocation code
      iwlwifi: pcie: track interrupt mask in SW
      iwlwifi: pcie: re-organize the PCIe ISR code
      iwlwifi: pcie: move the ICT / non-ICT handling functions
      iwlwifi: pcie: read the interrupt cause from the handler
      iwlwifi: pcie: determine the interrupt type in the handler
      iwlwifi: pcie: return inta from iwl_pcie_int_cause_{non_}ict
      iwlwifi: pcie: no need to save inta in trans_pcie
      iwlwifi: pcie: move interrupt prints to the common handler
      iwlwifi: pcie: use don't disable interrupt when irq_lock is taken
      iwlwifi: pcie: use don't disable interrupt when rxq->lock is taken
      iwlwifi: mvm: fix AC / FIFO mapping
      iwlwifi: pcie: keep the NIC awake when commands are in flight
      iwlwifi: pcie: don't update the op_mode if rfkill hasn't changed
      iwlwifi: pcie: allow the op_mode to call stop_device whenever it wants
      iwlwifi: mvm: disable the device as soon as RFKILL fires
      iwlwifi: mvm: fix harmless smatch / coccinelle warnings
      iwlwifi: mvm: BT Coex - update channel inihibition for channel 14
      iwlwifi: mvm: dump to debugfs the SRAM as binary
      iwlwifi: Update Copyright to 2014

Eran Harary (1):
      iwlwifi: pcie: Fix CSR_RESET operation access type

Eyal Shapira (1):
      iwlwifi: mvm: rs: fix a potential NULL deref

Eytan Lifshitz (1):
      iwlwifi: mvm: fix possible memory leak

Felix Fietkau (3):
      mac80211: add helper functions for tracking P2P NoA state
      ath9k_hw: fix gentimer callback without overflow handler
      ath9k_hw: fix TSF offset calculation

Fengguang Wu (1):
      iwlwifi: mvm: fix coccinelle warnings

Gianluca Anzolin (4):
      Bluetooth: Release RFCOMM port when the last user closes the TTY
      Bluetooth: Move rfcomm_get_device() before rfcomm_dev_activate()
      Bluetooth: Always wait for a connection on RFCOMM open()
      Bluetooth: Remove rfcomm_carrier_raised()

Hante Meuleman (2):
      brcmfmac: Remove some obsolete definitions and variables.
      brcmfmac: Limit control message length from host to device.

Hauke Mehrtens (2):
      bcma: fix sparse warnings in driver_chipcommon_sflash.c
      ssb: fix sparse warnings in driver_chipcommon_sflash.c

Ilan Peer (3):
      iwlwifi: mvm: Add a missed beacons threshold
      iwlwifi: mvm: change the parameters for calculating an AP TBTT
      iwlwifi: mvm: dynamically update tsf_id

Joe Perches (1):
      mac80211: align struct ps_data.tim to unsigned long

Johan Hedberg (4):
      Bluetooth: Add missing 6lowpan.h include
      Bluetooth: Fix test for lookup_dev return value
      Bluetooth: Fix NULL pointer dereference when disconnecting
      Bluetooth: Default to no security with L2CAP RAW sockets

Johannes Berg (4):
      mac80211: make ieee80211_recalc_radar_chanctx static
      mac80211: remove unnecessary iflist_mtx locking
      mac80211: fix iflist_mtx/mtx locking in radar detection
      nl80211: support vendor-specific events

John W. Linville (5):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Josh Triplett (1):
      net: wireless: brcm80211: Drop debug version with build date/time

Jukka Rissanen (5):
      6lowpan: Moving generic compression code into 6lowpan_iphc.c
      net: if_arp: add ARPHRD_6LOWPAN type
      ipv6: Add checks for 6LOWPAN ARP type
      Bluetooth: Enable 6LoWPAN support for BT LE devices
      Bluetooth: Manually enable or disable 6LoWPAN between devices

Julia Lawall (10):
      rt2x00: use ether_addr_equal_64bits
      ath5k: use ether_addr_equal_64bits
      p54: use ether_addr_equal_64bits
      mwl8k: use ether_addr_equal_64bits
      rtlwifi: use ether_addr_equal_64bits
      iwlegacy: use ether_addr_equal_64bits
      ath9k: use ether_addr_equal_64bits
      ipw2x00: use ether_addr_equal_64bits
      at76c50x-usb: use ether_addr_equal_64bits
      carl9170: use ether_addr_equal_64bits

Kyeyoon Park (2):
      cfg80211: Add support for QoS mapping
      mac80211: Add support for QoS mapping

Marcel Holtmann (5):
      Bluetooth: Set HCI_QUIRK_RESET_ON_CLOSE for Socket SDIO cards
      Bluetooth: Add support for vectored writes to virtual HCI driver
      Bluetooth: Use MD SET register for changing SDIO Type-B to Type-A
      Bluetooth: Add quirk for disabling Delete Stored Link Key command
      Bluetooth: Deal with USB devices that are faking CSR vendor

Paul Gortmaker (1):
      wireless: delete non-required instances of include <linux/init.h>

Pavel Machek (2):
      wl1251: add nvs file name to module firmware list
      wl1251: fix NULL pointer dereference

Sujith Manoharan (28):
      ath9k: Fix max AMPDU size calculation
      ath9k: Register supported HW hang checks
      ath9k: Add HW callbacks for MAC/BB hang checks
      ath9k: Fix MAC HW hang check for AR9003
      ath9k: Fix PHY restart workaround
      ath9k: Fix baseband watchdog interrupts
      ath9k: Identify baseband watchdog signatures
      ath9k: Fix baseband watchdog reset
      ath9k: Remove RX Poll
      ath9k: Process BB watchdog events in the tasklet
      ath9k: Fix "cc_lock" usage
      ath9k: Remove unused functions
      ath9k: Move private HW callbacks to hw-ops.h
      ath9k: Handle unsupported MAC versions early
      ath9k: Cleanup __ath9k_hw_init()
      ath9k: Fix AR9100 chip power-on
      ath9k: Remove unused config option ack_6mb
      ath9k: Fix interrupt statistics
      ath9k: Add version/revision macros for QCA9531
      ath9k: Assign macVersion for QCA9531
      ath9k: Add QCA953x initvals
      ath9k: Initialize QCA953x INI arrays
      ath9k: Add hardware support for QCA9531
      ath9k: Fix AR955x RX sensitivity
      ath9k: Fix regulatory compliance
      ath9k: Update WB335 PCI IDs
      ath9k: Use correct channel for RX packets
      ath9k: Disable cross-band FCC

Vladimir Kondratiev (3):
      wil6210: interrupt moderation
      wil6210: Fix IP version indication for Tx csum offload
      wil6210: prefetch head of packet

Wei Yongjun (3):
      Bluetooth: remove unused including <linux/version.h>
      Bluetooth: fix return value check
      ath9k: fix sparse non static symbol warning

Weilong Chen (1):
      mac80211: fix checkpatch errors

Wenliang Fan (1):
      drivers/net/wireless/hostap: Integer overflow

 drivers/bcma/driver_chipcommon_sflash.c            |   6 +-
 drivers/bluetooth/btsdio.c                         |   6 +-
 drivers/bluetooth/btusb.c                          |  46 +-
 drivers/bluetooth/hci_vhci.c                       |  29 +-
 drivers/net/wireless/adm8211.c                     |   1 -
 drivers/net/wireless/airo_cs.c                     |   1 -
 drivers/net/wireless/at76c50x-usb.c                |   2 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |   1 -
 drivers/net/wireless/ath/ath5k/base.c              |   4 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  15 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      | 223 ++++++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  13 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         | 161 +++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  91 ++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |  17 +-
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   | 718 +++++++++++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |   7 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |  10 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   2 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |  42 +
 drivers/net/wireless/ath/ath9k/hw.c                | 323 +++-----
 drivers/net/wireless/ath/ath9k/hw.h                |  28 +-
 drivers/net/wireless/ath/ath9k/init.c              |   2 -
 drivers/net/wireless/ath/ath9k/link.c              |  67 +-
 drivers/net/wireless/ath/ath9k/mac.c               |  24 +-
 drivers/net/wireless/ath/ath9k/main.c              |  76 +-
 drivers/net/wireless/ath/ath9k/pci.c               | 101 ++-
 drivers/net/wireless/ath/ath9k/recv.c              |  31 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  14 +-
 drivers/net/wireless/ath/ath9k/spectral.c          |   2 +-
 drivers/net/wireless/ath/ath9k/wow.c               |   1 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   9 +-
 drivers/net/wireless/ath/carl9170/debug.c          |   1 -
 drivers/net/wireless/ath/carl9170/main.c           |   1 -
 drivers/net/wireless/ath/carl9170/rx.c             |   7 +-
 drivers/net/wireless/ath/carl9170/tx.c             |   1 -
 drivers/net/wireless/ath/wil6210/interrupt.c       |  13 +
 drivers/net/wireless/ath/wil6210/txrx.c            |   8 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   1 +
 drivers/net/wireless/atmel.c                       |   1 -
 drivers/net/wireless/atmel_cs.c                    |   1 -
 drivers/net/wireless/atmel_pci.c                   |   1 -
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |  10 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   | 230 +++---
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   7 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   9 -
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   9 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 167 ++--
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  43 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  46 ++
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |   8 -
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   1 -
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 164 ++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   5 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   1 +
 .../net/wireless/brcm80211/include/brcmu_wifi.h    |  14 +
 drivers/net/wireless/cw1200/fwio.c                 |   1 -
 drivers/net/wireless/cw1200/main.c                 |   1 -
 drivers/net/wireless/cw1200/pm.c                   |  11 +-
 drivers/net/wireless/hostap/hostap_cs.c            |   1 -
 drivers/net/wireless/hostap/hostap_ioctl.c         |   2 +-
 drivers/net/wireless/hostap/hostap_pci.c           |   1 -
 drivers/net/wireless/hostap/hostap_plx.c           |   1 -
 drivers/net/wireless/ipw2x00/ipw2200.h             |   1 -
 drivers/net/wireless/ipw2x00/libipw_rx.c           |   2 +-
 drivers/net/wireless/iwlegacy/3945-rs.c            |   1 -
 drivers/net/wireless/iwlegacy/3945.c               |   5 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |   1 -
 drivers/net/wireless/iwlegacy/4965.c               |   1 -
 drivers/net/wireless/iwlegacy/common.c             |   9 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   4 +-
 drivers/net/wireless/iwlwifi/dvm/calib.c           |   4 +-
 drivers/net/wireless/iwlwifi/dvm/calib.h           |   4 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |   4 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |   2 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         |   2 +-
 drivers/net/wireless/iwlwifi/dvm/led.c             |   3 +-
 drivers/net/wireless/iwlwifi/dvm/led.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   3 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   3 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   2 +-
 drivers/net/wireless/iwlwifi/dvm/power.c           |   3 +-
 drivers/net/wireless/iwlwifi/dvm/power.h           |   2 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |   3 +-
 drivers/net/wireless/iwlwifi/dvm/rs.h              |   2 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |   2 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |   2 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |   2 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/tt.c              |   3 +-
 drivers/net/wireless/iwlwifi/dvm/tt.h              |   2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   3 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |   3 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   2 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |   4 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   4 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   7 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |   2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   4 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |   6 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |   4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |   4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.c     |   4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.h     |   4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |   4 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   4 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   4 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   2 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   2 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |   4 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |   4 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.h      |   4 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   4 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |   4 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   4 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |   4 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |   4 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   4 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  11 +-
 drivers/net/wireless/iwlwifi/mvm/binding.c         |   4 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |   8 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |   4 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   4 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |   4 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  53 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.h         |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-bt-coex.h  |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   4 +-
 drivers/net/wireless/iwlwifi/mvm/led.c             |   6 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        | 160 ++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  24 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   7 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  15 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   6 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |   4 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |   5 +-
 drivers/net/wireless/iwlwifi/mvm/power_legacy.c    |   4 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   4 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  14 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   2 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   4 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  13 +-
 drivers/net/wireless/iwlwifi/mvm/sf.c              |   4 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   4 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |   4 +-
 drivers/net/wireless/iwlwifi/mvm/testmode.h        |   4 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   4 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |   4 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   4 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   4 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   4 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   4 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |  40 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             | 400 ++++------
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  79 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             | 106 ++-
 drivers/net/wireless/mwifiex/cfg80211.c            |   9 +-
 drivers/net/wireless/mwifiex/main.c                |   2 +-
 drivers/net/wireless/mwifiex/main.h                |   1 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   5 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  17 +-
 drivers/net/wireless/mwl8k.c                       |   3 +-
 drivers/net/wireless/orinoco/hermes.c              |   1 -
 drivers/net/wireless/orinoco/orinoco_cs.c          |   1 -
 drivers/net/wireless/orinoco/orinoco_usb.c         |   1 -
 drivers/net/wireless/orinoco/spectrum_cs.c         |   1 -
 drivers/net/wireless/p54/eeprom.c                  |   1 -
 drivers/net/wireless/p54/fwio.c                    |   1 -
 drivers/net/wireless/p54/led.c                     |   1 -
 drivers/net/wireless/p54/main.c                    |   1 -
 drivers/net/wireless/p54/p54pci.c                  |   1 -
 drivers/net/wireless/p54/p54usb.c                  |   1 -
 drivers/net/wireless/p54/txrx.c                    |   3 +-
 drivers/net/wireless/rndis_wlan.c                  |   1 -
 drivers/net/wireless/rt2x00/rt2400pci.c            |   1 -
 drivers/net/wireless/rt2x00/rt2500pci.c            |   1 -
 drivers/net/wireless/rt2x00/rt2500usb.c            |   1 -
 drivers/net/wireless/rt2x00/rt2800usb.c            |   1 -
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   4 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   1 -
 drivers/net/wireless/rt2x00/rt73usb.c              |   1 -
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   1 -
 drivers/net/wireless/rtl818x/rtl8180/grf5101.c     |   1 -
 drivers/net/wireless/rtl818x/rtl8180/max2820.c     |   1 -
 drivers/net/wireless/rtl818x/rtl8180/rtl8225.c     |   1 -
 drivers/net/wireless/rtl818x/rtl8180/sa2400.c      |   1 -
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   1 -
 drivers/net/wireless/rtl818x/rtl8187/rtl8225.c     |   1 -
 drivers/net/wireless/rtlwifi/base.c                |   4 +-
 drivers/net/wireless/rtlwifi/ps.c                  |   4 +-
 drivers/net/wireless/ti/wl1251/acx.c               |  49 +-
 drivers/net/wireless/ti/wl1251/acx.h               |  26 +-
 drivers/net/wireless/ti/wl1251/boot.c              |   3 +-
 drivers/net/wireless/ti/wl1251/cmd.c               |  58 +-
 drivers/net/wireless/ti/wl1251/cmd.h               |   8 +-
 drivers/net/wireless/ti/wl1251/event.c             |  46 +-
 drivers/net/wireless/ti/wl1251/event.h             |   7 +
 drivers/net/wireless/ti/wl1251/init.c              |  13 +-
 drivers/net/wireless/ti/wl1251/main.c              | 150 +++-
 drivers/net/wireless/ti/wl1251/rx.c                |   2 +-
 drivers/net/wireless/ti/wl1251/tx.c                |  35 +-
 drivers/net/wireless/ti/wl1251/wl1251.h            |   6 +
 drivers/net/wireless/wl3501_cs.c                   |   1 -
 drivers/ssb/driver_chipcommon_sflash.c             |   6 +-
 include/linux/mmc/sdio_ids.h                       |   9 +
 include/net/bluetooth/hci.h                        |   4 +-
 include/net/bluetooth/hci_core.h                   |   1 +
 include/net/bluetooth/l2cap.h                      |   1 +
 include/net/cfg80211.h                             | 118 ++-
 include/net/mac80211.h                             |  47 ++
 include/uapi/linux/if_arp.h                        |   1 +
 include/uapi/linux/nl80211.h                       |  17 +
 net/bluetooth/6lowpan.c                            | 860 +++++++++++++++++=
++++
 net/bluetooth/6lowpan.h                            |  26 +
 net/bluetooth/Makefile                             |   6 +-
 net/bluetooth/hci_core.c                           |  52 +-
 net/bluetooth/hci_event.c                          |   3 +
 net/bluetooth/l2cap_core.c                         |  12 +
 net/bluetooth/l2cap_sock.c                         |   3 +
 net/bluetooth/rfcomm/tty.c                         | 103 ++-
 net/ieee802154/6lowpan.c                           | 796 +----------------=
--
 net/ieee802154/6lowpan.h                           |  72 ++
 net/ieee802154/6lowpan_iphc.c                      | 799 +++++++++++++++++=
++
 net/ieee802154/Makefile                            |   2 +-
 net/ipv6/addrconf.c                                |   4 +-
 net/mac80211/aes_cmac.c                            |   2 +-
 net/mac80211/aes_cmac.h                            |   2 +-
 net/mac80211/cfg.c                                 |  54 +-
 net/mac80211/chan.c                                |  67 +-
 net/mac80211/ibss.c                                |   7 +
 net/mac80211/ieee80211_i.h                         |  11 +-
 net/mac80211/iface.c                               |   8 +-
 net/mac80211/mlme.c                                |  25 +-
 net/mac80211/rc80211_minstrel.c                    |   8 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   2 +-
 net/mac80211/tkip.c                                |   2 +-
 net/mac80211/trace.h                               |   2 +-
 net/mac80211/tx.c                                  |   4 +-
 net/mac80211/util.c                                | 150 +++-
 net/mac80211/wme.c                                 |   7 +-
 net/wireless/ap.c                                  |   1 +
 net/wireless/ibss.c                                |   2 +
 net/wireless/mesh.c                                |   1 +
 net/wireless/nl80211.c                             | 160 +++-
 net/wireless/rdev-ops.h                            |  15 +
 net/wireless/sme.c                                 |   2 +
 net/wireless/trace.h                               |  40 +
 net/wireless/util.c                                |  19 +-
 264 files changed, 5728 insertions(+), 2387 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar953x_initvals.h
 create mode 100644 net/bluetooth/6lowpan.c
 create mode 100644 net/bluetooth/6lowpan.h
 create mode 100644 net/ieee802154/6lowpan_iphc.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJS0D49AAoJEJctW/TcYTgG5zQP/1JUurli0iwfDhoIA8X7GgqA
IrSAWCwxCuYmrYDNTMXuQ+GahEwzGzh1JEKwnoP/yiQ7BBKEljoLwOSPJwEl+oPu
VmPX08oLVuhd33FyR446dmApZQ55qKTM92LjjK+aaiErxWRXl9r+/PCL+uPnJFlO
kH+mk8g5GzOGvHW/Y99/x3GpS47hpJBS91iipj7DiOAKtZX9ePMrUTe+y/wlGyV3
k+OhpVp3MHRM5hCRZaRxRr05A7Ae3/guDf1OsApeipt1gNdFXdGuST+x+wrGCNbY
8WA4SMkYMMc3lZa0es3sskQ8XMO2mAUs9bT9+qV5cZDwVN/MATnDvBPhfgdm2Wy5
8aBRxQo+jQDGsKy0gPflwgrz/aiNKqvTHTtkgdohrHe4o499nJ/Kj+DtRfbO+Oc/
gCJI4DheIO2RYbDIqu+gNW7FKgguI4EN+71W+O0wqs0irk7FaE4W1mRUwOfTOKKm
fVn0DuCyrWSsAtDwiFmHi2dA1QwpLq6FxuZgMUOTW683OfwYP8qo+N/Bwa22YM5G
968D3tYc7q/zwQFeEqbnbVfV73jnbc4W+6k9OH3+LK2pTQWkn9GPmQgg5x3LmbUE
7KzapLUA+gn8/nibUOcpaxhXcDQdkzzwzwBfkNkXRPQiHyPKIw0rHCqekyWZw0AT
Y0vuvCDma4TF97HtRYO6
=bUlY
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--
