From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-09-25
Date: Mon, 25 Sep 2017 11:55:22 +0300
Message-ID: <878th36ttx.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here a pull request to net for 4.14, more info in the signed tag below.
Please let me know if there are any problems.

Kalle

The following changes since commit 2bd6bf03f4c1c59381d62c61d03f6cc3fe71f66e:

  Linux 4.14-rc1 (2017-09-16 15:47:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-09-25

for you to fetch changes up to 3e747fa18202896b5be66b88478352d5880fb8eb:

  Merge ath-current from ath.git (2017-09-25 10:06:12 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.14

Quite a lot of fixes this time. Most notable is the brcmfmac fix for a
CVE issue.

iwlwifi

* a couple of bugzilla bugs related to multicast handling

* two fixes for WoWLAN bugs that were causing queue hangs and
  re-initialization problems

* two fixes for potential uninitialized variable use reported by Dan
  Carpenter in relation to a recently introduced patch

* a fix for buffer reordering in the newly supported 9000 device
  family

* fix a race when starting aggregation

* small fix for a recent patch to wake mac80211 queues

* send non-bufferable management frames in the generic queue so they
  are not sent on queues that are under power-save

ath10k

* fix a PCI PM related gcc warning

brcmfmac

* CVE-2017-0786: add length check scan results from firmware

* respect passive scan requests from user space

qtnfmac

* fix race in tx path when using multiple interfaces

* cancel ongoing scan when removing the wireless interface

----------------------------------------------------------------
Arend Van Spriel (2):
      brcmfmac: add length check in brcmf_cfg80211_escan_handler()
      brcmfmac: setup passive scan if requested by user-space

Arnd Bergmann (1):
      ath10k: mark PM functions as __maybe_unused

Avraham Stern (2):
      iwlwifi: mvm: send all non-bufferable frames on the probe queue
      iwlwifi: mvm: wake the correct mac80211 queue

David Spinadel (1):
      iwlwifi: mvm: Flush non STA TX queues

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2017-09-15' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Luca Coelho (4):
      iwlwifi: mvm: use IWL_HCMD_NOCOPY for MCAST_FILTER_CMD
      iwlwifi: mvm: handle FIF_ALLMULTI when setting multicast addresses
      iwlwifi: mvm: initialize status in iwl_mvm_add_int_sta_common()
      iwlwifi: mvm: set status before calling iwl_mvm_send_cmd_status()

Matt Chen (1):
      iwlwifi: mvm: fix wowlan resume failed to load INIT ucode

Naftali Goldstein (1):
      iwlwifi: mvm: change state when queueing agg start work

Sara Sharon (1):
      iwlwifi: mvm: fix reorder buffer for 9000 devices

Sergey Matyukevich (2):
      qtnfmac: lock access to h/w in tx path
      qtnfmac: cancel scans on wireless interface changes

 drivers/net/wireless/ath/ath10k/pci.c              |  7 +--
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 37 ++++++-------
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |  5 ++
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  | 62 ++++++++++++++++++++--
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |  3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  7 +--
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  8 +--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |  2 +
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |  1 +
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        | 10 ++--
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c  |  9 ++--
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.h  |  3 ++
 drivers/net/wireless/quantenna/qtnfmac/event.c     |  2 -
 .../net/wireless/quantenna/qtnfmac/pearl/pcie.c    |  9 +++-
 .../quantenna/qtnfmac/pearl/pcie_bus_priv.h        |  2 +
 17 files changed, 125 insertions(+), 46 deletions(-)
