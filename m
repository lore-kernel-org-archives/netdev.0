From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2013-06-21
Date: Fri, 21 Jun 2013 16:09:58 -0400
Message-ID: <20130621200957.GA2831@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bp/iNruPH9dso1Pn"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

I would guess that this is the last big wireless pull request before
the 3.11 merge window...

Regarding the mac80211 bits, Johannes says:

"I have a number of mesh fixes and improvements from Colleen, Jacob,
Ashok and Thomas, powersave fixes in mac80211 from Alex, improved
management-TX from Antonio, and a few various things, including locking
fixes, from others and myself. Overall though, nothing really stands
out."

As for the iwlwifi bits, Johannes says:

"Emmanuel contributed two AP mode fixes, removed an unused field, fixed a
comment and added a warning for something that shouldn't happen in
practice, and I removed the declaration of a function that doesn't even
exist and cleaned up a small include."

"This time I have a number of cleanups, a small fix from Emmanuel and two
performance improvements that combined reduce our driver's CPU
utilisation as much as 75% in high TX-throughput scenarios."

"These two patches fix two issues with using rfkill randomly during
traffic, which would then cause our driver to stop working and not be
able to recover at all."

Regarding the ath6kl bits, Kalle says:

"Here are few simple patches for ath6kl. We have a suspend crash fix for
USB from Shafi, use of mac_pton(), a compiler warning fix and a fix for
module initialisation error path."

Kalle also sends the biggest single item of note, the new ath10k
driver for Qualcomm Atheros 802.11ac CQA98xx devices.

Included is an NFC pull, of which Samuel says:

"These are the pending NFC patches for the 3.11 merge window.

It contains the pending fixes that were on nfc-fixes (nfc-fixes-3.10-2),
along with a few more for the pn544 and pn533 drivers, the LLCP
disconnection path and an LLCP memory leak.

Highlights for this one are:

- An initial secure element API. NFC chipsets can carry an embedded
  secure element or get access to the SIM one. In both cases they
  control the secure elements and this API provides a way to discover,
  enable and disable the available SEs. It also exports that to
  userspace in order for SE focused middleware to actually do something
  with them (e.g. payments).

- NCI over SPI support. SPI is the most complex NCI specified transport
  layer and we now have support for it in the kernel. The next step will
  be to implement drivers for NCI chipsets using this transport like
  e.g. bcm2079x.

- NFC p2p hardware simulation driver. We now have an nfcsim driver that
  is mostly a loopback device between 2 NFC interfaces. It also
  implements the rest of the NFC core API like polling and target
  detection. This driver, with neard running on top of it, allows us to
  completely test the LLCP, SNEP and Handover implementation without
  physical hardware.

- A Firmware update netlink API. Most (All ?) HCI chipsets have a
  special firmware update mode where applications can push a new
  firmware that will be flashed. We now have a netlink API for providing
  that mode to e.g. nfctool."

On top of all that, there are a variety of updates to brcmfmac,
iwlegacy, rtlwifi, wil6210, and the TI wl12xx drivers.  As usual,
the bcma and ssb busses get a little love as well, as do a handful
of others here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fedaf4ffc224a194e2d13a3ec2abe5df0bc94258:

  ndisc: Convert use of typedef ctl_table to struct ctl_table (2013-06-19 2=
3:18:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 7d2a47aab2a511c87a96238977e04e6378969d45:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-06-21 15:42:30 -0400)

----------------------------------------------------------------

Alexander Bondar (2):
      mac80211: fix powersave bug and clean up ieee80211_rx_bss_info
      mac80211: Use suitable semantics for beacon availability indication

Alexey Khoroshilov (1):
      orinoco_usb: fix memory leak in ezusb_access_ltv() when device discon=
nected

Amitkumar Karwar (4):
      mwifiex: fix regression issue for usb interface
      mwifiex: code rearrangement for better readability
      mwifiex: add basic 11h support for station
      mwifiex: channel switch handling for station

Andy Shevchenko (1):
      wireless: ath6kl: re-use native helper to parse MAC

Antonio Quartulli (5):
      mac80211: make mgmt_tx accept a NULL channel
      brcm80211: make mgmt_tx in brcmfmac accept a NULL channel
      ath6kl: make mgmt_tx accept a NULL channel
      nl80211: allow sending CMD_FRAME without specifying any frequency
      brcm80211: fix null pointer access

Arend van Spriel (15):
      brcmfmac: allow firmware-signal tlv to be longer than specified
      brcmfmac: remove fifo bitfield from brcmf_skbuff_cb::if_flags
      brcmfmac: rework credit pickup to assure consistent handling
      brcmfmac: explicitly indicate sk_buff is sent upon request credit
      brcmfmac: reducing debug logging in firmware-signalling code
      brcmfmac: fix send_pkts statistic counter in firmware-signalling
      brcmfmac: add trace event for capturing BDC header
      brcmfmac: increment hard_header_len instead of overriding
      brcmfmac: Sent TIM information in case of data available.
      brcmfmac: free primary net_device when brcmf_bus_start() fails
      brcmfmac: add debugfs statistics for firmware-signalling
      brcmfmac: rename variable prec to more appropriate name, ie. fifo
      brcmfmac: remove dependency with nl80211.h
      brcmfmac: consolidate mac_descriptor related function names
      brcmfmac: simplify dpc handling using atomic operations

Arik Nemtsov (2):
      wlcore: cancel channel switch work on interface removal
      wlcore: hold jiffies in unsigned long

Arron Wang (2):
      NFC: pn544: Identify Type F NFC-DEP through NFCID2
      NFC: pn544: Remove Felica and Jewel device presence check

Ashok Nagarajan (1):
      {nl,mac,cfg}80211: Allow user to configure basic rates for mesh

Avinash Patil (2):
      mwifiex: enable/disable tx_amsdu support via module parameter
      mwifiex: Add module parameter for regdomain

Cho, Yu-Chen (1):
      Bluetooth: Add support for Mediatek Bluetooth device [0e8d:763f]

Christian Lamparter (1):
      carl9170: add support for the new rate control API

Colleen Twitty (2):
      {nl,cfg}80211: make peer link expiration time configurable
      mac80211: expire mesh peers based on mesh configuration

Dan Carpenter (1):
      ath10k: off by one sanity check

Daniel Drake (1):
      mwifiex: fix memory corruption when unsetting multicast list

David Spinadel (1):
      iwlwifi: remove calib channel section from PHY DB

Eliad Peller (1):
      wlcore: configure rates in multiple cases

Emmanuel Grumbach (9):
      iwlwifi: mvm: remove unused wait_for_ba field
      iwlwifi: mvm: fix irrelevant comment
      iwlwifi: ignore 0-length PHY DB sections
      iwlwifi: mvm: properly tell the fw that a STA is awake
      iwlwifi: mvm: don't set the MCAST queue in STA's queue list
      iwlwifi: mvm: take the seqno from packet if transmit failed
      iwlwifi: mvm: remove obsolete comment
      iwlwifi: pcie: fix race in queue unmapping
      iwlwifi: pcie: wake the queue if stopped when being unmapped

Eric Lapuyade (2):
      NFC: Add firmware upload netlink command
      NFC: HCI: Implement fw_upload ops

Felix Fietkau (5):
      mac80211: add a tx control flag to indicate PS-Poll/uAPSD response
      nl80211: add kernel-doc for NL80211_FEATURE_ACTIVE_MONITOR
      ath9k: add support for IEEE80211_TX_CTL_PS_RESPONSE
      ath9k: implement support for .release_buffered_frames()
      ath9k: limit multicast buffer hardware queue depth

Franky Lin (3):
      brcmfmac: remove redundant chip ID check in dhd_sdio
      brcmfmac: replace brcmf_sdioh_request_buffer with brcmf_sdio_buffrw
      brcmfmac: add sdio sg list support

Frederic Danis (4):
      NFC: NCI: Fix skb->dev usage
      NFC: Add basic NCI over SPI
      NFC: Add NCI over SPI send
      NFC: Add NCI over SPI receive

Gabor Juhos (15):
      rt2x00: rt2x00queue: add priv_size field to struct data_queue
      rt2x00: rt2x00queue: remove qdesc parameter of rt2x00queue_alloc_entr=
ies
      rt2x00: rt2x00dev: use rt2x00dev->bcn->limit
      rt2x00: rt2x00queue: setup queue->threshold from queue->limit
      rt2x00: add queue_init callback to rt2x00_ops
      rt2x00: rt2800usb: implement queue_init callback
      rt2x00: rt2800pci: implement queue_init callback
      rt2x00: rt73usb: implement queue_init callback
      rt2x00: rt2400pci: implement queue_init callback
      rt2x00: rt2500pci: implement queue_init callback
      rt2x00: rt61pci: implement queue_init callback
      rt2x00: rt2500usb: implement queue_init callback
      rt2x00: remove data_queue_desc struct
      rt2x00: move extra_tx_headroom field from rt2x00_ops to rt2x00_dev
      rt2x00: rt2800usb: nuke rt2800usb_ops_5592

Geert Uytterhoeven (1):
      ath6kl: Unify sg_sz and buf_sz in ath6kl_sdio_alloc_prep_scat_req()

Hante Meuleman (12):
      brcmfmac: Take bus flowcontrol at credit mgmt into account.
      brcmfmac: On bus flow control use fw signalling or netif.
      brcmfmac: For FW signalling it is necessary to track gen bit.
      brcmfmac: Correct creditmap when credit borrowing is active.
      brcmfmac: Find correct MAC descriptor in case of TDLS.
      brcmfmac: fix invalid ifp lookup in firmware-signalling
      brcmfmac: Accept only first creditmap event.
      brcmfmac: Signalling header push and pull on logic places.
      brcmfmac: Fix endless loop when brcmf_fws_commit_skb fails.
      brcmfmac: Simplify counting transit count.
      brcmfmac: Always use fifo_credits, also for requested credits.
      brcmfmac: Only use credits for bcmc when firmware indicates it.

Hauke Mehrtens (4):
      wil6210: fix name of tracing config option
      b43: ensue that BCMA is "y" when B43 is "y"
      bcma: activate PCI host option by default
      b43: activate N-PHY and HT-PHY support by default

Ido Reis (1):
      wl18xx: FDSP Code RAM Corruption fix

Ilan Peer (1):
      iwlwifi: mvm: Update the supported interface combinations

Jacob Minshall (1):
      mac80211: set mesh formation field properly

Johannes Berg (18):
      cfg80211: take WoWLAN support information out of wiphy struct
      nl80211: remove bogus genlmsg_end() error checking
      Merge remote-tracking branch 'wireless-next/master' into HEAD
      cfg80211/mac80211: clean up cfg80211 SME APIs
      cfg80211: separate internal SME implementation
      regulatory: use proper enum return value
      cfg80211: fix potential deadlock regression
      cfg80211: make wiphy index start at 0 again
      wireless: fix kernel-doc
      iwlwifi: mvm: remove iwl_mvm_dbgfs_set_fw_dbg_log declaration
      cfg80211: fix rtnl leak in wiphy dump error cases
      iwlwifi: include export.h instead of module.h
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: make TX seqno validation more efficient
      iwlwifi: pcie: don't read INTA register in ICT IRQ handler
      iwlwifi: reduce debug ifdefs using the optimiser
      iwlwifi: mvm: mark scratch area in TX command
      iwlwifi: create opmode/device dependencies

John W. Linville (11):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'for-linville-ath10k' of git://github.com/kvalo/ath6kl
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'nfc-next-3.11-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      cfg80211: fix VHT TDLS peer AID verification

Kalle Valo (1):
      ath10k: mac80211 driver for Qualcomm Atheros 802.11ac CQA98xx devices

Kirshenbaum Erez (1):
      wil6210: Fix AP/PCP start flow

Larry Finger (2):
      rtlwifi: rtl8192cu: Add new USB ID for TP-Link TL-WN8200ND
      rtlwifi: rtl8192cu: Fix duplicate if test

Luciano Coelho (3):
      wlcore: some non-functional clean-ups in main.c
      wlcore: move sysfs handling to a separate file
      wl18xx: use locally administered MAC address if not available from fu=
se

Luis R. Rodriguez (1):
      ath: add VHT80 support for regulatory domains

Mohammed Shafi Shajakhan (2):
      ath6kl: Rename USB driver's suspend/resume/reset_resume
      ath6kl: Fix a suspend/resume crash in AR6004 USB

Oleksij Rempel (1):
      ath9k_htc: add STBC TX support

Olivier Guiter (1):
      NFC: pn533: Fix ACR122 related debug output

Oren Givon (1):
      iwlwifi: mvm: removed an unused parameter from a function

Peter Huewe (1):
      net/wireless/ti/wlcore/spi: Use module_spi_driver to register driver

Pontus Fuchs (1):
      mac80211: set IEEE80211_TX_CTL_REQ_TX_STATUS on nullframes

Rafa=C5=82 Mi=C5=82ecki (5):
      bcma: update core (en|dis)abling functions
      ssb: use const for serial flash hardware table
      bcma: use const for serial flash hardware table
      ssb: add struct for serial flash
      ssb: register serial flash as platform device

Raja Mani (1):
      ath6kl: Check wmi ready event status before validating abi version

Sachin Kamat (2):
      net: wireless: wl1251: Use module_spi_driver macro
      net: wireless: wl1251: Fix commenting style

Samuel Ortiz (14):
      NFC: HCI: Follow a positive code path in the HCI ops implementations
      NFC: pn533: Use 0x3 for SENSF_REQ Time Slot Number (TSN)
      NFC: pn533: Copy NFCID2 through ATR_REQ
      NFC: Remove the static supported_se field
      NFC: Extend and fix the internal secure element API
      NFC: Add secure elements addition and removal API
      NFC: Send netlink events for secure elements additions and removals
      NFC: Remove and free all SEs when releasing an NFC device
      NFC: Add secure element enablement internal API
      NFC: Add secure element enablement netlink API
      NFC: llcp: Fix non blocking sockets connections
      NFC: llcp: Do not send pending Tx frames when the remote is not ready
      NFC: llcp: Set the LLC Link Management well known service bit
      NFC: llcp: Fix the well known services endianness

Stanislaw Gruszka (5):
      iwlegacy: small refactoring of il_{stop,wake}_queue
      iwlegacy: add il_{stop,wake}_queues_by_reason functions
      iwl4965: workaround for firmware frame tx rejection
      iwl3945: workaround for firmware frame tx rejection
      Revert "iwl4965: workaround connection regression on passive channel"

Sujith Manoharan (21):
      ath9k: Fix OFDM weak signal detection for AP mode
      ath9k: Fix ANI monitoring
      ath9k: Fix ANI levels
      ath9k: Fix ofdm weak signal configuration
      ath9k: Remove redundant code
      ath9k: Remove unused ANI macros
      ath9k_hw: Assign default xlna config for AR9485
      ath9k: Fix noisefloor calibration
      ath9k: Do not assign noise for NULL caldata
      ath9k: Fix ANI trigger threshold
      ath9k: Add custom parameters for CUS198
      ath9k: Fix LNA gpio for AR9485
      ath9k: Fix ANI for AP mode
      ath9k: Merge HWTIMER debug level with BTCOEX
      ath9k: Convert a couple of debug messages
      ath9k: Update AR9462 2.0 initvals
      ath9k: Add support for 5G-XLNA/AR9462
      ath9k: Modify IDs to identify CUS230
      ath9k: Add PCI IDs for CUS217
      ath9k: Add initvals required for CUS217
      ath9k: Program initvals for CUS217

Thierry Escande (4):
      NFC: Rename nfc_llcp_disconnect() to nfc_llcp_send_disconnect()
      NFC: Keep socket alive until the DISC PDU is actually sent
      NFC: Fix a potential memory leak
      NFC: Add a nfc hardware simulation driver

Thomas Huehn (1):
      ath5k: make use of the new rate control API

Thomas Pedersen (2):
      mac80211: don't check local mesh TTL on TX
      mac80211: fix mesh deadlock

Valentin Ilie (1):
      NFC: mei_phy: Clean up file

Victor Goldenshtein (1):
      wlcore: fix occasional AP TX stop after recovery

Vladimir Kondratiev (6):
      wil6210: fix timeout for start_pcp
      wil6210: map more FW memory
      wil6210: improve frame type reporting
      wil6210: Derive IE's for AP
      wil6210: Send EAPOL frames using normal Tx queue
      wil6210: Init Rx vring right after reset

Wei Yongjun (3):
      iwlegacy: fix error return code in il3945_pci_probe()
      Bluetooth: btmrvl: fix error return code in btmrvl_sdio_card_to_host()
      NFC: pn533: Fix error return code in pn533_probe()

Yoni Divinsky (1):
      wlcore: set default_wep_key when configured

 Documentation/DocBook/80211.tmpl                   |   11 +-
 drivers/bcma/Kconfig                               |    1 +
 drivers/bcma/core.c                                |   28 +-
 drivers/bcma/driver_chipcommon_sflash.c            |    8 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    1 +
 drivers/bluetooth/btusb.c                          |    3 +
 drivers/net/wireless/ath/Kconfig                   |    1 +
 drivers/net/wireless/ath/Makefile                  |    1 +
 drivers/net/wireless/ath/ath.h                     |   13 +-
 drivers/net/wireless/ath/ath10k/Kconfig            |   39 +
 drivers/net/wireless/ath/ath10k/Makefile           |   20 +
 drivers/net/wireless/ath/ath10k/bmi.c              |  295 ++
 drivers/net/wireless/ath/ath10k/bmi.h              |  224 ++
 drivers/net/wireless/ath/ath10k/ce.c               | 1189 ++++++++
 drivers/net/wireless/ath/ath10k/ce.h               |  516 ++++
 drivers/net/wireless/ath/ath10k/core.c             |  665 +++++
 drivers/net/wireless/ath/ath10k/core.h             |  369 +++
 drivers/net/wireless/ath/ath10k/debug.c            |  503 ++++
 drivers/net/wireless/ath/ath10k/debug.h            |   90 +
 drivers/net/wireless/ath/ath10k/hif.h              |  137 +
 drivers/net/wireless/ath/ath10k/htc.c              | 1000 +++++++
 drivers/net/wireless/ath/ath10k/htc.h              |  368 +++
 drivers/net/wireless/ath/ath10k/htt.c              |  152 +
 drivers/net/wireless/ath/ath10k/htt.h              | 1338 +++++++++
 drivers/net/wireless/ath/ath10k/htt_rx.c           | 1167 ++++++++
 drivers/net/wireless/ath/ath10k/htt_tx.c           |  510 ++++
 drivers/net/wireless/ath/ath10k/hw.h               |  304 ++
 drivers/net/wireless/ath/ath10k/mac.c              | 3066 ++++++++++++++++=
++++
 drivers/net/wireless/ath/ath10k/mac.h              |   61 +
 drivers/net/wireless/ath/ath10k/pci.c              | 2506 ++++++++++++++++
 drivers/net/wireless/ath/ath10k/pci.h              |  355 +++
 drivers/net/wireless/ath/ath10k/rx_desc.h          |  990 +++++++
 drivers/net/wireless/ath/ath10k/targaddrs.h        |  449 +++
 drivers/net/wireless/ath/ath10k/trace.c            |   20 +
 drivers/net/wireless/ath/ath10k/trace.h            |  170 ++
 drivers/net/wireless/ath/ath10k/txrx.c             |  417 +++
 drivers/net/wireless/ath/ath10k/txrx.h             |   39 +
 drivers/net/wireless/ath/ath10k/wmi.c              | 2081 +++++++++++++
 drivers/net/wireless/ath/ath10k/wmi.h              | 3052 ++++++++++++++++=
+++
 drivers/net/wireless/ath/ath5k/base.c              |   79 +-
 drivers/net/wireless/ath/ath5k/base.h              |   14 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   51 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |    8 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   14 +-
 drivers/net/wireless/ath/ath6kl/sdio.c             |   12 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |   36 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   32 +-
 drivers/net/wireless/ath/ath9k/ani.h               |   11 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   26 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   22 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   97 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    2 +
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |  282 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   13 +
 drivers/net/wireless/ath/ath9k/beacon.c            |   23 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    1 -
 drivers/net/wireless/ath/ath9k/htc.h               |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    3 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                |    9 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    7 +
 drivers/net/wireless/ath/ath9k/init.c              |   46 +-
 drivers/net/wireless/ath/ath9k/main.c              |    8 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   44 +
 drivers/net/wireless/ath/ath9k/xmit.c              |  333 ++-
 drivers/net/wireless/ath/carl9170/carl9170.h       |    3 +
 drivers/net/wireless/ath/carl9170/main.c           |    3 +
 drivers/net/wireless/ath/carl9170/tx.c             |  182 +-
 drivers/net/wireless/ath/regd.c                    |    6 +-
 drivers/net/wireless/ath/wil6210/Kconfig           |    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   34 +-
 drivers/net/wireless/ath/wil6210/main.c            |   42 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   20 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |    1 -
 drivers/net/wireless/ath/wil6210/wmi.c             |   47 +-
 drivers/net/wireless/b43/Kconfig                   |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  179 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  114 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |   18 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |    6 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   23 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  176 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  787 +++--
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h |    1 +
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   15 +-
 .../net/wireless/brcm80211/brcmfmac/tracepoint.h   |   21 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    8 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   18 +-
 drivers/net/wireless/cw1200/main.c                 |   13 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    3 +-
 drivers/net/wireless/iwlegacy/3945.c               |   18 +
 drivers/net/wireless/iwlegacy/4965-mac.c           |   21 +-
 drivers/net/wireless/iwlegacy/common.c             |   11 +
 drivers/net/wireless/iwlegacy/common.h             |   41 +-
 drivers/net/wireless/iwlwifi/Makefile              |    6 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    3 +
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   17 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |    7 -
 drivers/net/wireless/iwlwifi/iwl-config.h          |    4 +
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    4 +
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 +
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |   39 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   15 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    9 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    5 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   37 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |    6 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   11 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    2 -
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    5 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    4 +
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    2 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   44 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   23 +-
 drivers/net/wireless/mwifiex/11h.c                 |  101 +
 drivers/net/wireless/mwifiex/Makefile              |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c            |   45 +-
 drivers/net/wireless/mwifiex/fw.h                  |   16 +
 drivers/net/wireless/mwifiex/init.c                |   82 +-
 drivers/net/wireless/mwifiex/join.c                |    2 +
 drivers/net/wireless/mwifiex/main.c                |   87 +-
 drivers/net/wireless/mwifiex/main.h                |   27 +
 drivers/net/wireless/mwifiex/scan.c                |   37 +
 drivers/net/wireless/mwifiex/sta_event.c           |   11 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   52 +-
 drivers/net/wireless/mwifiex/wmm.c                 |    5 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    3 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   66 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   66 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   66 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   61 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |  125 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    9 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   20 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   60 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   21 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   55 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   55 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    1 +
 drivers/net/wireless/ti/wl1251/spi.c               |   30 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   47 +-
 drivers/net/wireless/ti/wl18xx/reg.h               |   15 +
 drivers/net/wireless/ti/wlcore/Makefile            |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |  284 +-
 drivers/net/wireless/ti/wlcore/ps.c                |    2 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   14 +-
 drivers/net/wireless/ti/wlcore/sysfs.c             |  216 ++
 drivers/net/wireless/ti/wlcore/sysfs.h             |   28 +
 drivers/net/wireless/ti/wlcore/tx.c                |    2 +-
 drivers/nfc/Kconfig                                |   10 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/mei_phy.c                              |    6 +-
 drivers/nfc/microread/microread.c                  |    6 +-
 drivers/nfc/nfcsim.c                               |  541 ++++
 drivers/nfc/nfcwilink.c                            |   18 +-
 drivers/nfc/pn533.c                                |   31 +-
 drivers/nfc/pn544/pn544.c                          |   40 +-
 drivers/ssb/driver_chipcommon_sflash.c             |   34 +-
 drivers/ssb/main.c                                 |    8 +
 drivers/ssb/ssb_private.h                          |    4 +
 include/linux/ieee80211.h                          |    1 +
 include/linux/ssb/ssb_driver_mips.h                |   15 +
 include/net/cfg80211.h                             |  115 +-
 include/net/mac80211.h                             |   11 +-
 include/net/nfc/hci.h                              |    7 +-
 include/net/nfc/nci_core.h                         |   58 +-
 include/net/nfc/nfc.h                              |   35 +-
 include/uapi/linux/nfc.h                           |   18 +-
 include/uapi/linux/nl80211.h                       |    9 +
 net/mac80211/cfg.c                                 |   20 +-
 net/mac80211/ieee80211_i.h                         |    3 +-
 net/mac80211/main.c                                |    3 +-
 net/mac80211/mesh.c                                |   38 +-
 net/mac80211/mesh.h                                |    5 +-
 net/mac80211/mesh_plink.c                          |    7 +-
 net/mac80211/mlme.c                                |   98 +-
 net/mac80211/rx.c                                  |   26 +-
 net/mac80211/sta_info.c                            |    4 +-
 net/mac80211/sta_info.h                            |    3 +
 net/mac80211/tx.c                                  |    6 -
 net/mac80211/util.c                                |    5 +-
 net/nfc/core.c                                     |  224 +-
 net/nfc/hci/core.c                                 |   75 +-
 net/nfc/llcp.h                                     |    3 +-
 net/nfc/llcp_commands.c                            |   22 +-
 net/nfc/llcp_core.c                                |   16 +-
 net/nfc/llcp_sock.c                                |   19 +-
 net/nfc/nci/Kconfig                                |   10 +
 net/nfc/nci/Makefile                               |    4 +-
 net/nfc/nci/core.c                                 |   37 +-
 net/nfc/nci/data.c                                 |    2 -
 net/nfc/nci/spi.c                                  |  378 +++
 net/nfc/netlink.c                                  |  183 +-
 net/nfc/nfc.h                                      |   11 +
 net/wireless/core.c                                |   47 +-
 net/wireless/core.h                                |   30 +-
 net/wireless/ibss.c                                |    6 -
 net/wireless/mesh.c                                |   12 +
 net/wireless/mlme.c                                |  241 +-
 net/wireless/nl80211.c                             |  187 +-
 net/wireless/reg.c                                 |    2 +-
 net/wireless/sme.c                                 |  542 ++--
 net/wireless/trace.h                               |   46 +-
 net/wireless/wext-sme.c                            |    8 +-
 210 files changed, 27577 insertions(+), 2842 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath10k/Kconfig
 create mode 100644 drivers/net/wireless/ath/ath10k/Makefile
 create mode 100644 drivers/net/wireless/ath/ath10k/bmi.c
 create mode 100644 drivers/net/wireless/ath/ath10k/bmi.h
 create mode 100644 drivers/net/wireless/ath/ath10k/ce.c
 create mode 100644 drivers/net/wireless/ath/ath10k/ce.h
 create mode 100644 drivers/net/wireless/ath/ath10k/core.c
 create mode 100644 drivers/net/wireless/ath/ath10k/core.h
 create mode 100644 drivers/net/wireless/ath/ath10k/debug.c
 create mode 100644 drivers/net/wireless/ath/ath10k/debug.h
 create mode 100644 drivers/net/wireless/ath/ath10k/hif.h
 create mode 100644 drivers/net/wireless/ath/ath10k/htc.c
 create mode 100644 drivers/net/wireless/ath/ath10k/htc.h
 create mode 100644 drivers/net/wireless/ath/ath10k/htt.c
 create mode 100644 drivers/net/wireless/ath/ath10k/htt.h
 create mode 100644 drivers/net/wireless/ath/ath10k/htt_rx.c
 create mode 100644 drivers/net/wireless/ath/ath10k/htt_tx.c
 create mode 100644 drivers/net/wireless/ath/ath10k/hw.h
 create mode 100644 drivers/net/wireless/ath/ath10k/mac.c
 create mode 100644 drivers/net/wireless/ath/ath10k/mac.h
 create mode 100644 drivers/net/wireless/ath/ath10k/pci.c
 create mode 100644 drivers/net/wireless/ath/ath10k/pci.h
 create mode 100644 drivers/net/wireless/ath/ath10k/rx_desc.h
 create mode 100644 drivers/net/wireless/ath/ath10k/targaddrs.h
 create mode 100644 drivers/net/wireless/ath/ath10k/trace.c
 create mode 100644 drivers/net/wireless/ath/ath10k/trace.h
 create mode 100644 drivers/net/wireless/ath/ath10k/txrx.c
 create mode 100644 drivers/net/wireless/ath/ath10k/txrx.h
 create mode 100644 drivers/net/wireless/ath/ath10k/wmi.c
 create mode 100644 drivers/net/wireless/ath/ath10k/wmi.h
 create mode 100644 drivers/net/wireless/mwifiex/11h.c
 create mode 100644 drivers/net/wireless/ti/wlcore/sysfs.c
 create mode 100644 drivers/net/wireless/ti/wlcore/sysfs.h
 create mode 100644 drivers/nfc/nfcsim.c
 create mode 100644 net/nfc/nci/spi.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--bp/iNruPH9dso1Pn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRxLMVAAoJEJctW/TcYTgGKDAQAIYiS81xFazkDSiB7OEDuktA
9KxZFLWXj6/7fmTaP6LN00cyO2mXJtNEzDjnCwfaHN9QzDSHyDFcX8e4FFH95XEC
kI4Q5k7PFeHpCzshKDqjcXx8aLitllD5Kv7YiRPLx7BIOcN2Ps49wOjYYXP2CQYU
eAp5xCbZ3HlDyRuziZplZHZnBaJbBDT/u97X0cqLoMzGeyrt3pEhBiEc77++yvI1
hlvfkZHanB7uasJhiSKIvKKS+R9zJqTa3Dq8jt/GJMF9tIs+2eJJEowDmLDq7oc1
z4OHFJ02O3J1KkevbEqj7WzNbkqXxfh4mDpVL93zHGD0xiAGwgXV5TMEv2m+n2hm
LeaDsxvdgMA42DsZ6enVxFToGT8PSJdYpjrxYzgyyBKEe/NWQtPky/m9iBCvicWb
FJTeEUqFZt5dyjasC8ur+CRfs4tkzSOVolfouZ4c491MbCx8bO4TH6ZD+RFbxA43
70MU2pwd23KnRsKWqkVDaNB707PWTeuxcl9tw6B46KisMijth4wVdwC4v2/BI54+
7n9wWK7k51J4J64N8ewi5w0plcYV1AOgl0cdDSl1Vcsn1/YI0vZ8NrSKsv60jJbL
B/9Rqpbc5qgODRH+yAATEgUlgDneae66nr9aSwBulnJkCvC1Ixyd/ONWmA/tBsgM
XWOS+8fNFregn/qV9xoE
=ayUt
-----END PGP SIGNATURE-----

--bp/iNruPH9dso1Pn--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
