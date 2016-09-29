From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2016-09-29
Date: Thu, 29 Sep 2016 19:57:28 +0300
Message-ID: <87ponmve2v.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

this should be the last wireless-drivers-next pull request for 4.9, from
now on only important bugfixes. Nothing really special stands out,
iwlwifi being most active but other drivers also getting attention. More
details in the signed tag. Please let me know if there are any problems.

Or actually I had one problem. While doing a test merge I noticed that
net-next fails to compile for me, but I don't think this is anything
wireless related:

  CC      net/netfilter/core.o
net/netfilter/core.c: In function 'nf_set_hooks_head':
net/netfilter/core.c:96:149: error: 'struct net_device' has no member named=
 'nf_hooks_ingress'

Kalle

The following changes since commit fd9527f404d51e50f40dac0d9a69f2eff3dac33e:

  Merge branch 'ip_tunnel-collect_md' (2016-09-17 10:13:16 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2016-09-29

for you to fetch changes up to 15b95a15950238eff4d7f24be1716086eea67835:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/a=
th.git (2016-09-28 16:37:33 +0300)

----------------------------------------------------------------

wireless-drivers-next patches for 4.9

Major changes:

iwlwifi

* work for new hardware support continues
* dynamic queue allocation stabilization
* improvements in the MSIx code
* multiqueue support work continues
* new firmware version support (API 26)
* add 8275 series support
* add 9560 series support
* add support for MU-MIMO sniffer
* add support for RRM by scan
* add support for "reverse" rx packet injection faking hw descriptors
* migrate to devm memory allocation handling
* Remove support for older firmwares (API older than -17 and -22)

wl12xx

* support booting the same rootfs with both wl12xx and wl18xx

hostap

* mark the driver as obsolete

ath9k

* disable RNG by default

----------------------------------------------------------------
Amitkumar Karwar (1):
      mwifiex: code rearrangement in mwifiex_usb_host_to_card()

Arend Van Spriel (4):
      brcmfmac: rework pointer trickery in brcmf_proto_bcdc_query_dcmd()
      brcmfmac: fix memory leak in brcmf_flowring_add_tdls_peer()
      brcmfmac: initialize variable in brcmf_sdiod_regrl()
      brcmfmac: remove worker from .ndo_set_mac_address() callback

Arik Nemtsov (1):
      iwlwifi: move BIOS MCC retrieval to common code

Aviya Erenfeld (1):
      iwlwifi: mvm: add support for MU-MIMO air sniffer

Avrahams Stern (1):
      iwlwifi: mvm: Add support for RRM by scan

Ben Greear (3):
      ath10k: fix typo in logging message
      ath10k: document cycle count related counters
      ath10k: support up to 64 vdevs

Bob Copeland (1):
      mwifiex: fix error handling in mwifiex_create_custom_regdomain

Cathy Luo (2):
      mwifiex: fix kernel crash for USB chipsets
      mwifiex: fix race condition causing tx timeout

Chaehyun Lim (1):
      ath6kl: fix return value in ath6kl_wmi_set_pvb_cmd

Colin Ian King (1):
      mwifiex: fix null pointer deference when adapter is null

Emmanuel Grumbach (4):
      iwlwifi: mvm: bump max API to 26
      iwlwifi: don't export trace points that are used in iwlwifi only
      iwlwifi: mvm: fix typo in TC_CMD_SEC_KEY_FROM_TABLE
      iwlwifi: mvm: initialise ADD_STA before sending it to the firmware

Ganapathi Bhat (1):
      mwifiex: cfg80211 set_default_mgmt_key handler

Haim Dreyfuss (4):
      iwlwifi: pcie: Configure shared interrupt vector in MSIX mode
      iwlwifi: pcie: Set affinity mask for rx interrupt vectors per cpu
      iwlwifi: pcie: replace possible_cpus() with online_cpus() in MSIX mode
      iwlwifi: check for valid ethernet address provided by OEM

Hante Meuleman (5):
      brcmfmac: ignore 11d configuration errors
      brcmfmac: remove unnecessary null pointer check
      brcmfmac: fix clearing entry IPv6 address
      brcmfmac: fix out of bound access on clearing wowl wake indicator
      brcmfmac: simplify mapping of auth type

Ido Yariv (1):
      iwlwifi: mvm: Add mem debugfs entry

Jes Sorensen (4):
      rtl8xxxu: Implement 8192e specific power down sequence
      rtl8xxxu: Fix off by one error calculating pubq
      rtl8xxxu: Clean up llt_init() API
      rtl8xxxu: Use a struct rtl8xxxu_fileops * in rtl8xxxu_init_device()

Joe Perches (2):
      ath10k: spelling and miscellaneous neatening
      rtlwifi: Add switch variable to 'switch case not processed' messages

Johannes Berg (11):
      iwlwifi: mvm: make RSS RX more robust
      iwlwifi: mvm: remove pointless _bh from spinlock in timer
      iwlwifi: mvm: tighten BAID range check
      iwlwifi: mvm: compare full command ID
      iwlwifi: mvm: make iwl_mvm_update_sta() an inline
      iwlwifi: mvm: document passing unexpected Block Ack Request frames
      iwlwifi: mvm: move AP-specific code to right function
      iwlwifi: mvm: use LIST_HEAD() macro
      iwlwifi: pcie: use LIST_HEAD() macro
      iwlwifi: pcie: avoid variable shadowing in TFD helpers
      iwlwifi: mvm: correct rate_idx bounds-check

Jouni Malinen (1):
      MAINTAINERS: hostap: Mark the Host AP driver obsolete

Kalle Valo (4):
      Merge tag 'iwlwifi-next-for-kalle-2016-09-15-2' of git://git.kernel.o=
rg/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2016-09-19-2' of git://git.kernel.o=
rg/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2015-09-26' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Larry Finger (3):
      rtl8xxxu: Stop log spam from each successful interrupt
      rtlwifi: Add HAL_DEF_WOWLAN case to *_get_hw() routines
      rtlwifi: Add explicit values to hw_variables enum

Liad Kaufman (4):
      iwlwifi: mvm: don't free queue after delba in dqa
      iwlwifi: mvm: fix pending frames tracking on tx resp
      iwlwifi: mvm: free reserved queue on STA removal
      iwlwifi: mvm: remove variable shadowing

Luca Coelho (2):
      iwlwifi: mvm: bail out if CTDP start operation fails
      iwlwifi: remove support for fw older than -17 and -22

Masahiro Yamada (3):
      ath10k: use devm_clk_get() instead of clk_get()
      ath10k: use devm_reset_control_get() instead of reset_control_get()
      ath10k: do not check if reset is NULL

Miaoqing Pan (1):
      ath9k: disable RNG by default

Mohammed Shafi Shajakhan (1):
      ath10k: Ignore SWBA event for a vif if its marked for no beacon

Oren Givon (4):
      iwlwifi: add the new 9560 series
      iwlwifi: add the new 8275 series
      iwlwifi: add new 8265 series PCI ID
      iwlwifi: add two new 9560 series PCI IDs

Rafa=C5=82 Mi=C5=82ecki (4):
      brcmfmac: fix memory leak in brcmf_fill_bss_param
      brcmfmac: drop unused fields from struct brcmf_pub
      brcmfmac: replace WARNING on timeout with a simple error message
      brcmfmac: use correct skb freeing helper when deleting flowring

Rajkumar Manoharan (1):
      ath10k: fix copy engine 5 destination ring stuck

Roee Zamir (1):
      iwlwifi: mvm: Add debugfs function for clocks diff

Sara Sharon (22):
      iwlwifi: mvm: call a different txq_enable function
      iwlwifi: pcie: introduce new tfd and tb formats
      iwlwifi: mvm: remove dump of locked registers
      iwlwifi: mvm: support new shared memory config API
      iwlwifi: introduce trans API to get byte count table
      iwlwifi: pcie: assign and access a000 TFD & TBs
      iwlwifi: change byte count table for a000 devices
      iwlwifi: pcie: merge iwl_queue and iwl_txq
      iwlwifi: mvm: support new BA notification response
      iwlwifi: pcie: change indentation of iwl_pcie_set_interrupt_capa()
      iwlwifi: pcie: fix typo in struct name for a000 devices
      iwlwifi: mvm: cleanup skb queue functions use
      iwlwifi: mvm: fix DQA AP mode station assumption
      iwlwifi: mvm: support BAR in reorder buffer
      iwlwifi: mvm: support packet injection
      iwlwifi: pcie: log full command sequence
      iwlwifi: move to wide ID for all commands
      iwlwifi: mvm: disable P2P queue on mac context release
      iwlwifi: mvm: set HCMD_NAME for PHY_DB as well
      iwlwifi: mvm: cleanup redundant no_power_up_nic_in_init config
      iwlwifi: mvm: cleanup usage of init_dbg parameter
      iwlwifi: allow error table address new range

Sharon Dvir (2):
      iwlwifi: unify iwl_get_ucode_image() implementations
      iwlwifi: migrate to devm_* API

Tony Lindgren (5):
      wlcore: Prepare family to fix nvs file handling
      wlcore: sdio: Populate config firmware data
      wlcore: spi: Populate config firmware data
      wlcore: Fix config firmware loading issues
      wlcore: wl18xx: Use chip specific configuration firmware

Vasanthakumar Thiagarajan (1):
      ath10k: fix rfc1042 header retrieval in QCA4019 with eth decap mode

Wei Yongjun (2):
      iwlwifi: mvm: use setup_timer instead of init_timer and data fields
      ath10k: fix error return code in ahb

kbuild test robot (1):
      iwlwifi: fix semicolon.cocci warnings

 MAINTAINERS                                        |    5 +-
 drivers/net/wireless/ath/ath10k/ahb.c              |  107 ++----
 drivers/net/wireless/ath/ath10k/ce.c               |    9 +-
 drivers/net/wireless/ath/ath10k/core.c             |   17 +-
 drivers/net/wireless/ath/ath10k/core.h             |    8 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    8 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    5 +-
 drivers/net/wireless/ath/ath10k/hw.c               |    2 +-
 drivers/net/wireless/ath/ath10k/hw.h               |    5 +-
 drivers/net/wireless/ath/ath10k/mac.c              |    2 +-
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    2 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |    6 +
 drivers/net/wireless/ath/ath10k/wmi.h              |   32 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    2 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |    2 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   46 +--
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |   55 ++-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    6 -
 .../broadcom/brcm80211/brcmfmac/flowring.c         |   17 +-
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |    2 -
 drivers/net/wireless/intel/iwlwifi/dvm/ucode.c     |   11 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   10 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   17 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   15 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    3 +-
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-devtrace.c  |    3 -
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |   57 ++-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   29 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |    9 +
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-notif-wait.c    |    8 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |  104 ++++-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h |   20 +-
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c    |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |   12 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |   20 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |   29 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |  184 +++++++++
 .../net/wireless/intel/iwlwifi/mvm/fw-api-power.h  |   21 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |   20 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   85 ++++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   74 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  152 ++++----
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   47 +--
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   42 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   18 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |   93 +----
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   80 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |   15 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   38 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   88 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   51 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |   10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  214 +++++++----
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   24 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |    8 +
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  128 ++++---
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   25 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  325 +++++++++-------
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |  397 ++++++++++++----=
----
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   24 ++
 drivers/net/wireless/marvell/mwifiex/fw.h          |    1 +
 drivers/net/wireless/marvell/mwifiex/ioctl.h       |    1 +
 drivers/net/wireless/marvell/mwifiex/main.c        |    8 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |    5 +
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   13 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |   37 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |    7 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |  144 ++++++-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |   49 +--
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |    1 +
 drivers/net/wireless/realtek/rtlwifi/core.c        |    3 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |    3 +-
 drivers/net/wireless/realtek/rtlwifi/ps.c          |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/fw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.c    |   11 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/phy.c   |   10 +-
 .../wireless/realtek/rtlwifi/rtl8192c/fw_common.c  |    4 +-
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.c |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |    9 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/phy.c   |    7 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/phy.c   |    7 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |   11 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   11 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |   11 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/phy.c   |    5 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/fw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |   11 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/phy.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |    9 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/led.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |   20 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |  208 +++++-----
 drivers/net/wireless/ti/wl18xx/main.c              |   19 +-
 drivers/net/wireless/ti/wlcore/boot.c              |   15 +-
 drivers/net/wireless/ti/wlcore/main.c              |   36 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   76 ++--
 drivers/net/wireless/ti/wlcore/spi.c               |   48 +--
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   12 +-
 122 files changed, 2383 insertions(+), 1437 deletions(-)
