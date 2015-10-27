From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-10-27
Date: Tue, 27 Oct 2015 10:46:38 +0200
Message-ID: <87y4eowvf5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a bigger pull request for 4.4. The diffstat looks scary as we
created a new directory realtek for all realtek drivers. In the future
I'm planning to create similar directories for all vendors, currently we
just have ath, mediatek and realtek. This change has been in linux-next
for a couple of weeks so it should be safe, but of course you never
know.

There's also a new driver rtl8xxxu for few realtek USB devices. This
just made it to the last linux-next build.

Otherwise there's nothing really special, more info below. If time
permits, and it's ok for you, I'm hoping to send you a one more pull
request this week.

Kalle

The following changes since commit 6623c60dc28ee966cd85c6f12aa2fc3c952d0179:

  bridge: vlan: enforce no pvid flag in vlan ranges (2015-10-12 19:59:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-10-27

for you to fetch changes up to c0963772cbbf1b7dc9fad4497f3aba8526bb07d6:

  rtl8xxxu: fix unused rtl8192cu_fops compiler warning (2015-10-26 18:06:10 +0200)

----------------------------------------------------------------
brcmfmac

* using netdev carrier state
* add and rework some cfg80211 callbacks mainly for AP mode
* use devcoredump when triggered by firmware event

realtek

* create new directory drivers/net/wireless/realtek/ for all realtek
  drivers, not visible to users (no kconfig changes etc)
* add rtl8xxxu, a new mac80211 driver for RTL8723AU, RTL8188CU,
  RTL8188RU, RTL8191CU, RTL8192CU and hopefully more in the future

ath10k

* add board 2 API support for automatically choosing correct board file
* data path optimisations
* disable PCI power save for qca988x and QCA99x0 due to interop reasons

wil6210

* BlockAckReq support
* firmware crashdump using devcoredump
* capture all frames with sniffer

----------------------------------------------------------------
Amitkumar Karwar (4):
      mwifiex: remove USB8897 chipset support
      mwifiex: correction in USB8997 chipset's product ID
      mwifiex: control WLAN and bluetooth coexistence modes
      mwifiex: add ndo_validate_addr netdev ops

Anilkumar Kolli (1):
      ath10k: disable PCI PS for QCA988X and QCA99X0

Arend van Spriel (2):
      brcmfmac: expose device memory to devcoredump subsystem
      brcmfmac: remove conversational comment

Colin Ian King (1):
      ath6kl: remove redundant null pointer check on send_pkt

Eric Caruso (1):
      brcm80211: Add support for brcm4371

Franky Lin (1):
      brcmfmac: rename firmware_path to alternative_fw_path

Ganapathi Bhat (1):
      mwifiex: fix AP VHT behaviour

Geliang Tang (2):
      ath6kl: drop unlikely behind WARN_ON()
      mwifiex: fix a comment typo

Hamad Kadmany (1):
      wil6210: Do no schedule firmware recovery during reset flow

Hante Meuleman (8):
      brcmfmac: Fix race condition between USB probe/load and disconnect.
      brcmfmac: Rework p2p attach, use single method for p2p dev creation.
      brcmfmac: Fix station info rate information.
      brcmfmac: Add RSSI information to get_station.
      brcmfmac: Add dump_station support to cfg80221 ops.
      brcmfmac: Move brcmf_c_preinit_dcmds prototype to correct file.
      brcmfmac: Remove unused state AP creating.
      brcmfmac: Properly set carrier state of netdev.

Jeff Johnson (1):
      ath10k: cleanup ath10k_mac_register() error handling

Jes Sorensen (1):
      New driver: rtl8xxxu (mac80211)

Kalle Valo (10):
      ath10k: fix checkpatch warning about logical continuations
      ath10k: indentation fixes
      ath10k: brace style fixes
      ath10k: remove void function return statements
      ath10k: fix whitespace usage
      ath10k: split an unnecessary long line
      ath10k: add a_sle32_to_cpu()
      Merge ath-next from ath.git
      rtl8xxxu: move devices supported by rtlwifi under UNTESTED config
      rtl8xxxu: fix unused rtl8192cu_fops compiler warning

Larry Finger (1):
      rtlwifi: rtl818x: Move drivers into new realtek directory

Maharaja Kennadyrajan (2):
      ath10k: implement debugfs interface for Transmit Power Control stats
      ath10k: increase pci wakeup timeout to 30 ms

Manikanta Pubbisetty (3):
      ath10k: add board 2 API support
      ath10k: select board data based on BMI chip id and board id
      ath10k: make fw stats prints specific to firmware version

Martin Blumenstingl (1):
      ath9k: Fix NF CCA limits for AR9287 and AR9227

Miaoqing Pan (2):
      ath9k: rename ini_modes_rxgain_5g_xlna to ini_modes_rxgain_xlna
      ath9k: fix QCA9561 XLNA rxgain initial

Mohammed Shafi Shajakhan (1):
      ath10k: fix cleanup in ath10k_thermal_unregister

Peter Oh (2):
      ath10k: use Rx decap mode configured when driver registered
      ath10k: use pre-allocated DMA buffer in Tx

Priit Laes (1):
      rtlwifi: rtl8192cu: Add missing case in rtl92cu_get_hw_reg

Rajkumar Manoharan (8):
      ath10k: optimize ce_lock on post rx buffer processing
      ath10k: export htc tx rx handlers
      ath10k: register per copy engine send completion callbacks
      ath10k: register per copy engine receive callbacks
      ath10k: export htt tx rx handlers
      ath10k: configure copy engine 5 for HTT messages
      ath10k: remove unused dl_is_polled
      ath10k: remove htc polling for tx completion

Vivek Natarajan (1):
      ath10k: use station's current operating mode from assoc request

Vladimir Kondratiev (8):
      wil6210: fix warning in system power management code
      wil6210: Add proper handling for invalid frames on Rx
      wil6210: log firmware crash information
      wil6210: treat broadcast bssid as "disconnect all"
      wil6210: support BAR (BlockAck Req)
      wil6210: capture all frames in sniffer mode
      wil6210: ratelimit Tx error message
      wil6210: dump firmware memory when firmware crashes

Vladimir Shulman (1):
      wil6210: pmc logger bug fix

Xinming Hu (1):
      mwifiex: remove unnecessary NULL check

Zefir Kurtisi (1):
      ath: fix DFS timestamp wraparound reset condition

 MAINTAINERS                                        |    7 +
 drivers/net/wireless/Kconfig                       |    7 +-
 drivers/net/wireless/Makefile                      |    4 +-
 drivers/net/wireless/ath/ath10k/bmi.h              |   10 +
 drivers/net/wireless/ath/ath10k/ce.c               |   10 +-
 drivers/net/wireless/ath/ath10k/ce.h               |    7 +-
 drivers/net/wireless/ath/ath10k/core.c             |  343 +-
 drivers/net/wireless/ath/ath10k/core.h             |   42 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  516 +-
 drivers/net/wireless/ath/ath10k/debug.h            |   11 +
 drivers/net/wireless/ath/ath10k/hif.h              |   26 +-
 drivers/net/wireless/ath/ath10k/htc.c              |   51 +-
 drivers/net/wireless/ath/ath10k/htc.h              |    4 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    7 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    1 +
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   57 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   13 +
 drivers/net/wireless/ath/ath10k/mac.c              |   31 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  254 +-
 drivers/net/wireless/ath/ath10k/pci.h              |   11 +-
 drivers/net/wireless/ath/ath10k/thermal.c          |    2 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    5 -
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   32 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |    1 +
 drivers/net/wireless/ath/ath10k/wmi.c              |  655 ++-
 drivers/net/wireless/ath/ath10k/wmi.h              |   46 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |    4 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    9 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c    |    2 +-
 drivers/net/wireless/ath/wil6210/Kconfig           |    1 +
 drivers/net/wireless/ath/wil6210/Makefile          |    1 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |    6 +
 drivers/net/wireless/ath/wil6210/interrupt.c       |   10 +-
 drivers/net/wireless/ath/wil6210/main.c            |   14 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    2 +-
 drivers/net/wireless/ath/wil6210/pmc.c             |    2 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   26 +
 drivers/net/wireless/ath/wil6210/txrx.c            |   62 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    7 +
 drivers/net/wireless/ath/wil6210/wil6210.h         |   10 +
 drivers/net/wireless/ath/wil6210/wil_crash_dump.c  |  115 +
 drivers/net/wireless/ath/wil6210/wmi.c             |    2 +-
 drivers/net/wireless/brcm80211/Kconfig             |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/bus.h      |   21 +
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |   86 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.h |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/common.h   |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/core.c     |   65 +-
 drivers/net/wireless/brcm80211/brcmfmac/core.h     |   11 +-
 drivers/net/wireless/brcm80211/brcmfmac/debug.c    |   42 +-
 drivers/net/wireless/brcm80211/brcmfmac/debug.h    |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.h     |    1 +
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   13 +
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |    3 -
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |   71 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   74 +
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |   49 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   29 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    2 +
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    2 +-
 drivers/net/wireless/mwifiex/debugfs.c             |   52 +
 drivers/net/wireless/mwifiex/fw.h                  |   16 +
 drivers/net/wireless/mwifiex/main.c                |    1 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   31 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   25 +
 drivers/net/wireless/mwifiex/uap_cmd.c             |   16 -
 drivers/net/wireless/mwifiex/usb.c                 |   14 -
 drivers/net/wireless/mwifiex/usb.h                 |    5 +-
 drivers/net/wireless/mwifiex/wmm.c                 |    2 +-
 drivers/net/wireless/realtek/Makefile              |    9 +
 drivers/net/wireless/{ => realtek}/rtl818x/Kconfig |    0
 .../net/wireless/{ => realtek}/rtl818x/Makefile    |    0
 .../{ => realtek}/rtl818x/rtl8180/Makefile         |    2 +-
 .../wireless/{ => realtek}/rtl818x/rtl8180/dev.c   |    0
 .../{ => realtek}/rtl818x/rtl8180/grf5101.c        |    0
 .../{ => realtek}/rtl818x/rtl8180/grf5101.h        |    0
 .../{ => realtek}/rtl818x/rtl8180/max2820.c        |    0
 .../{ => realtek}/rtl818x/rtl8180/max2820.h        |    0
 .../{ => realtek}/rtl818x/rtl8180/rtl8180.h        |    0
 .../{ => realtek}/rtl818x/rtl8180/rtl8225.c        |    0
 .../{ => realtek}/rtl818x/rtl8180/rtl8225.h        |    0
 .../{ => realtek}/rtl818x/rtl8180/rtl8225se.c      |    0
 .../{ => realtek}/rtl818x/rtl8180/rtl8225se.h      |    0
 .../{ => realtek}/rtl818x/rtl8180/sa2400.c         |    0
 .../{ => realtek}/rtl818x/rtl8180/sa2400.h         |    0
 .../{ => realtek}/rtl818x/rtl8187/Makefile         |    2 +-
 .../wireless/{ => realtek}/rtl818x/rtl8187/dev.c   |    0
 .../wireless/{ => realtek}/rtl818x/rtl8187/leds.c  |    0
 .../wireless/{ => realtek}/rtl818x/rtl8187/leds.h  |    0
 .../{ => realtek}/rtl818x/rtl8187/rfkill.c         |    0
 .../{ => realtek}/rtl818x/rtl8187/rfkill.h         |    0
 .../{ => realtek}/rtl818x/rtl8187/rtl8187.h        |    0
 .../{ => realtek}/rtl818x/rtl8187/rtl8225.c        |    0
 .../{ => realtek}/rtl818x/rtl8187/rtl8225.h        |    0
 .../net/wireless/{ => realtek}/rtl818x/rtl818x.h   |    0
 drivers/net/wireless/realtek/rtl8xxxu/Kconfig      |   34 +
 drivers/net/wireless/realtek/rtl8xxxu/Makefile     |    1 +
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   | 5993 ++++++++++++++++++++
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |  676 +++
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |  981 ++++
 drivers/net/wireless/{ => realtek}/rtlwifi/Kconfig |    0
 .../net/wireless/{ => realtek}/rtlwifi/Makefile    |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/base.c  |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/base.h  |    0
 .../{ => realtek}/rtlwifi/btcoexist/Makefile       |    0
 .../rtlwifi/btcoexist/halbt_precomp.h              |    0
 .../rtlwifi/btcoexist/halbtc8192e2ant.c            |    0
 .../rtlwifi/btcoexist/halbtc8192e2ant.h            |    0
 .../rtlwifi/btcoexist/halbtc8723b1ant.c            |    0
 .../rtlwifi/btcoexist/halbtc8723b1ant.h            |    0
 .../rtlwifi/btcoexist/halbtc8723b2ant.c            |    0
 .../rtlwifi/btcoexist/halbtc8723b2ant.h            |    0
 .../rtlwifi/btcoexist/halbtc8821a1ant.c            |    0
 .../rtlwifi/btcoexist/halbtc8821a1ant.h            |    0
 .../rtlwifi/btcoexist/halbtc8821a2ant.c            |    0
 .../rtlwifi/btcoexist/halbtc8821a2ant.h            |    0
 .../{ => realtek}/rtlwifi/btcoexist/halbtcoutsrc.c |    0
 .../{ => realtek}/rtlwifi/btcoexist/halbtcoutsrc.h |    0
 .../{ => realtek}/rtlwifi/btcoexist/rtl_btc.c      |    0
 .../{ => realtek}/rtlwifi/btcoexist/rtl_btc.h      |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/cam.c   |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/cam.h   |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/core.c  |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/core.h  |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/debug.c |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/debug.h |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/efuse.c |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/efuse.h |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/pci.c   |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/pci.h   |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/ps.c    |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/ps.h    |    0
 .../net/wireless/{ => realtek}/rtlwifi/pwrseqcmd.h |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/rc.c    |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/rc.h    |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/regd.c  |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/regd.h  |    0
 .../{ => realtek}/rtlwifi/rtl8188ee/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/fw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/phy.h |    0
 .../{ => realtek}/rtlwifi/rtl8188ee/pwrseq.c       |    0
 .../{ => realtek}/rtlwifi/rtl8188ee/pwrseq.h       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8188ee/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8188ee/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8188ee/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8192c/Makefile        |    0
 .../{ => realtek}/rtlwifi/rtl8192c/dm_common.c     |    0
 .../{ => realtek}/rtlwifi/rtl8192c/dm_common.h     |    0
 .../{ => realtek}/rtlwifi/rtl8192c/fw_common.c     |    0
 .../{ => realtek}/rtlwifi/rtl8192c/fw_common.h     |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192c/main.c |    0
 .../{ => realtek}/rtlwifi/rtl8192c/phy_common.c    |    0
 .../{ => realtek}/rtlwifi/rtl8192c/phy_common.h    |    0
 .../{ => realtek}/rtlwifi/rtl8192ce/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/phy.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8192ce/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8192ce/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ce/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8192cu/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/hw.c  |    8 +
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/mac.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/mac.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/phy.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8192cu/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8192cu/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192cu/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8192de/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/fw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/phy.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8192de/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8192de/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192de/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8192ee/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/fw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/phy.h |    0
 .../{ => realtek}/rtlwifi/rtl8192ee/pwrseq.c       |    0
 .../{ => realtek}/rtlwifi/rtl8192ee/pwrseq.h       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8192ee/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8192ee/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192ee/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8192se/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/fw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/phy.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8192se/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8192se/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8192se/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/btc.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/fw.h  |    0
 .../rtlwifi/rtl8723ae/hal_bt_coexist.c             |    0
 .../rtlwifi/rtl8723ae/hal_bt_coexist.h             |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/hal_btc.c      |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/hal_btc.h      |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/phy.h |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/pwrseq.c       |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/pwrseq.h       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8723ae/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723ae/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8723be/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/fw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/phy.h |    0
 .../{ => realtek}/rtlwifi/rtl8723be/pwrseq.c       |    0
 .../{ => realtek}/rtlwifi/rtl8723be/pwrseq.h       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8723be/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8723be/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8723be/trx.h |    0
 .../{ => realtek}/rtlwifi/rtl8723com/Makefile      |    0
 .../{ => realtek}/rtlwifi/rtl8723com/dm_common.c   |    0
 .../{ => realtek}/rtlwifi/rtl8723com/dm_common.h   |    0
 .../{ => realtek}/rtlwifi/rtl8723com/fw_common.c   |    0
 .../{ => realtek}/rtlwifi/rtl8723com/fw_common.h   |    0
 .../{ => realtek}/rtlwifi/rtl8723com/main.c        |    0
 .../{ => realtek}/rtlwifi/rtl8723com/phy_common.c  |    0
 .../{ => realtek}/rtlwifi/rtl8723com/phy_common.h  |    0
 .../{ => realtek}/rtlwifi/rtl8821ae/Makefile       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/def.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/dm.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/dm.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/fw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/fw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/hw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/hw.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/led.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/led.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/phy.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/phy.h |    0
 .../{ => realtek}/rtlwifi/rtl8821ae/pwrseq.c       |    0
 .../{ => realtek}/rtlwifi/rtl8821ae/pwrseq.h       |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/reg.h |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/rf.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/rf.h  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/sw.c  |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/sw.h  |    0
 .../{ => realtek}/rtlwifi/rtl8821ae/table.c        |    0
 .../{ => realtek}/rtlwifi/rtl8821ae/table.h        |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/trx.c |    0
 .../wireless/{ => realtek}/rtlwifi/rtl8821ae/trx.h |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/stats.c |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/stats.h |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/usb.c   |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/usb.h   |    0
 drivers/net/wireless/{ => realtek}/rtlwifi/wifi.h  |    0
 368 files changed, 10080 insertions(+), 728 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wil6210/wil_crash_dump.c
 create mode 100644 drivers/net/wireless/realtek/Makefile
 rename drivers/net/wireless/{ => realtek}/rtl818x/Kconfig (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/Makefile (69%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/dev.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/grf5101.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/grf5101.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/max2820.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/max2820.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/rtl8180.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/rtl8225.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/rtl8225.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/rtl8225se.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/rtl8225se.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/sa2400.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8180/sa2400.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/Makefile (62%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/dev.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/leds.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/leds.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/rfkill.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/rfkill.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/rtl8187.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/rtl8225.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl8187/rtl8225.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtl818x/rtl818x.h (100%)
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/Kconfig
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/Makefile
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h
 rename drivers/net/wireless/{ => realtek}/rtlwifi/Kconfig (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/base.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/base.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbt_precomp.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8192e2ant.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8192e2ant.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8723b1ant.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8723b1ant.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8723b2ant.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8723b2ant.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8821a1ant.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8821a1ant.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8821a2ant.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtc8821a2ant.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtcoutsrc.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/halbtcoutsrc.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/rtl_btc.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/btcoexist/rtl_btc.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/cam.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/cam.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/core.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/core.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/debug.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/debug.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/efuse.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/efuse.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/pci.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/pci.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/ps.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/ps.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/pwrseqcmd.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rc.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rc.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/regd.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/regd.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/pwrseq.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/pwrseq.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8188ee/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/dm_common.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/dm_common.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/fw_common.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/fw_common.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/main.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/phy_common.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192c/phy_common.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ce/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/hw.c (99%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/mac.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/mac.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192cu/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192de/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/pwrseq.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/pwrseq.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192ee/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8192se/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/btc.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/hal_bt_coexist.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/hal_bt_coexist.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/hal_btc.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/hal_btc.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/pwrseq.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/pwrseq.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723ae/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/pwrseq.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/pwrseq.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723be/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/dm_common.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/dm_common.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/fw_common.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/fw_common.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/main.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/phy_common.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8723com/phy_common.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/Makefile (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/def.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/dm.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/dm.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/fw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/fw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/hw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/hw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/led.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/led.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/phy.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/phy.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/pwrseq.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/pwrseq.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/reg.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/rf.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/rf.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/sw.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/sw.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/table.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/table.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/trx.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/rtl8821ae/trx.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/stats.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/stats.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/usb.c (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/usb.h (100%)
 rename drivers/net/wireless/{ => realtek}/rtlwifi/wifi.h (100%)

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
