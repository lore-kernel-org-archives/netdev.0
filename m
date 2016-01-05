From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2016-01-05
Date: Tue, 05 Jan 2016 12:28:36 +0200
Message-ID: <87y4c4l3qj.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a big pull request for 4.5, which I should have sent to you
earlier but instead I was wasting my time with eating way too much
chocolate and keeping my brains in low power mode :)

Once again 'git request-pull' got diffstat wrong so I had to manually
fix it, but at least based on my investigation the pull request seems t=
o
be ok. Lots of new features and bugfixes as well as a new kconfig optio=
n
CONFIG_ATH9K_HWRNG to enable the new ath9k random number generator.

I'm hoping to send one more pull request later this week. Please let me
know if there are any problems.

The following changes since commit 4585436091cd812b1165aab71bd4847ea1cb=
08ec:

  iwlwifi: mvm: protect RCU dereference in iwl_mvm_get_key_sta_id (2015=
-12-13 13:38:26 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-01-05

for you to fetch changes up to 49f2a47d913184b97ef84b2e4fd438dbee341487=
:

  prism54: fix checks for dma mapping errors (2015-12-31 10:23:32 +0200=
)

----------------------------------------------------------------
brcfmac

* fix IBSS which got broken over time
* new USB id for bcm43242 dongle
* arp offload configuration through inet notifier

ath9k

* add random number generator support (CONFIG_ATH9K_HWRNG)

iwlwifi

* Make scan parameters low latency aware
* Fix in the NL80211_FEATURE_FULL_AP_CLIENT_STATE state case
* Fix enable injection mode (Chaya Rachel)
* Various cleanups (Dan / Julia / myself)
* Allow to stay more time on popular channels (David Spinadel)
* Bug fixes for D0i3 (Eliad / Luca)
* Fixes for GO uAPSD (myself)
* Start of TSO support (myself)
* Rate control bug fixes (Eyal / Gregory)
* Start the work on 9000 devices (Johannes / Sara / Oren)
* Start the work on a new Tx queue allocation model (Liad)
* Debug infrastructure enhancements (Golan)

mwifiex

* add a debugfs file for chip reset
* advertise SMS4 cipher suite
* increase ap and station interface limit to 3
* enable MSI support on newer pcie devices (8897 onwards)

rtlwifi

* fix lots of module parameter usage

----------------------------------------------------------------
Alexey Khoroshilov (1):
      prism54: fix checks for dma mapping errors

Amitkumar Karwar (13):
      mwifiex: parse adhoc start/join result
      mwifiex: handle start AP error paths correctly
      mwifiex: set regulatory info from EEPROM
      mwifiex: don't follow AP if country code received from EEPROM
      mwifiex: correction in region code to country mapping
      mwifiex: suppress "Rx of mgmt packet failed" message
      mwifiex: remove redundant timestamp assignment
      mwifiex: add debugfs file for testing reset of card
      mwifiex: fix AMPDU not setup on TDLS link problem
      mwifiex: update region_code_index array
      mwifiex: use world for unidentified region code
      mwifiex: fix PCIe register information for 8997 chipset
      mwifiex: add missing check for PCIe8997 chipset

Arend van Spriel (2):
      brcmfmac: no interface combination check for single interface
      brcmfmac: add 43242 device id for LG dongle

Arnd Bergmann (1):
      iwlegacy: mark il_adjust_beacon_interval as noinline

Avinash Patil (1):
      mwifiex: enable MSI interrupt support in pcie

Avraham Stern (1):
      iwlwifi: mvm: configure scheduled scan according to traffic condi=
tions

Ayala Beker (1):
      iwlwifi: mvm: Change number of associated stations when station b=
ecomes associated

Ben Greear (2):
      ath6kl: fix tx/rx antenna reporting for 2x2 devices
      ath6kl: add log messages for firmware failure cases.

Bob Copeland (1):
      ath5k: fix RTS/CTS by using proper rate flags

Chaya Rachel Ivgi (1):
      iwlwifi: mvm: Add a station in monitor mode

Colin Ian King (2):
      brcmfmac: only lock and unlock fws if fws is not null
      ath9k: fix inconsistent indenting on return statement

Dan Carpenter (6):
      cw1200: remove some dead code
      iwlegacy: cleanup end of il_send_add_sta()
      mwifiex: remove an unneeded condition
      hostap: fix an error code in prism2_config()
      prism54: off by one BUG_ON() test
      iwlwifi: mvm: remove an extra tab

David Spinadel (1):
      iwlwifi: mvm: add extended dwell time

Eliad Peller (6):
      iwlwifi: mvm: cleanup roc te on restart cleanup
      iwlwifi: mvm: check iwl_mvm_wowlan_config_key_params() return val=
ue
      iwlwifi: avoid d0i3 commands when no/init ucode is loaded
      iwlwifi: mvm: remove the vif parameter of iwl_mvm_configure_bcast=
_filter()
      iwlwifi: update key params on d0i3 entrance/exit
      iwlwifi: bail out in case of bad trans state

Emmanuel Grumbach (18):
      iwlwifi: pcie: allow the op_mode to block the tx queues
      iwlwifi: trans: support a callback for ASYNC commands
      iwlwifi: block the queues when we send ADD_STA for uAPSD
      iwlwifi: uninline iwl_trans_send_cmd
      Merge tag 'mac80211-next-for-davem-2015-12-07' into next
      iwlwifi: mvm: close the SP if we send fewer frames than expected =
in SP
      Merge tag 'iwlwifi-for-kalle-2015-12-16' into next
      iwlwifi: change the Intel Wireless email address
      iwlwifi: pcie: allow to pretend to have Tx CSUM for debug
      iwlwifi: mvm: prepare the code towards TSO implementation
      iwlwifi: pcie: re-organize code towards TSO
      iwlwifi: clear ieee80211_tx_info->driver_data in the op_mode
      iwlwifi: pcie: build an A-MSDU using TSO core
      iwlwifi: 9000: increase the number of queues
      iwlwifi: mvm: small update in the firmware API
      iwlwifi: mvm: dump more registers upon error
      iwlwifi: remove unused parameter from grab_nic_access
      iwlwifi: fix printf specifier

Eyal Shapira (1):
      iwlwifi: mvm: rs: fix a potential out of bounds access

=46elix Fietkau (1):
      ath10k: do not use coherent memory for allocated device memory ch=
unks

Golan Ben-Ami (2):
      iwlwifi: expose fw usniffer mode to more utilities
      iwlwifi: mvm: support description for user triggered fw dbg colle=
ction

Gregory Greenman (1):
      iwlwifi: mvm: add an option to start rs from HT/VHT rates

Guy Mishol (1):
      wlcore: split wl12xx/wl18xx sg parameters

Hante Meuleman (9):
      brcmfmac: Simplify scan timing configuration
      brcmfmac: Use local storage for ssid iovar
      brcmfmac: Remove some redundant cfg80211 data
      brcmfmac: Cleanup pmksa cache handling code
      brcmfmac: Make TDLS a detectable feature
      brcmfmac: Add support for PCIE 4350 revision 5 device
      brcmfmac: Fix IBSS setup
      brcmfmac: Change error print in debug print
      brcmfmac: Move scheduled scan related interface layer structs

Janusz Dziedzic (11):
      ath9k: add debug messages to aggr/chanctx funcs
      ath9k: print real timer value
      ath9k: queue null frames in case of MCC
      ath9k: P2P_CLIENT, send frames after 1ms AP/GO will aprear
      ath9k: use u32 when calculate tsf
      ath9k: setup correct skb priority for nullfunc
      ath9k: MCC enable Opportunistic Power Save
      ath9k: P2P_CLIENT, get/set NOA correctly
      ath9k: MCC, add NOA also in case of an AP
      ath9k: MCC, print time elapsed between events
      ath9k: remove ath9k_mod_tsf64_tu

Johannes Berg (4):
      iwlwifi: mvm: advertise NETIF_F_SG
      iwlwifi: dvm: advertise NETIF_F_SG
      iwlwifi: mvm: change iwl_mvm_get_key_sta_id() to return the stati=
on
      iwlwifi: mvm: add 9000 series RX processing

Julia Lawall (4):
      brcm80211: fix compare_const_fl.cocci warnings
      mwifiex: fix semicolon.cocci warnings
      prism54: fix compare_const_fl.cocci warnings
      iwlwifi: dvm: fix compare_const_fl.cocci warnings

Kalle Valo (2):
      Merge ath-next from ath.git
      Merge tag 'iwlwifi-next-for-kalle-2015-12-21' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next

Kosuke Tatsukawa (1):
      brcmfmac: fix waitqueue_active without memory barrier in brcmfmac=
 driver

Larry Finger (9):
      rtlwifi: rtl8723be: Fix module parameter initialization
      rtlwifi: rtl8723ae: Fix initialization of module parameters
      rtlwifi: rtl8821ae: Fix errors in parameter initialization
      rtlwifi: rtl8188ee: Fix module parameter initialization
      rtlwifi: rtl8192de: Fix incorrect module parameter descriptions
      rtlwifi: rtl8192se: Fix module parameter initialization
      rtlwifi: rtl8192ce: Fix handling of module parameters
      rtlwifi: rtl8192cu: Add missing parameter setup
      rtlwifi: rtl_pci: Fix kernel panic

Liad Kaufman (1):
      iwlwifi: mvm: set default new STA as non-aggregated

Luca Coelho (3):
      iwlwifi: mvm: don't keep an mvm ref when the interface is down
      iwlwifi: replace d0i3_mode and wowlan_d0i3 with more generic vari=
ables
      iwlwifi: mvm: refactor the way fw_key_table is handled

Martin Blumenstingl (1):
      ath9k: Simplify and fix eeprom endianness swapping

Maya Erez (1):
      wil6210: prevent external wmi commands during suspend flow

Miaoqing Pan (2):
      ath9k: fix AR_RX_FILTER for ar9462/ar9565 when rx stopped
      ath9k: feeding entropy in kernel from ADC capture

Mohammed Shafi Shajakhan (1):
      ath10k: remove unnecessary amsdu/ampdu assignment in debugfs

Nicholas Mc Guire (2):
      rsi: consolidate kmalloc/memset 0 calls to kzalloc
      rsi: bool tests do not need comparison

Oren Givon (1):
      iwlwifi: Update PCI IDs for 8000 and 9000 series

Peter Oh (1):
      ath10k: allow Mesh Point to install peer security key

Peter Wu (1):
      rtlwifi: fix memory leak for USB device

Rafa=C5=82 Mi=C5=82ecki (2):
      ssb: pick SoC invariants code from MIPS BCM47xx arch
      bcma: use module_init for the main part of bus initialization

Sara Sharon (3):
      iwlwifi: mvm: change protocol offload flows
      iwlwifi: mvm: enable L3 filtering
      iwlwifi: mvm: infrastructure for frame-release message

Shahar Patury (1):
      wlcore/wl18xx: fw logger over sdio

Sharon Dvir (1):
      iwlwifi: update host command messages to new format

Shengzhen Li (2):
      mwifiex: change ap and station interface limits
      mwifiex: multiple bss support

Steve deRosier (1):
      ath6kl: Don't print error message when recv is canceled

Uri Mashiach (2):
      wlcore/wl12xx: spi: fix oops on firmware load
      wlcore/wl12xx: spi: fix NULL pointer dereference (Oops)

Xinming Hu (3):
      mwifiex: fix bug for wildcard-prefix wowlan pattern
      mwifiex: increase supported wowlan pattern length
      mwifiex: abort cac in del_station() handler

Zhaoyang Liu (1):
      mwifiex: advertise SMS4 cipher suite

chunfan chen (3):
      mwifiex: fix wake on disconnect feature
      mwifiex: fix WPA connection problem
      mwifiex: fix potential integer truncation

 arch/mips/bcm47xx/setup.c                          |   39 +-
 drivers/bcma/main.c                                |   29 +-
 drivers/net/wireless/ath/ath10k/debug.c            |    2 +-
 drivers/net/wireless/ath/ath10k/mac.c              |    3 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   61 ++-
 drivers/net/wireless/ath/ath5k/base.c              |    2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |    5 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   16 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   11 +
 drivers/net/wireless/ath/ath9k/Makefile            |    1 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |   23 +
 drivers/net/wireless/ath/ath9k/beacon.c            |    3 +-
 drivers/net/wireless/ath/ath9k/channel.c           |   56 ++-
 drivers/net/wireless/ath/ath9k/common-beacon.c     |   22 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |   74 ++++
 drivers/net/wireless/ath/ath9k/eeprom.h            |    3 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   76 +---
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   68 +--
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   61 +--
 drivers/net/wireless/ath/ath9k/hw.c                |   11 +-
 drivers/net/wireless/ath/ath9k/main.c              |    4 +
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +
 drivers/net/wireless/ath/ath9k/rng.c               |  107 +++++
 drivers/net/wireless/ath/ath9k/xmit.c              |   23 +-
 drivers/net/wireless/ath/wil6210/main.c            |    4 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |    4 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  233 +++++-----
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |  111 +----
 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.h |    4 +-
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |  105 +++++
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |    7 +-
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |    3 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    8 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    6 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |    4 +-
 .../wireless/broadcom/brcm80211/brcmsmac/channel.c |    4 +-
 .../broadcom/brcm80211/include/brcm_hw_ids.h       |    2 +
 .../broadcom/brcm80211/include/brcmu_wifi.h        |   23 -
drivers/net/wireless/intel/iwlegacy/common.c       |   14 +-
 drivers/net/wireless/intel/iwlwifi/dvm/agn.h       |   11 +-
 drivers/net/wireless/intel/iwlwifi/dvm/calib.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c   |    6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/dev.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/led.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |    5 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |  100 ++++-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.h        |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c        |   89 +---
 drivers/net/wireless/intel/iwlwifi/dvm/rxon.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/scan.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/sta.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/tt.c        |    4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/tt.h        |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/tx.c        |    3 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-debug.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-debug.h     |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-devtrace-data.h |   17 +
 .../wireless/intel/iwlwifi/iwl-devtrace-iwlwifi.h  |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-devtrace.c  |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-devtrace.h  |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.h       |    4 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.c  |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |   16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-op-mode.h   |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |   91 ++++
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |  201 ++++++---
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile    |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/coex_legacy.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  141 ++++--
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |    8 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-coex.h   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h |   17 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   20 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |   24 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |    7 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |   35 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   18 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   84 ++--
drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   65 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/offloading.c    |   74 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  332 +++++++++---=
---
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/quota.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   74 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  378 ++++++++++++=
+++++
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   86 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  118 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   14 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tdls.c      |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.c    |   38 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.h    |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/tof.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  112 ++++-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   13 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   23 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |    5 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   85 +++-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |  447 ++++++++++++=
+++++---
 drivers/net/wireless/intersil/hostap/hostap_cs.c   |    6 +-
 drivers/net/wireless/intersil/prism54/isl_ioctl.c  |    2 +-
 drivers/net/wireless/intersil/prism54/islpci_dev.c |    4 +-
 drivers/net/wireless/intersil/prism54/islpci_eth.c |    5 +-
 drivers/net/wireless/intersil/prism54/islpci_mgt.c |    4 +-
 drivers/net/wireless/intersil/prism54/oid_mgt.c    |   10 +-
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c    |    2 -
 .../net/wireless/marvell/mwifiex/11n_rxreorder.c   |   10 +
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   62 ++-
 drivers/net/wireless/marvell/mwifiex/cfp.c         |    6 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |    4 +-
 drivers/net/wireless/marvell/mwifiex/debugfs.c     |   30 ++
 drivers/net/wireless/marvell/mwifiex/decl.h        |    6 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   13 +-
 drivers/net/wireless/marvell/mwifiex/ie.c          |    2 +-
 drivers/net/wireless/marvell/mwifiex/init.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/join.c        |   20 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |   50 ++-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   33 +-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   10 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |   85 ++--
 drivers/net/wireless/marvell/mwifiex/sta_rx.c      |    2 +-
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |    6 +-
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c    |    3 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |   11 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |    7 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |    2 +
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    |    2 +
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |    9 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |    9 +-
 drivers/net/wireless/realtek/rtlwifi/usb.c         |    2 +
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |    5 +-
 drivers/net/wireless/st/cw1200/sta.c               |    6 -
 drivers/net/wireless/ti/wl12xx/conf.h              |  233 ++++++++++
 drivers/net/wireless/ti/wl12xx/main.c              |  116 ++---
 drivers/net/wireless/ti/wl18xx/conf.h              |   90 ++++
 drivers/net/wireless/ti/wl18xx/event.c             |    2 +
 drivers/net/wireless/ti/wl18xx/event.h             |    1 +
 drivers/net/wireless/ti/wl18xx/main.c              |  147 ++++---
 drivers/net/wireless/ti/wlcore/acx.c               |    4 +-
 drivers/net/wireless/ti/wlcore/acx.h               |    2 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    1 -
 drivers/net/wireless/ti/wlcore/conf.h              |  237 +----------
 drivers/net/wireless/ti/wlcore/debugfs.c           |   60 +++
 drivers/net/wireless/ti/wlcore/event.c             |   82 ++++
 drivers/net/wireless/ti/wlcore/event.h             |    9 +
 drivers/net/wireless/ti/wlcore/io.c                |   11 +-
 drivers/net/wireless/ti/wlcore/io.h                |   14 +-
 drivers/net/wireless/ti/wlcore/main.c              |   96 +----
 drivers/net/wireless/ti/wlcore/rx.c                |    1 -
 drivers/net/wireless/ti/wlcore/spi.c               |   10 +-
 drivers/net/wireless/ti/wlcore/sysfs.c             |   26 --
 drivers/net/wireless/ti/wlcore/wlcore.h            |    3 -
 drivers/ssb/Kconfig                                |    2 +-
 drivers/ssb/host_soc.c                             |   37 ++
 drivers/ssb/main.c                                 |    5 +-
 drivers/ssb/ssb_private.h                          |    3 +
 include/linux/ssb/ssb.h                            |   10 +-
 184 files changed, 3889 insertions(+), 1884 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/rng.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
