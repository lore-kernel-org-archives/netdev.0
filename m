From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-12-07
Date: Mon, 07 Dec 2015 19:46:45 +0200
Message-ID: <878u56cfsq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's the first "real" pull request after the wireless directory
reorganisation. Nothing really out ordinary, new features and bugfixes
as usual. This time there's a regression in ath10k because of a bugfix
in wireless-drivers.git which conflicted with a patch in
wireless-drivers-next.git. But it should be easy to fix, just follow
what Stephen did in in linux-next:

http://article.gmane.org/gmane.linux.kernel.next/37391

Please let me know if you have any problems.

Kalle

The following changes since commit 6d808eba602b00f77f26191f45328774ff057cc0:

  mac80211_hwsim: move Kconfig entry for sorting alphabetically (2015-11-18 15:23:36 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-12-07

for you to fetch changes up to 2abcd3d40d2cae8d4698ba4b0f4d6c793dda6f8b:

  Merge tag 'iwlwifi-next-for-kalle-2015-12-01' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2015-12-03 17:23:43 +0200)

----------------------------------------------------------------

brcfmac

* support bcm4359 which can operate in two bands concurrently
* disable runtime pm for USB avoiding issues
* use generic pm callback in PCIe driver
* support wowlan wake indication reporting
* add beamforming support
* unified handling of firmware files

ath10k

* support Manegement Frame Protection (MFP)
* add thermal throttling support for 10.4 firmware
* add support for pktlog in QCA99X0
* add debugfs file to enable Bluetooth coexistence feature
* use firmware's native mesh interface type instead of raw mode

iwlwifi

* BT coex improvements
* D3 operation bugfixes
* rate control improvements
* firmware debugging infra improvements
* ground work for multi Rx
* various security fixes

----------------------------------------------------------------
Andy Green (5):
      wcn36xx: introduce WCN36XX_HAL_AVOID_FREQ_RANGE_IND
      wcn36xx: swallow two wcn3620 IND messages
      wcn36xx: handle new hal response format
      wcn36xx: use new response format for wcn3620 trigger_ba
      wcn36xx: use new response format for wcn3620 remove_bsskey

Andy Shevchenko (2):
      rtlwifi: btcoexist: re-use %*ph specifier to hexdump
      wireless: airo: re-use mac_pton()

Arend van Spriel (1):
      brcmfmac: assure net_ratelimit() is declared before use

Avraham Stern (1):
      iwlwifi: mvm: Configure fragmented scan for scheduled scan

Avri Altman (2):
      iwlwifi: mvm: Enable MPLUT only on supported hw
      iwlwifi: mvm: Align bt-coex priority with requirements

Dan Carpenter (5):
      ath9k_htc: check for underflow in ath9k_htc_rx_msg()
      rt2x00: type bug in _rt2500usb_register_read()
      libertas: cleanup a variable name
      brcm80211: fix error code in brcmf_pcie_exit_download_state()
      iwlwifi: mvm: rs: fix a warning message

Derek Basehore (1):
      iwlwifi: mvm: report wakeup for wowlan

Dreyfuss, Haim (1):
      iwlwifi: Add new PCI IDs for 9260 and 5165 series

Eliad Peller (2):
      iwlwifi: mvm: refactor d3 key update functions
      iwlwifi: remove IWL_DL_LED

Emmanuel Grumbach (4):
      Merge remote-tracking branch 'iwlwifi-fixes/master' into next
      iwlwifi: add support for 12K Receive Buffers
      iwlwifi: mvm: change name of iwl_mvm_d3_update_gtk
      iwlwifi: change the Intel Wireless email address

Eyal Shapira (1):
      iwlwifi: mvm: drop low_latency_agg_frame_cnt_limit

Felix Fietkau (1):
      ath10k: stop abusing GFP_DMA

Franky Lin (1):
      brcmfmac: no retries on rxglom superframe errors

Golan Ben Ami (1):
      iwlwifi: mvm: Support setting continuous recording debug mode

Golan Ben-Ami (4):
      iwlwifi: mvm: add trigger for firmware dump upon TDLS events
      iwlwifi: export the _no_grab version of PRPH IO functions
      iwlwifi: dump prph registers in a common place for all transports
      iwlwifi: mvm: move fw-dbg code to separate file

Hante Meuleman (17):
      brcmfmac: Add support for the BCM4359 11ac RSDB PCIE device.
      brcmfmac: Simplify and fix usage of brcmf_ifname.
      brcmfmac: Remove unnecessary check from start_xmit.
      brcmfmac: Remove unncessary variable irq_requested.
      brcmfmac: Disable runtime pm for USB.
      brcmfmac: Add RSDB support.
      brcmfmac: Use consistent naming for bsscfgidx.
      brcmfmac: Use new methods for pcie Power Management.
      brcmfmac: Add wowl wake indication report.
      brcmfmac: Cleanup ssid storage.
      brcmfmac: Return actual error by fwil.
      brcmfmac: Change error print on wlan0 existence.
      brcmfmac: Remove redundant parameter action from scan.
      brcmfmac: Cleanup roaming configuration.
      brcmfmac: Add beamforming support.
      brcmfmac: Unify methods to define and map firmware files.
      brcmfmac: Fix double free on exception at module load.

Johannes Berg (11):
      iwlwifi: nvm: fix up phy section when reading it
      iwlwifi: dvm: remove Kconfig default
      iwlwifi: trans: make various conversion macros inlines
      iwlwifi: dvm: remove stray debug code
      iwlwifi: pcie: remove ICT allocation message
      iwlwifi: mvm: use build-time assertion for fw trigger ID
      iwlwifi: clean up transport debugfs handling
      iwlwifi: pcie: remove pointer from debug message
      iwlwifi: mvm: use firmware station lookup, combine code
      iwlwifi: print index in api/capa flags parsing message
      iwlwifi: mvm: add 9000-series RX API

Julia Lawall (1):
      brcmfmac: constify brcmf_bus_ops structures

Kalle Valo (8):
      ath10k: fix otp board id error message
      ath10k: reorganise hardware and firmware info messages
      ath10k: always show bmi chip ids and subdevice ids
      ath10k: split driver info messages during device initialisation
      ath10k: print crc32 checksums for firmware and board files
      ath10k: implement fw_checksums debugfs file
      Merge ath-next from ath.git
      Merge tag 'iwlwifi-next-for-kalle-2015-12-01' of https://git.kernel.org/.../iwlwifi/iwlwifi-next

Luca Coelho (6):
      iwlwifi: mvm: ignore LMAC scan notifications when running UMAC scans
      iwlwifi: generalize d0i3_entry_timeout module parameter
      iwlwifi: mvm: remove redundant d0i3 flag from the config struct
      iwlwifi: mvm: remove stray nd_config element
      iwlwifi: mvm: flush all used TX queues before suspending
      iwlwifi: mvm: remove unnecessary check in iwl_mvm_is_d0i3_supported()

Manikanta Pubbisetty (1):
      ath10k: consolidate if statements in ath10k_wmi_event_mgmt_rx

Markus Elfring (2):
      brcm80211: Delete an unnecessary check before the function call "release_firmware"
      rtlwifi: Delete unnecessary checks before the function call "kfree_skb"

Matti Gottlieb (2):
      iwlwifi: mvm: check FW's response for nvm access write cmd
      iwlwifi: mvm: ROC: Extend the ROC max delay duration & limit ROC duration

Michal Kazior (9):
      ath10k: merge is_protected with nohwcrypt
      ath10k: rename function to adhere to naming convention
      ath10k: remove txmode from skb_cb
      ath10k: remove is_offchan
      ath10k: remove freq from skb_cb
      ath10k: pack up flags in skb_cb
      ath10k: fix tx header parsing
      ath10k: replace vdev_id and tid in skb cb
      ath10k: store msdu_id instead of txbuf pointers

Mohammed Shafi Shajakhan (2):
      ath10k: Enable AP + STA interface combination support for 10.x
      ath10k: Fix write permission on few debugfs files

Moshe Harel (2):
      iwlwifi: mvm: add bt settings to debugfs
      iwlwifi: mvm: add bt rrc and ttc to debugfs

Nicholas Krause (1):
      iwlwifi: mvm: fix incorrect fallthrough in iwl_mvm_check_running_scans()

Oren Givon (2):
      iwlwifi: Add PCI IDs for the new 3168 series
      iwlwifi: Add PCI IDs for the new series 8165

Peter Oh (4):
      ath10k: fix board data fetch error message
      ath10k: update WMI 10.x service map
      ath10k: introduce new subtypes for proxy STA and Mesh
      ath10k: apply Mesh subtype when Mesh interface created.

Tamizh chelvam (3):
      ath10k: add abstraction layer for peer flags
      ath10k: set peer MFP flag in peer assoc command
      ath10k: add thermal throttling support for 10.4 firmware

Vasanthakumar Thiagarajan (6):
      ath10k: add new service defines for 10.4
      ath10k: add new WMI cmd/event defines for 10.4
      ath10k: add new pdev params defines to 10.4
      ath10k: fix peer assoc complete WMI command for 10.4
      ath10k: rename the helper which is used for off-channel tx
      ath10k: fix peerid configuration in htt tx desc for htt version < 3.4

Vivek Natarajan (1):
      ath10k: add support for pktlog in QCA99X0

Vladimir Kondratiev (1):
      wil6210: hold wil->mutex while managing vrings

Yanbo Li (3):
      ath10k: debugfs file to enable Bluetooth coexistence feature
      ath10k: fix the wrong RX rate idx report at 11G mode
      ath10k: adjust the RX packet pad offset at QCA99X0 4addr mode

sudip (1):
      libertas: check for NULL before use

 drivers/net/wireless/ath/ath10k/Kconfig            |    1 +
 drivers/net/wireless/ath/ath10k/core.c             |   16 +-
 drivers/net/wireless/ath/ath10k/core.h             |   38 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  197 ++++-
 drivers/net/wireless/ath/ath10k/debug.h            |    4 +
 drivers/net/wireless/ath/ath10k/htt.h              |   15 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   33 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |  130 ++--
 drivers/net/wireless/ath/ath10k/hw.h               |   15 +
 drivers/net/wireless/ath/ath10k/mac.c              |  204 ++---
 drivers/net/wireless/ath/ath10k/mac.h              |    3 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   11 +
 drivers/net/wireless/ath/ath10k/thermal.c          |    2 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |   15 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   19 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |   18 +
 drivers/net/wireless/ath/ath10k/wmi.c              |  147 +++-
 drivers/net/wireless/ath/ath10k/wmi.h              |  130 +++-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    2 +-
 drivers/net/wireless/ath/wcn36xx/hal.h             |    2 +
 drivers/net/wireless/ath/wcn36xx/smd.c             |   27 +-
 drivers/net/wireless/ath/wcn36xx/smd.h             |    9 +
 drivers/net/wireless/ath/wil6210/main.c            |   18 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |    5 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |   10 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |    2 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  211 ++++--
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |   10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/chip.c    |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |   24 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  114 ++-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    8 +-
 .../wireless/broadcom/brcm80211/brcmfmac/debug.c   |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/debug.h   |    2 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.h |    5 +-
 .../broadcom/brcm80211/brcmfmac/firmware.c         |   47 +-
 .../broadcom/brcm80211/brcmfmac/firmware.h         |   46 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |    8 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.h    |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fwil.c    |   31 +-
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |   26 +-
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |    4 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   39 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.h |    2 -
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |  243 ++----
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  198 ++---
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.h    |    4 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |   89 +--
 .../broadcom/brcm80211/include/brcm_hw_ids.h       |    2 +
 drivers/net/wireless/cisco/airo.c                  |   18 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig         |    2 +-
 drivers/net/wireless/intel/iwlwifi/Makefile        |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/calib.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/calib.h     |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/commands.h  |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/devices.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/led.c       |    4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |    8 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |   16 +-
 drivers/net/wireless/intel/iwlwifi/dvm/power.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/power.h     |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/ucode.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-1000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-2000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-5000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-6000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   15 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |  163 ++++
 drivers/net/wireless/intel/iwlwifi/iwl-agn-hw.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-debug.h     |    2 -
 .../net/wireless/intel/iwlwifi/iwl-devtrace-data.h |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-devtrace-io.h   |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-devtrace-msg.h  |    2 +-
 .../wireless/intel/iwlwifi/iwl-devtrace-ucode.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   19 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.c  |    4 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.h  |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-read.c   |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-read.h   |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |    7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   15 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |   16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |   25 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.h        |    6 +-
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |   13 +-
 .../net/wireless/intel/iwlwifi/iwl-notif-wait.c    |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-notif-wait.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |   30 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-scd.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |   29 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/binding.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |   41 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  228 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |   60 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.h   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-power.h  |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |  116 ++-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-stats.h  |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-tof.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   22 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  780 ++++++++++++++++++++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.h    |  150 ++++
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  132 +---
 drivers/net/wireless/intel/iwlwifi/mvm/led.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  522 +++----------
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   90 +--
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |   53 +-
 .../net/wireless/intel/iwlwifi/mvm/offloading.c    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   31 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   44 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   16 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sf.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   88 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/testmode.h  |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.c    |    3 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   40 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   20 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   25 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  188 +----
 drivers/net/wireless/marvell/libertas/cfg.c        |    3 +-
 drivers/net/wireless/marvell/libertas/if_sdio.c    |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |    5 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    |   23 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |   21 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    |   22 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |   23 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    |   21 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |    3 +-
 .../realtek/rtlwifi/rtl8723com/fw_common.c         |    4 +-
 149 files changed, 3368 insertions(+), 2120 deletions(-)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/iwl-9000.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.h

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
