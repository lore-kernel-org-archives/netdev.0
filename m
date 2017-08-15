From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-08-15
Date: Tue, 15 Aug 2017 14:30:34 +0300
Message-ID: <87d17x9ig5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

more fixes to net tree for 4.13. More info in the signed tag below,
please let me know if there are any problems.

Kalle

The following changes since commit 5f5d03143de5e0c593da4ab18fc6393c2815e108:

  brcmfmac: fix memleak due to calling brcmf_sdiod_sgtable_alloc() twice (2017-07-27 14:03:14 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-08-15

for you to fetch changes up to e9bf53ab1ee34bb05c104bbfd2b77c844773f8e6:

  brcmfmac: feature check for multi-scheduled scan fails on bcm4343x devices (2017-08-14 11:09:30 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.13

This time quite a few fixes for iwlwifi and one major regression fix
for brcmfmac. For the iwlwifi aggregation bug a small change was
needed for mac80211, but as Johannes is still away the mac80211 patch
is taken via wireless-drivers tree.

brcmfmac

* fix firmware crash (a recent regression in bcm4343{0,1,8}

iwlwifi

* Some simple PCI HW ID fix-ups and additions for family 9000

* Remove a bogus warning message with new FWs (bug #196915)

* Don't allow illegal channel options to be used (bug #195299)

* A fix for checksum offload in family 9000

* A fix serious throughput degradation in 11ac with multiple streams

* An old bug in SMPS where the firmware was not aware of SMPS changes

* Fix a memory leak in the SAR code

* Fix a stuck queue case in AP mode;

* Convert a WARN to a simple debug in a legitimate race case (from
  which we can recover)

* Fix a severe throughput aggregation on 9000-family devices due to
  aggregation issues, needed a small change in mac80211

----------------------------------------------------------------
Arend Van Spriel (1):
      brcmfmac: feature check for multi-scheduled scan fails on bcm4343x devices

Avraham Stern (1):
      iwlwifi: mvm: start mac queues when deferred tx frames are purged

Christophe Jaillet (1):
      iwlwifi: mvm: Fix a memory leak in an error handling path in 'iwl_mvm_sar_get_wgds_table()'

Emmanuel Grumbach (4):
      iwlwifi: mvm: fix TCP CSUM offload with WEP and A000 series
      iwlwifi: add TLV for MLME offload firmware capability
      iwlwifi: split the regulatory rules when the bandwidth flags require it
      iwlwifi: mvm: don't WARN when a legit race happens in A-MPDU

Gregory Greenman (2):
      iwlwifi: mvm: set A-MPDU bit upon empty BA notification from FW
      iwlwifi: mvm: rs: fix TLC statistics collection

Haim Dreyfuss (1):
      iwlwifi: fix fw_pre_next_step to apply also for C step

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2017-08-02' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'iwlwifi-for-kalle-2018-08-09' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Naftali Goldstein (3):
      iwlwifi: mvm: set the RTS_MIMO_PROT bit in flag mask when sending sta to fw
      mac80211: add api to start ba session timer expired flow
      iwlwifi: mvm: send delba upon rx ba session timeout

Tzipi Peres (1):
      iwlwifi: add the new 9000 series PCI IDs

 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |  6 ++++--
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c      | 14 +++++++-------
 drivers/net/wireless/intel/iwlwifi/fw/file.h       |  2 ++
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |  8 ++++----
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |  5 +++--
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c | 19 +++++++++++--------
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  6 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  | 12 +++++++++++-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |  8 ++++----
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      | 10 ++++++----
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  7 ++++---
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        | 12 ++++++++++--
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      | 20 ++++++++++++++++++++
 include/net/mac80211.h                             | 15 +++++++++++++++
 net/mac80211/agg-rx.c                              | 22 +++++++++++++++++++++-
 15 files changed, 126 insertions(+), 40 deletions(-)
