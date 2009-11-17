From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-11-17
Date: Tue, 17 Nov 2009 11:10:38 -0500
Message-ID: <20091117161038.GA2854@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46527 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbZKQQP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 11:15:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another round of wireless bits for -next...

Included are a bunch of rt2x00 updates (related to rt2800{usb,pci}), an
802.11s mesh support refresh to match current drafts of the spec, big
ath9k and iwlwifi drivers updates, new mac80211 support for using
4-address frames to talk to APs, a smattering of other driver and
infrastructure updates, and of course my fix for the zdnet build break.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 2071a0084a0323697b7d6fd5a98982194bd6929f:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Bartlomiej Zolnierkiewicz (10):
      rt2800: prepare for unification of EEPROM support code
      rt2800: unify EEPROM support code
      rt2800pci: add missing RF values to rf_vals table
      rt2800usb: reorganize code in rt2800usb_probe_hw_mode()
      rt2800: prepare for rt2800*_probe_hw_mode() unification
      rt2800: unify rt2800*_probe_hw_mode()
      rt2800usb: fix RX descriptor naming
      rt2800: add eFuse EEPROM support code to rt2800lib
      rt2800usb: add eFuse EEPROM support
      rt2500usb: remove dead link tuning code

Ben Hutchings (13):
      at76c50x-usb: declare MODULE_FIRMWARE
      atmel: declare MODULE_FIRMWARE
      ipw2100: declare MODULE_FIRMWARE
      ipw2200: declare MODULE_FIRMWARE
      iwmc3200wifi: declare MODULE_FIRMWARE
      libertas: declare MODULE_FIRMWARE
      libertas_tf_usb: declare MODULE_FIRMWARE
      mwl8k: declare MODULE_FIRMWARE
      orinoco: declare MODULE_FIRMWARE
      prism54: declare MODULE_FIRMWARE
      wl12xx: declare MODULE_FIRMWARE
      zd1201: declare MODULE_FIRMWARE
      zd1211rw: declare MODULE_FIRMWARE

Ben M Cahill (6):
      iwlwifi: Limit size of Event Log dump
      iwlwifi: speed up event log dumps
      iwlwifi: Update comments for struct iwl_ssid_ie
      iwlwifi: Add comments about MAC_ACCESS_REQ
      iwlagn: update write pointers in iwl_irq_tasklet()
      iwlwifi: MAC_ACCESS_REQ cleanup

Bob Copeland (1):
      ath5k: allow setting txpower to 0

Felix Fietkau (5):
      nl80211: add a parameter for using 4-address frames on virtual interfaces
      mac80211: implement support for 4-address frames for AP and client mode
      mac80211: fix broadcast frame handling for 4-addr AP VLANs
      nl80211: only allow adding stations to running vlan interfaces
      ath9k: fix massive rx packet loss issue

Gertjan van Wingerde (10):
      rt2x00: Move interface type assignments to generic code.
      rt2x00: Fix building of rt2800lib when rt2x00 driver is built-in.
      rt2x00: Add dynamic detection of eFuse EEPROM in rt2800pci.
      rt2x00: Update copyright statements.
      rt2x00: Fix typo in rf programming of rt2800lib.
      rt2x00: Properly detect Ralink RT3070 devices.
      rt2x00: Fix rt2800lib RF chip programming selection.
      rt2x00: Initialize rf302x RF values properly for rt2800pci.
      rt2x00: Log RT/RF chipset information correctly.
      rt2x00: Fix BUG on rt2800usb when trying to read eFuse EEPROM.

Holger Schurig (2):
      cfg80211: introduce nl80211_get_ifidx()
      cfg80211: return channel noise via survey API

Ivo van Doorn (1):
      rt2x00: Remove deprecated ieee80211_rx_status->qual usage

Jason Andryuk (2):
      at76c50x-usb: Remove mac2str and replace with %pM format specifier.
      at76c50x-usb: Supply additional parameters to at76_start_monitor scan request

Johannes Berg (3):
      iwlwifi: don't double-activate queue 4
      iwlwifi: fix FIFO vs. queue confusion
      iwlwifi: add FIFO usage for 5000

John W. Linville (1):
      znet: fix build failure from i82593.h relocation

Josef Bacik (1):
      rt2800: do not enable tbtt unless we are in a beacon mode

Jouni Malinen (1):
      mac80211: Do not queue Probe Request frames for station MLME

Julia Lawall (1):
      drivers/net/wireless: correct check on CCS_START_NETWORK

Jussi Kivilinna (1):
      rndis_wlan: handle NL80211_AUTHTYPE_AUTOMATIC

Luis R. Rodriguez (30):
      ath9k: fix listening to idle requests
      ath9k: update hw configuration for virtual wiphys
      ath9k: simpify RX by calling ath_get_virt_hw() once
      ath9k: use the passed ieee80211_hw on ath_rx_prepare()
      ath9k: pass the ieee80211_hw on radio enable/disable
      ath9k: use correct hw for tx aggregation TX completion
      ath9k: use the right hw on ath_tx_setup_buffer() for HT
      ath9k: handle low buffer space for virtual wiphys
      ath9k: do not pass the entire descriptor to ath_rx_prepare()
      ath9k_hw: move ath_extend_tsf() to hw code to share as ath9k_hw_extend_tsf()
      ath9k: move struct ath_ani to common area
      ath9k: use the ieee80211_hw to get to an sband on ath_rx_prepare()
      ath9k: move RX check code into helper ath9k_rx_accept()
      ath9k: remove temp variable ratecode from ath_rx_prepare()
      ath9k: move rate descriptor reading into a helper
      ath9k: move qual processing into a helper
      ath9k: move rssi processing into a helper
      ath9k: avoid the copy skb->cb on every RX'd skb
      ath9k: move the rx_stats->rs_datalen check to ath9k_rx_accept()
      ath: move the rx bufsize to common to share with ath5k/ath9k
      ath5k: remove double cache alignment, ath_rxbuf_alloc() already does it
      ath9k: move the max rx buffer size check to ath9k_rx_accept()
      ath9k: rename ath_rx_prepare() to ath9k_rx_skb_preprocess()
      ath9k: move driver keymap, keymax and splitmic to common
      ath5k: use the common->keymap
      ath9k: move RX skb post processing to a helper
      ath9k_common: add new module to share 802.11n driver helpers
      ath9k_common: remove ath9k_compute_qual()
      ath9k_common: clarify and correct jumbogram processing
      mac80211: fix max HT rate processing on mac80211

Michael Buesch (2):
      b43: Rewrite TX bounce buffer handling
      b43-pio: Fix RX error path for rev>=8 devices

Randy Dunlap (1):
      staging/wireless: don't build when NET etc. are not enabled

Reinette Chatre (1):
      iwlwifi: change debug message to error in failure case

Rui Paulo (20):
      mac80211: update meshconf IE
      mac80211: set MESH_TTL to 31
      mac80211: implement the meshconf formation info field
      mac80211: fix typo in a comment
      mac80211: update peer link management IE and action frames
      mac80211: update the format of path selection frames
      mac80211: add MAC80211_VERBOSE_MHWMP_DEBUG
      mac80211: allow processing of more than one HWMP IE
      mac80211: improve HWMP debugging
      mac80211: improve peer link management debugging
      mac80211: implement RANN processing and forwarding
      mac80211: update PERR frame format
      mac80211: properly forward the RANN IE
      mac80211: set the AID field correctly for mesh peer frames
      mac80211: fix BSSID setup for beacon frames
      mac80211: add the DS params to the beacon
      mac80211: replace "destination" with "target" to follow the spec
      mac80211: implement a timer to send RANN action frames
      mac80211: add nl80211/cfg80211 handling of the new mesh root mode option.
      mac80211: update copyrights to 2009

Shanyu Zhao (2):
      iwlwifi: use only one chain for scan in PS
      iwlwifi: use configured valid rx chain for scan

Thadeu Lima de Souza Cascardo (2):
      rt2x00: fix some typos and punctuation in comments
      rt2800lib: fix some typos and punctuation in comments

Vasanthakumar Thiagarajan (2):
      ath9k_hw: Fix possible OOB array indexing in gen_timer_index[] on 64-bit
      ath9k_hw: Fix AR_GPIO_INPUT_EN_VAL_BT_PRIORITY_BB and its shift value in 0x4054

Wey-Yi Guy (7):
      iwlwifi: print rx_on config to help debug
      iwlwifi: no periodic Tx/IQ calibration for 6x00/6x50 series
      iwlwifi: remove un-used parameter
      iwlwifi: fix for channel switch
      iwlwifi: drop non-production PCI-IDs
      iwlwifi: do not base station's sm_ps setting on AP
      iwlwifi: Fix issue on file transfer stalled in HT mode

Zhu Yi (1):
      iwlwifi: allocate 128 bytes linear buffer for rx skb

 drivers/net/wireless/at76c50x-usb.c                |   45 +-
 drivers/net/wireless/ath/ath.h                     |   28 ++
 drivers/net/wireless/ath/ath5k/base.c              |   32 +-
 drivers/net/wireless/ath/ath5k/base.h              |    2 -
 drivers/net/wireless/ath/ath5k/phy.c               |    2 -
 drivers/net/wireless/ath/ath9k/Kconfig             |    3 +
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |  130 +-----
 drivers/net/wireless/ath/ath9k/common.c            |  286 +++++++++++
 drivers/net/wireless/ath/ath9k/common.h            |  123 +++++
 drivers/net/wireless/ath/ath9k/hw.c                |   15 +
 drivers/net/wireless/ath/ath9k/hw.h                |    3 +-
 drivers/net/wireless/ath/ath9k/main.c              |  243 ++++++-----
 drivers/net/wireless/ath/ath9k/rc.h                |    2 +
 drivers/net/wireless/ath/ath9k/recv.c              |  313 ++-----------
 drivers/net/wireless/ath/ath9k/reg.h               |    4 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |   79 +++-
 drivers/net/wireless/ath/ath9k/xmit.c              |   21 +-
 drivers/net/wireless/atmel.c                       |   16 +
 drivers/net/wireless/b43/dma.c                     |   48 +--
 drivers/net/wireless/b43/pio.c                     |    6 +-
 drivers/net/wireless/b43/xmit.h                    |   19 +
 drivers/net/wireless/ipw2x00/ipw2100.c             |    6 +
 drivers/net/wireless/ipw2x00/ipw2200.c             |    5 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   16 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  106 +----
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   79 ++--
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    7 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   54 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    5 +
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   22 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   20 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   19 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |    5 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   18 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   12 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   42 ++-
 drivers/net/wireless/iwmc3200wifi/sdio.c           |    3 +
 drivers/net/wireless/libertas/if_cs.c              |    1 +
 drivers/net/wireless/libertas/if_sdio.c            |    6 +
 drivers/net/wireless/libertas/if_spi.c             |    4 +
 drivers/net/wireless/libertas/if_usb.c             |    2 +
 drivers/net/wireless/libertas_tf/if_usb.c          |    2 +
 drivers/net/wireless/mwl8k.c                       |    3 +
 drivers/net/wireless/orinoco/fw.c                  |    6 +
 drivers/net/wireless/prism54/islpci_dev.c          |    3 +
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    2 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |  137 +------
 drivers/net/wireless/rt2x00/rt2500usb.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   38 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  494 +++++++++++++++++++-
 drivers/net/wireless/rt2x00/rt2800lib.h            |   17 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |  416 +---------------
 drivers/net/wireless/rt2x00/rt2800pci.h            |   37 +--
 drivers/net/wireless/rt2x00/rt2800usb.c            |  418 +----------------
 drivers/net/wireless/rt2x00/rt2800usb.h            |   46 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   22 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    3 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |    2 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00leds.h           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   16 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |   90 +----
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    3 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00soc.c            |    8 +-
 drivers/net/wireless/rt2x00/rt2x00soc.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    4 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   39 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    3 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    2 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |    1 +
 drivers/net/wireless/wl12xx/wl1271_main.c          |    1 +
 drivers/net/wireless/zd1201.c                      |    3 +
 drivers/net/wireless/zd1211rw/zd_usb.c             |    7 +
 drivers/net/znet.c                                 |    3 +-
 drivers/staging/arlan/Kconfig                      |    2 +-
 drivers/staging/netwave/Kconfig                    |    2 +-
 drivers/staging/wavelan/Kconfig                    |    4 +-
 drivers/staging/wavelan/wavelan_cs.p.h             |    2 +-
 .../staging/wavelan => include/linux}/i82593.h     |    0
 include/linux/ieee80211.h                          |   17 +-
 include/linux/nl80211.h                            |   49 ++-
 include/net/cfg80211.h                             |   45 ++-
 net/mac80211/Kconfig                               |   13 +
 net/mac80211/cfg.c                                 |   47 ++-
 net/mac80211/debugfs_netdev.c                      |    2 +
 net/mac80211/ieee80211_i.h                         |   27 +-
 net/mac80211/iface.c                               |    4 +
 net/mac80211/mesh.c                                |  143 ++++--
 net/mac80211/mesh.h                                |   28 +-
 net/mac80211/mesh_hwmp.c                           |  388 ++++++++++-----
 net/mac80211/mesh_pathtbl.c                        |   18 +-
 net/mac80211/mesh_plink.c                          |   56 ++-
 net/mac80211/mlme.c                                |    1 -
 net/mac80211/rx.c                                  |   40 ++-
 net/mac80211/sta_info.c                            |    3 +
 net/mac80211/tx.c                                  |   47 ++-
 net/mac80211/util.c                                |    4 +
 net/wireless/nl80211.c                             |  208 +++++++--
 net/wireless/util.c                                |    4 +-
 122 files changed, 2688 insertions(+), 2220 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/common.c
 create mode 100644 drivers/net/wireless/ath/ath9k/common.h
 rename {drivers/staging/wavelan => include/linux}/i82593.h (100%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-11-17.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
