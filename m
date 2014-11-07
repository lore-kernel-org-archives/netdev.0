From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-11-07
Date: Fri, 7 Nov 2014 15:30:45 -0500
Message-ID: <20141107203045.GD29733@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53727 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaKGUpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:45:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.19 stream!

For the mac80211 bits, Johannes says:

"This relatively large batch of changes is comprised of the following:
 * large mac80211-hwsim changes from Ben, Jukka and a bit myself
 * OCB/WAVE/11p support from Rostislav on behalf of the Czech Technical
   University in Prague and Volkswagen Group Research
 * minstrel VHT work from Karl
 * more CSA work from Luca
 * WMM admission control support in mac80211 (myself)
 * various smaller fixes, spelling corrections, and minor API additions"

For the Bluetooth bits, Johan says:

"Here's the first bluetooth-next pull request for 3.19. The vast majority
of patches are for ieee802154 from Alexander Aring with various fixes
and cleanups. There are also several LE/SMP fixes as well as improved
support for handling LE devices that have lost their pairing information
(the patches from Alfonso). Jukka provides a couple of stability fixes
for 6lowpan and Szymon conformance fixes for RFCOMM. For the HCI drivers
we have one new USB ID for an Acer controller as well as a reset
handling fix for H5."

For the Atheros bits, Kalle says:

"Major changes are:

o ethtool support (Ben)

o print dev string prefix with debug hex buffers dump (Michal)

o debugfs file to read calibration data from the firmware verification
  purposes (me)

o fix fw_stats debugfs file, now results are more reliable (Michal)

o firmware crash counters via debugfs (Ben&me)

o various tracing points to debug firmware (Rajkumar)

o make it possible to provide firmware calibration data via a file (me)

And we have quite a lot of smaller fixes and clean up."

For the iwlwifi bits, Emmanuel says:

"The big new thing here is netdetect which allows the
firmware to wake up the platform when a specific network
is detected. Along with that I have fixes for d3 operation.
The usual amount of rate scaling stuff - we now support STBC.
The other commit that stands out is Johannes's work on
devcoredump. He basically starts to use the standard
infrastructure he built."

Along with that are the usual sort of updates and such for ath9k,
brcmfmac, wil6210, and a handful of other bits here and there...

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 61ed53deb1c6a4386d8710dbbfcee8779c381931:

  Merge tag 'ntb-3.18' of git://github.com/jonmason/ntb (2014-10-19 12:58:2=
2 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-11-04

for you to fetch changes up to bf515fb11ab539c76d04f0e3c5216ed41f41d81f:

  Merge tag 'mac80211-next-for-john-2014-11-04' of git://git.kernel.org/pub=
/scm/linux/kernel/git/jberg/mac80211-next (2014-11-04 16:18:12 -0500)

----------------------------------------------------------------

Alexander Aring (103):
      ieee802154: 6lowpan: fix byteorder for frag tag
      ieee802154: reassembly: fix tag byteorder
      ieee802154: 6lowpan: fix sign of errno return val
      at86rf230: fix errno on tx timeout handling
      at86rf230: add missing error handling
      at86rf230: correct aret lifs and sifs handling
      at86rf230: correct at86rf2xx lifs timings
      at86rf230: squash unnecessary dereferencing
      at86rf230: add missing enable_irq
      at86rf230: fix race condition
      at86rf230: fix enable_irq handling on async spi
      at86rf230: remove unnecessary print of async error
      ieee802154: 6lowpan: improve packet registration
      ieee802154: 6lowpan: add RTNL assertion
      ieee802154: mac802154: remove FSF address
      ieee802154: ieee802154_dev: fix align typo
      mac802154: fix typo IEEE802515 to IEEE802154
      ieee802154: wpan-phy: change to __aligned(size)
      ieee802154: wpan-phy: use blank line after function
      ieee802154: wpan-class: fix trailing semicolon
      mac802154: move ieee802154_dev.c to main.c
      mac802154: move mac802154.h to ieee802154_i.h
      mac802154: move wpan.c to iface.c
      ieee802154: move wpan-phy.h to cfg802154.h
      ieee802154: move wpan-class.c to core.c
      ieee802154: move ieee802154 header
      MAINTAINERS: add missing headers in 802.15.4
      ieee802154: remove fakehard driver
      ieee802154: rename ieee802154_dev to ieee802154_hw
      mac802154: rename mac802154_priv to ieee802154_local
      mac802154: rename mac802154_sub_if_data
      mac802154: rename hw subif_data variable to local
      mac802154: rename sdata slaves and slaves_mtx
      mac802154: introduce hw_to_local function
      mac802154: introduce IEEE802154_DEV_TO_SUB_IF
      mac802154: rename dev_workqueue to workqueue
      mac802154: remove ieee802154_addr from driver_ops
      mac802154: tx: move xmit callback to tx file
      mac802154: tx: remove kmalloc in xmit hotpath
      mac802154: tx: squash multiple dereferencing
      mac802154: tx: remove xmit channel context switch
      mac802154: add netdev qeue helpers
      mac802154: tx: use queue helpers in xmit worker
      mac802154: tx: fix error handling while xmit
      mac802154: tx: add support for xmit_async callback
      mac802154: tx: don't allow if down while sync tx
      mac802154: tx: use netdev print helpers
      mac802154: tx: cleanup crc calculation
      mac802154: tx: move stats tx increment
      mac802154: tx: change naming convention
      mac802154: tx: add comment at sync xmit callback
      at86rf230: asynchronous xmit handling
      mac802154: tx: make worker information static
      mac802154: tx: use put_unaligned_le16 for copy crc
      ieee802154: drivers: use dev_alloc_skb
      mac802154: rx: use tasklet instead workqueue
      mac802154: rx: document ieee802154_rx() context requirement
      mac802154: rx: move receive handling into rx.c
      mac802154: tx: remove monitor receive while xmit
      mac802154: rx: rename remove mac802154_subif_rx
      mac802154: rx: move skb->protocol setting
      mac802154: rx: add CHECKSUM_UNNECESSARY
      mac802154: rx: add monitor pkt_type information
      mac802154: rx: move skb_reset_mac_header
      mac802154: rx: move rcu locking
      ieee802154: add valid psdu length helper
      at86rf230: use ieee802154_is_valid_psdu_len helper
      at86rf230: improve receive handling
      mac802154: rx: change naming convention
      mac802154: monitor: merge into iface implementation
      mac802154: main: move open and close into iface
      mac802154: declare struct ieee802154_ops as const
      mac802154: ops: declare channel and page as u8
      mac802154: introduce driver-ops header
      mac802154: use driver-ops function wrappers
      mac802154: remove might_sleep from driver layer
      mac802154: remove driver ops in wpan-phy
      mac802154: rework sdata state change to running
      mac802154: rename running to started
      mac802154: move local started handling
      mac802154: add synchronization handling
      mac802154: iface: remove assign to zero
      mac802154: remove channel attributes from sdata
      mac802154: move mac_params functions into mac_cmd
      mac802154: cleanup open count handling
      ieee802154: introduce sysfs file
      mac802154: main: remove unnecessary include
      mac802154: remove tab after define
      mac802154: add IEEE802154_HW_ARET hw flag
      mac802154: add hardware address filter flag
      mac802154: add support for promiscuous mode
      at86rf230: add support for promiscuous mode
      mac802154: separate omit tx/rx flags
      mac802154: rx: remove unnecessary parameter
      mac802154: rx: simplify crc receive handling
      mac802154: rx: add software checksum filtering check
      mac802154: rx: remove override pkt_type set to PACKET_HOST
      mac802154: rx: use netif_receive_skb
      mac802154: rx: add rx stats incrementation
      mac802154: rx: monitor receive cleanup
      mac802154: rx: add error handling after skb_clone
      at86rf230: deliver with checksum
      mac802154: add basic support for monitor

Alfonso Acosta (4):
      Bluetooth: Refactor arguments of mgmt_device_connected
      Bluetooth: Include ADV_IND report in Device Connected event
      Bluetooth: Remove redundant check on hci_conn's device class
      Bluetooth: Defer connection-parameter removal when unpairing

Anantha Krishnan (1):
      Bluetooth: Add support for Acer [0489:e078]

Andrei Otcheretianski (2):
      mac80211: export IE splitting function
      mac80211: increase U-APSD max service period length

Arend van Spriel (5):
      brcmfmac: show firmware error as string in debug message
      brcmfmac: remove unused defintion
      brcmfmac: do not use firmware error code in driver
      brcmsmac: fix statistic counter update function
      brcmsmac: expose 802.11 core statistics in debugfs

Arik Nemtsov (5):
      mac80211: fix network header breakage during encryption
      mac80211: expose TDLS-initiator value to low level driver
      mac80211: add stations in order to the station list
      mac80211: expose API allowing station iteration
      iwlwifi: mvm: remove mvm argument from get_queues_mask

Avinash Patil (1):
      mwifiex: channel statistics support for mwifiex

Bartosz Markowski (1):
      ath10k: advertise all possible firmware(-api) files

Ben Greear (16):
      ath10k: add firmware crash counters
      ath10k: support ethtool stats
      ath10k: use 64-bit vdev map
      mac80211_hwsim: fix memory leak on netlink TX failure
      mac80211_hwsim: fix typo, remove unnecessary goto
      mac80211-hwsim: add ethtool stats support
      mac80211-hwsim: support destroying radio by name
      cfg80211: support creating wiphy with suggested name
      mac80211: allow creating wiphy devices with suggested name
      mac80211-hwsim: support creating radios with specific name
      mac80211: support creating wiphy w/out creating wlanX
      mac80211-hwsim: support creating wiphy w/out creating wlanX
      cfg80211: support configuring vif mac addr on create
      mac80211: support creating vifs with specified mac address
      mac80211-hwsim: add frequency attribute to netlink pkts
      mac80211-hwsim: support SGI-20

Dan Carpenter (3):
      ipw2x00: remove unused ->ibss_dfs pointer
      ipw2x00: clean up a condition
      Bluetooth: 6lowpan: use after free in disconnect_devices()

David Spinadel (1):
      iwlwifi: mvm: fix scan condition iterator

Eliad Peller (2):
      iwlwifi: mvm: unref SCAN ref on scan completion
      mac80211: replace restart_complete() with reconfig_complete()

Emmanuel Grumbach (13):
      iwlwifi: configure the LTR
      iwlwifi: mvm: BT Coex - update the MPLUT Boost register value
      iwlwifi: mvm: BT coex - fix BT prio for probe requests
      iwlwifi: dvm: drop non VO frames when flushing
      Revert "iwlwifi: mvm: treat EAPOLs like mgmt frames wrt rate"
      iwlwifi: pcie: fix polling in various places
      mac80211: don't flush when probing the AP
      Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-next
      iwlwifi: mvm: remove unneeded NULL pointer check
      iwlwifi: pcie: warn if extern fw_debug buffer failed
      iwlwifi: pcie: fix recovery from ARC reset in WoWLAN
      iwlwifi: mvm: BT Coex - move BT_ANTENNA_COUPLING_THRESHOLD to constan=
ts
      iwlwifi: mvm: BT Coex - make the multiprio lut a constant

Eran Harary (2):
      iwlwifi: always run the secured flow for family 8000
      ieee80211: add "max length of AMPDU" enum for VHT

Eyal Shapira (3):
      iwlwifi: rs: option to easily disable Tx MIMO
      iwlwifi: enable STBC support for 8000 chips
      iwlwifi: mvm: rs: add Tx STBC support

Fabian Frederick (5):
      net: rfkill: kernel-doc warning fixes
      mac80211: directly return ieee80211_vif_use_reserved_context()
      mac80211: remove unnecessary null test before debugfs_remove()
      Bluetooth: fix shadow warning in hci_disconnect()
      cfg80211: fix set but not used warning in nl80211_channel_switch()

Felix Fietkau (11):
      ath9k_hw: make support for PC-OEM cards optional
      ath9k_hw: remove support for UB124 tx gain table
      ath9k: fix processing RXORN interrupts
      ath9k: clean up debugfs print of reset causes
      ath9k: restart hardware after noise floor calibration failure
      ath9k_hw: do not run NF and periodic calibration at the same time
      ath9k_hw: start initial NF calibration after PA calibration on <AR9003
      ath9k: add support for endian swap of eeprom from platform data
      ath9k: allow disabling bands via platform data
      ath9k: use a random MAC address if the EEPROM address is invalid
      mac80211: add support for driver tx power reporting

Gregory Greenman (1):
      iwlwifi: allow to restrict Tx aggregation size per-device

Haim Dreyfuss (1):
      iwlwifi: mvm: Add tx power condition to bss_info_changed_ap_ibss

Hante Meuleman (13):
      brcmfmac: Add wowl support for USB devices.
      brcmfmac: Add wowl support for SDIO devices.
      brcmfmac: Add wowl patterns support.
      brcmfmac: (clean) Remove usb_rdl.h as it is not needed.
      brcmfmac: (clean) Remove packet filter configuration.
      brcmfmac: (clean) Move tracepoint related function.
      brcmfmac: (clean) Rename files dhd_dbg to debug
      brcmfmac: (clean) Rename dhd_bus.h in bus.h
      brcmfmac: (clean) Rename dhd_common.c in common.c
      brcmfmac: (clean) Rename files wl_cfg80211 to cfg80211
      brcmfmac: (clean) Rename sdio related files.
      brcmfmac: (clean) Rename sdio related files.
      brcmfmac: (clean) Move sdio related function.

Henning Rogge (2):
      cfg80211: add ops to query mesh proxy path table
      mac80211: implement cfg80211_ops to query mesh proxy path table

Janusz Dziedzic (2):
      ath10k: don't create bssid peer for ibss
      ath10k: fix WMI scan command length

Joe Perches (3):
      ath: change logging functions to return void
      iwlwifi: dvm: Fix probable mask then right shift defect
      carl9170: Convert byte_rev_table uses to bitrev8

Johan Hedberg (6):
      Bluetooth: Pass only crypto context to SMP crypto functions
      Bluetooth: Add skeleton for SMP self-tests
      Bluetooth: Add self-tests for SMP crypto functions
      Bluetooth: Revert SMP self-test patches
      Bluetooth: Fix LE connection timeout deadlock
      Bluetooth: Fix check for direct advertising

Johannes Berg (14):
      mac80211: fix change flags variable signedness
      Merge branch 'mac80211' into mac80211-next
      cfg80211: make WMM TSPEC support flag an nl80211 feature flag
      mac80211: sanity check CW_min/CW_max towards driver
      mac80211: add WMM admission control support
      mac80211: don't remove tainted keys after not programming
      iwlwifi: mvm: improve MCS rate warning
      iwlwifi: mvm: flush queues without mutex held
      iwlwifi: mvm: port to devcoredump framework
      cfg80211: fix integer signedness in chandef_primary_freqs()
      mac80211-hwsim: remove spurious newline
      mac80211-hwsim: add missing policy entries
      cfg80211: avoid using default in interface type switch
      mac80211: handle RIC data element in reassociation request

John W. Linville (4):
      Merge tag 'for-linville-20141024' of git://github.com/kvalo/ath
      Merge tag 'iwlwifi-next-for-john-2014-10-29' of git://git.kernel.org/=
=2E../iwlwifi/iwlwifi-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge tag 'mac80211-next-for-john-2014-11-04' of git://git.kernel.org=
/.../jberg/mac80211-next

Jouni Malinen (2):
      cfg80211: Convert del_station() callback to use a param struct
      cfg80211: Specify frame and reason code for NL80211_CMD_DEL_STATION

Jukka Rissanen (7):
      mac80211-hwsim: Add support for HWSIM_ATTR_DESTROY_RADIO_ON_CLOSE
      Bluetooth: 6lowpan: Converting rwlocks to use RCU
      Bluetooth: 6lowpan: Fix lockdep splats
      Bluetooth: Wrong style spin lock used
      mac80211-hwsim: Rename CREATE and DESTROY radio to NEW and DEL radio
      mac80211-hwsim: Provide multicast event for HWSIM_CMD_NEW_RADIO
      mac80211-hwsim: Provide multicast event for HWSIM_CMD_DEL_RADIO

Julien Catalano (1):
      trivial: net/mac802154: Fix Kconfig typo

Kalle Valo (6):
      ath10k: don't enable interrupts for the diagnostic window
      ath10k: add diag_read() to hif ops
      ath10k: add cal_data debugfs file
      ath10k: add back enum ath10k_bus
      ath10k: refactor ath10k_init_download_firmware()
      ath10k: retrieve calibration data from file

Karl Beldan (10):
      mac80211: minstrel_ht: fix MCS_GROUP_RATES usage
      cfg80211: set the rates mask in connection probes over specified freq
      mac80211: fix typo in starting baserate for rts_cts_rate_idx
      mac80211: minstrels: fix buffer overflow in HT debugfs rc_stats
      mac80211: minstrel_ht: Increase the range of handled rate indexes
      mac80211: minstrel_ht: macros adjustments for future VHT_GROUPs
      mac80211: minstrel_ht: include type (cck/ht) in rates flag
      mac80211: minstrel_ht: add basic support for VHT rates <=3D 3SS@80MHz
      mac80211: minstrel_ht: use group flags instead of index to display ra=
tes
      mac80211: minstrel_ht: do not always skip ht rates vht_only is true

Larry Finger (1):
      rtlwifi: rtl8821ae: Remove extra semicolons

Li RongQing (1):
      Bluetooth: 6lowpan: remove unnecessary codes in give_skb_to_upper

Liad Kaufman (2):
      mac80211: fix warning on htmldocs for last_tdls_pkt_time
      iwlwifi: 8000: fix string given to MODULE_FIRMWARE

Loic Poulain (1):
      Bluetooth: HCI H5 peer reset detection

Lorenzo Bianconi (2):
      ath9k: do not overwrite AR_PHY_RADAR_1 MSB
      ath9k: set pulse_rssi threshold to 15

Luciano Coelho (15):
      mac80211: return the vif's chandef in ieee80211_cfg_get_channel()
      nl80211: sanity check the channel switch counter value
      mac80211: add device_timestamp to the ieee80211_channel_switch struct
      mac80211: add extended channel switching capability if the driver sup=
ports CSA
      mac80211: add pre_channel_switch driver operation
      mac80211: add post_channel_switch driver operation
      mac80211: wait for the first beacon on the new channel after CSA
      mac80211: allow channel switch with multiple channel contexts
      iwlwifi: mvm: hold the rtnl when resuming from a d3 test
      iwlwifi: mvm: split wowlan handling out of the main suspend function
      iwlwifi: mvm: move the check if associated outside of the iterator fo=
r wowlan
      iwlwifi: mvm: spin off a function to start scan offload
      iwlwifi: mvm: add debugfs entry to configure netdetect SSIDs
      iwlwifi: mvm: change the iwl_mvm_d3_iface_iterator into a generic fun=
ction
      iwlwifi: mvm: remove unnecessary includes in tt.c

Marcel Holtmann (1):
      Bluetooth: Clear LE white list when resetting controller

Martin Townsend (6):
      6lowpan: Use skb_cow in IPHC decompression.
      Bluetooth: Fix missing channel unlock in l2cap_le_credits
      6lowpan: remove skb_deliver from IPHC
      6lowpan: fix process_data return values
      bluetooth:6lowpan: use consume_skb when packet processed successfully
      ieee802154: 6lowpan: rename process_data and lowpan_process_data

Matti Gottlieb (1):
      iwlwifi: mvm: ROC - bug fixes around time events and locking

Max Stepanov (1):
      iwlwifi: mvm: add MVM_FW_BCAST_FILTER_PASS_ALL option

Michal Kazior (27):
      ath10k: workaround fw beaconing bug
      ath10k: fix tx/rx chainmask init
      ath10k: remove unused pdev_set_channel command
      ath10k: deduplicate wmi_channel code
      ath10k: deduplicate host mem chunk code
      ath10k: relocate wmi attach/deatch functions
      ath10k: deduplicate wmi service ready logic
      ath10k: clean up phyerr code
      ath10k: unify wmi event function names
      ath10k: re-work scan start command building
      ath10k: print wmi version info
      ath10k: dump hex bytes with dev string prefix
      ath10k: add debug dump for pci rx
      ath10k: split wmi stats parsing
      ath10k: rename fw_stats related stuff
      ath10k: request fw_stats once on open
      ath10k: fix fw stats processing
      ath10k: warn on unhandled htt events
      mac80211: enable DFS with channel contexts
      ath10k: clean up assoc code
      ath10k: skip some commands on reassoc
      ath10k: clean up sta auth/assoc code
      ath10k: simplify computation of mgmt rx band
      ath10k: use bss_info as txpower source
      ath10k: re-disable interrupts after target init
      ath10k: mask/unmask msi fw irq
      ath10k: split ce pipe init/alloc further

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: fill core details for every device

Rajkumar Manoharan (6):
      ath10k: add support to configure pktlog filter
      ath10k: add tracing for ath10k_htt_pktlog
      ath10k: add tracing for rx descriptor
      ath10k: add tracing for tx info
      ath10k: add tracing for frame transmission
      ath10k: fix kernel panic while shutting down AP

Rostislav Lisovy (2):
      cfg80211: 802.11p OCB mode handling
      mac80211: 802.11p OCB mode support

Simon Vincent (2):
      ieee802154: 6lowpan: Drop PACKET_OTHERHOST skbs in 6lowpan
      ieee802154: mrf24j40: Add support for MRF24J40MC

Stanislaw Gruszka (1):
      rt2x00: tune multi-registers I/O timeout

Stephen Hemminger (2):
      Bluetooth: spelling fixes
      mac80211: fix spelling errors

Sujith Manoharan (25):
      ath9k: Use sta_state() callback
      ath9k: Enable multi-channel properly
      ath9k: Process beacons properly
      ath9k: Unify reset API
      ath9k: Set ATH_OP_HW_RESET before HW reset
      ath9k: Disable beacon tasklet during reset
      ath9k: Clear NoA schedule properly
      ath9k: Use configurable timeout for flush
      ath9k: Fix MCC flush timeout
      ath9k: Fix offchannel flush timeout
      ath9k: Check for pending frames properly
      ath9k: Send AUTHORIZED event only for station mode
      ath9k: Fix address management
      ath9k: Add a function to check for an active GO
      ath9k: Check for active GO in mgd_prepare_tx()
      ath9k: Use a helper function for offchannel NoA
      ath9k: Use a helper function to set NoA
      ath9k: Use a helper function for bmiss
      ath9k: Fix RoC expiration
      ath9k: Send oneshot NoA
      ath9k: Fix HW scan abort
      ath9k: Improve flush() in mcc mode
      ath9k: Do not start BA when scanning
      ath9k: Update AR9580 initvals
      ath9k: Update AR955x initvals

Szymon Janc (2):
      Bluetooth: Fix RFCOMM NSC response
      Bluetooth: Improve RFCOMM __test_pf macro robustness

Varka Bhadram (1):
      MAINTAINERS: add cc2520 driver maintainer

Vladimir Kondratiev (5):
      wil6210: do not attempt FW recovery if interface is down
      wil6210: reset flow updates
      wil6210: prevent double disconnect command issuing
      wil6210: improve dmesg for fw error handling
      wil6210: Add support for large packets

Xinming Hu (1):
      mwifiex: add cfg80211 dump_survey handler

 MAINTAINERS                                        |   15 +
 drivers/bcma/bcma_private.h                        |    1 +
 drivers/bcma/main.c                                |    9 +-
 drivers/bcma/scan.c                                |    1 +
 drivers/bluetooth/ath3k.c                          |    2 +
 drivers/bluetooth/btusb.c                          |    1 +
 drivers/bluetooth/hci_h5.c                         |   34 +
 drivers/net/ieee802154/Kconfig                     |   10 -
 drivers/net/ieee802154/Makefile                    |    1 -
 drivers/net/ieee802154/at86rf230.c                 |  392 +++----
 drivers/net/ieee802154/cc2520.c                    |   70 +-
 drivers/net/ieee802154/fakehard.c                  |  427 --------
 drivers/net/ieee802154/fakelb.c                    |   92 +-
 drivers/net/ieee802154/mrf24j40.c                  |  104 +-
 drivers/net/wireless/ath/ath.h                     |    2 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   83 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   21 +-
 drivers/net/wireless/ath/ath10k/core.c             |  111 +-
 drivers/net/wireless/ath/ath10k/core.h             |   82 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  891 ++++++++++++----
 drivers/net/wireless/ath/ath10k/debug.h            |   40 +-
 drivers/net/wireless/ath/ath10k/hif.h              |   10 +
 drivers/net/wireless/ath/ath10k/htt.h              |    2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   20 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    2 +
 drivers/net/wireless/ath/ath10k/hw.h               |   17 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  517 +++++----
 drivers/net/wireless/ath/ath10k/mac.h              |    1 +
 drivers/net/wireless/ath/ath10k/pci.c              |  203 ++--
 drivers/net/wireless/ath/ath10k/spectral.c         |   34 +-
 drivers/net/wireless/ath/ath10k/spectral.h         |    8 +-
 drivers/net/wireless/ath/ath10k/trace.h            |  163 +++
 drivers/net/wireless/ath/ath10k/txrx.c             |    1 +
 drivers/net/wireless/ath/ath10k/wmi.c              | 1116 +++++++++++-----=
----
 drivers/net/wireless/ath/ath10k/wmi.h              |  273 ++---
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath6kl/common.h           |    2 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   28 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |   13 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    5 +
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    7 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   42 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   11 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    3 -
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    7 +-
 drivers/net/wireless/ath/ath9k/ar9003_rtt.h        |   36 +
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |    8 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |  144 ++-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   15 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    6 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    2 +-
 drivers/net/wireless/ath/ath9k/channel.c           |  319 ++++--
 drivers/net/wireless/ath/ath9k/debug.c             |   49 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   31 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   43 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   26 +-
 drivers/net/wireless/ath/ath9k/init.c              |    7 +
 drivers/net/wireless/ath/ath9k/link.c              |   12 +-
 drivers/net/wireless/ath/ath9k/main.c              |  200 +++-
 drivers/net/wireless/ath/ath9k/pci.c               |    6 +
 drivers/net/wireless/ath/ath9k/reg.h               |   33 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |    4 +-
 drivers/net/wireless/ath/carl9170/phy.c            |    4 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    5 +-
 drivers/net/wireless/ath/wil6210/main.c            |   95 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    2 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |    7 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    4 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   13 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   51 +-
 drivers/net/wireless/brcm80211/brcmfmac/btcoex.c   |    6 +-
 .../brcm80211/brcmfmac/{dhd_bus.h =3D> bus.h}        |   11 +-
 .../brcmfmac/{wl_cfg80211.c =3D> cfg80211.c}         |   85 +-
 .../brcmfmac/{wl_cfg80211.h =3D> cfg80211.h}         |    9 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/common.c   |  168 +++
 .../net/wireless/brcm80211/brcmfmac/commonring.c   |    2 +-
 .../brcm80211/brcmfmac/{dhd_linux.c =3D> core.c}     |    8 +-
 .../wireless/brcm80211/brcmfmac/{dhd.h =3D> core.h}  |    7 +-
 .../brcm80211/brcmfmac/{dhd_dbg.c =3D> debug.c}      |    6 +-
 .../brcm80211/brcmfmac/{dhd_dbg.h =3D> debug.h}      |    6 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  400 -------
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |   11 +-
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |   84 +-
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   89 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/of.c       |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/proto.c    |    6 +-
 .../brcm80211/brcmfmac/{dhd_sdio.c =3D> sdio.c}      |   55 +-
 .../brcm80211/brcmfmac/{sdio_host.h =3D> sdio.h}     |    8 +-
 .../net/wireless/brcm80211/brcmfmac/tracepoint.c   |   15 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  142 ++-
 drivers/net/wireless/brcm80211/brcmfmac/usb_rdl.h  |   75 --
 drivers/net/wireless/brcm80211/brcmfmac/vendor.c   |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/debug.c    |  166 ++-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   18 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    2 +-
 drivers/net/wireless/ipw2x00/libipw.h              |    5 -
 drivers/net/wireless/ipw2x00/libipw_module.c       |   15 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |   21 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/4965.h               |    5 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    1 +
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    4 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   25 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   12 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    3 -
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    1 -
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    6 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |   13 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |   14 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    5 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  318 +++---
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  201 ++--
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   35 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |    1 +
 drivers/net/wireless/iwlwifi/mvm/fw.c              |    9 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    5 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  152 ++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   18 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   16 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   80 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |    2 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   38 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |    2 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |    4 -
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   14 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   37 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   67 +-
 drivers/net/wireless/mac80211_hwsim.c              |  462 ++++++--
 drivers/net/wireless/mac80211_hwsim.h              |   25 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   75 +-
 drivers/net/wireless/mwifiex/decl.h                |   10 +
 drivers/net/wireless/mwifiex/fw.h                  |   16 +
 drivers/net/wireless/mwifiex/main.c                |    6 +
 drivers/net/wireless/mwifiex/main.h                |    6 +-
 drivers/net/wireless/mwifiex/scan.c                |   76 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   10 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   39 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c       |   12 +-
 drivers/net/wireless/ti/wlcore/main.c              |   23 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |    4 +-
 include/linux/ath9k_platform.h                     |    3 +
 include/linux/ieee80211.h                          |   22 +-
 include/{net =3D> linux}/ieee802154.h                |   23 +-
 include/linux/nl802154.h                           |    4 -
 include/net/6lowpan.h                              |   12 +-
 include/net/af_ieee802154.h                        |    4 -
 include/net/bluetooth/hci_core.h                   |    8 +-
 include/net/cfg80211.h                             |   84 +-
 include/net/{wpan-phy.h =3D> cfg802154.h}            |   22 +-
 include/net/ieee802154_netdev.h                    |    6 +-
 include/net/mac80211.h                             |  138 ++-
 include/net/mac802154.h                            |  124 ++-
 include/net/nl802154.h                             |    4 -
 include/uapi/linux/nl80211.h                       |   32 +-
 net/6lowpan/iphc.c                                 |   71 +-
 net/bluetooth/6lowpan.c                            |  284 +++--
 net/bluetooth/hci_conn.c                           |   14 +-
 net/bluetooth/hci_core.c                           |   16 +-
 net/bluetooth/hci_event.c                          |   50 +-
 net/bluetooth/hci_sock.c                           |    2 +-
 net/bluetooth/l2cap_core.c                         |    7 +-
 net/bluetooth/mgmt.c                               |   83 +-
 net/bluetooth/rfcomm/core.c                        |    6 +-
 net/bluetooth/smp.c                                |   34 +-
 net/ieee802154/6lowpan_rtnl.c                      |  108 +-
 net/ieee802154/Makefile                            |    4 +-
 net/ieee802154/af802154.h                          |    4 -
 net/ieee802154/af_ieee802154.c                     |    4 -
 net/ieee802154/{wpan-class.c =3D> core.c}            |   79 +-
 net/ieee802154/dgram.c                             |    6 +-
 net/ieee802154/header_ops.c                        |    3 +-
 net/ieee802154/ieee802154.h                        |    4 -
 net/ieee802154/netlink.c                           |    4 -
 net/ieee802154/nl-mac.c                            |   27 +-
 net/ieee802154/nl-phy.c                            |    6 +-
 net/ieee802154/nl_policy.c                         |    4 -
 net/ieee802154/raw.c                               |    4 -
 net/ieee802154/reassembly.c                        |    8 +-
 net/ieee802154/reassembly.h                        |    4 +-
 net/ieee802154/sysfs.c                             |   94 ++
 net/ieee802154/sysfs.h                             |    9 +
 net/mac80211/Kconfig                               |   18 +
 net/mac80211/Makefile                              |    3 +-
 net/mac80211/agg-tx.c                              |    5 -
 net/mac80211/cfg.c                                 |  180 +++-
 net/mac80211/chan.c                                |    5 +-
 net/mac80211/debug.h                               |   10 +
 net/mac80211/debugfs_key.c                         |   12 +-
 net/mac80211/driver-ops.h                          |   74 +-
 net/mac80211/ieee80211_i.h                         |   80 +-
 net/mac80211/iface.c                               |   30 +-
 net/mac80211/key.c                                 |   11 +-
 net/mac80211/main.c                                |   38 +-
 net/mac80211/mesh.h                                |    3 +
 net/mac80211/mesh_pathtbl.c                        |   31 +
 net/mac80211/mlme.c                                |  281 ++++-
 net/mac80211/ocb.c                                 |  250 +++++
 net/mac80211/rate.c                                |    2 +-
 net/mac80211/rc80211_minstrel.c                    |    2 +-
 net/mac80211/rc80211_minstrel_debugfs.c            |   12 +-
 net/mac80211/rc80211_minstrel_ht.c                 |  313 ++++--
 net/mac80211/rc80211_minstrel_ht.h                 |   40 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |   48 +-
 net/mac80211/rx.c                                  |   35 +
 net/mac80211/sta_info.c                            |    4 +-
 net/mac80211/sta_info.h                            |    1 +
 net/mac80211/status.c                              |    3 +-
 net/mac80211/tdls.c                                |    8 +-
 net/mac80211/trace.h                               |  100 +-
 net/mac80211/tx.c                                  |   15 +
 net/mac80211/util.c                                |  132 ++-
 net/mac80211/wep.c                                 |    2 -
 net/mac80211/wme.c                                 |   33 +-
 net/mac80211/wme.h                                 |    2 -
 net/mac80211/wpa.c                                 |    5 -
 net/mac802154/Kconfig                              |    2 +-
 net/mac802154/Makefile                             |    4 +-
 net/mac802154/driver-ops.h                         |  226 ++++
 net/mac802154/ieee802154_dev.c                     |  415 --------
 net/mac802154/{mac802154.h =3D> ieee802154_i.h}      |   87 +-
 net/mac802154/iface.c                              |  466 ++++++++
 net/mac802154/llsec.c                              |    4 +-
 net/mac802154/mac_cmd.c                            |   36 +-
 net/mac802154/main.c                               |  265 +++++
 net/mac802154/mib.c                                |  240 ++---
 net/mac802154/monitor.c                            |  117 --
 net/mac802154/rx.c                                 |  311 ++++--
 net/mac802154/tx.c                                 |  154 +--
 net/mac802154/util.c                               |   55 +
 net/mac802154/wpan.c                               |  599 -----------
 net/wireless/Makefile                              |    2 +-
 net/wireless/chan.c                                |   10 +-
 net/wireless/core.c                                |   77 +-
 net/wireless/core.h                                |   12 +
 net/wireless/nl80211.c                             |  206 +++-
 net/wireless/ocb.c                                 |   88 ++
 net/wireless/rdev-ops.h                            |   55 +-
 net/wireless/sme.c                                 |   13 +-
 net/wireless/trace.h                               |   97 +-
 net/wireless/util.c                                |    5 +-
 258 files changed, 10107 insertions(+), 6017 deletions(-)
 delete mode 100644 drivers/net/ieee802154/fakehard.c
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_bus.h =3D> bus.h} (98%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{wl_cfg80211.c =3D> cfg8021=
1.c} (98%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{wl_cfg80211.h =3D> cfg8021=
1.h} (98%)
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/common.c
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_linux.c =3D> core.c} (=
99%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd.h =3D> core.h} (98%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_dbg.c =3D> debug.c} (9=
8%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_dbg.h =3D> debug.h} (9=
8%)
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_sdio.c =3D> sdio.c} (9=
8%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{sdio_host.h =3D> sdio.h} (=
98%)
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/usb_rdl.h
 rename include/{net =3D> linux}/ieee802154.h (94%)
 rename include/net/{wpan-phy.h =3D> cfg802154.h} (77%)
 rename net/ieee802154/{wpan-class.c =3D> core.c} (60%)
 create mode 100644 net/ieee802154/sysfs.c
 create mode 100644 net/ieee802154/sysfs.h
 create mode 100644 net/mac80211/ocb.c
 create mode 100644 net/mac802154/driver-ops.h
 delete mode 100644 net/mac802154/ieee802154_dev.c
 rename net/mac802154/{mac802154.h =3D> ieee802154_i.h} (73%)
 create mode 100644 net/mac802154/iface.c
 create mode 100644 net/mac802154/main.c
 delete mode 100644 net/mac802154/monitor.c
 create mode 100644 net/mac802154/util.c
 delete mode 100644 net/mac802154/wpan.c
 create mode 100644 net/wireless/ocb.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUXSv1AAoJEJctW/TcYTgG0AIP/jzvGfdciyvDkggpqh0DL+vA
SaZ/qb9KDWIj0VXGj9PAWA2RjWPNox7pvL77woExfap7T0MAY5CSJdqvpnvlQ2UW
uSB0EcI6SVxxTPQOKuJOHK+ezE9tFb220NcA49Zexm0M2RRFCVWjZswQpLwtFQr2
4MQtrxlSpiym4frY69S41Uhryoqzu1bRO8ACjAYH3zyTPZe1SD5ZoaENxQoOrJ3k
xhW/YVkFkhPitfy3Q0VsNS1MGNb5Zuonk5Rp/zKXdF5/Zn/t7M606tCzxs2vrgCY
43G62CteEiWDRA0oK/jQgh0S63QVJ28LgVW61ZoPRYA7TCWp/yhePyJgJTYvkU5l
7GbqxdFwpf791KfGmxoih0MEN0GDRnZWmZM6X7xULpRtoW63iYXKyRKgu3aXlvab
GiVj/75WURvBzQBAVu3pylMU5BtllVYzzRcQwpupHPYRVE7a1WlkKFLfJkGospyC
S19kMrQIdLMZqLS4M8bgSjJRJuHj+dixsMP6zsqAtMJue5oAkJwM7dfwIsiCkrYR
vy4+pGDmoBJuPR34w/++yDL3QoiKiE4CrCOe8+QXKvm6pQJFg/KHJRXLEZg/G/Su
JXA1rG+pSnUpcIwQ4z5aVkuWJz/8zbPrizlUL3GXPY8LbpCiPMp1eaC/D2d1sp2W
6JGFZds5CH07aAOmDEnP
=ynRE
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
