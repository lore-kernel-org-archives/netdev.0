From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] 100GbE Intel Wired LAN Driver Updates 2015-12-05
Date: Sun,  6 Dec 2015 00:01:19 -0800
Message-ID: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbbLFIBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jacob provides the remaining fm10k patches in the series.  First change
ensures that all the logic regarding the setting of netdev features is
consolidated in one place of the driver.  Fixed an issue where an assumption
was being made on how many queues are available, especially when init_hw_vf()
errors out.  Fixed up an number of issues with init_hw() where failures
were not being handled properly or at all, so update the driver to check
returned error codes and respond appropriately.  Fixed up typecasting
issues found where either the incorrect typecast size was used or
explicitly typecast values.  Added additional debugging statistics and
rename statistic to better reflect its true value.  Added support for
ITR scaling based on PCIe link speed for fm10k.  Fixed up code comment
where "hardware" was misspelled.

v2: Dropped patches #1 and #10 from original submission, patch #1 was from
    Nick Krause and due to his past kernel interactions, dropping his patch.
    Patch #10 had questions and concerns from Tom Herbert which cannot be
    addressed at this time since the author (Jacob Keller) is currently on
    sabbatical, so dropping this patch for now until we can properly address
    Tom's questions and concerns.

The following are changes since commit b82583ec6f1a5ca765a2a331317c3b5791036b25:
  Merge branch 'renesas-read-mac'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (15):
  fm10k: set netdev features in one location
  fm10k: reset max_queues on init_hw_vf failure
  fm10k: always check init_hw for errors
  fm10k: reinitialize queuing scheme after calling init_hw
  fm10k: Correct typecast in fm10k_update_xc_addr_pf
  fm10k: explicitly typecast vlan values to u16
  fm10k: add statistics for actual DWORD count of mbmem mailbox
  fm10k: rename mbx_tx_oversized statistic to mbx_tx_dropped
  fm10k: Add support for ITR scaling based on PCIe link speed
  fm10k: introduce ITR_IS_ADAPTIVE macro
  fm10k: Update adaptive ITR algorithm
  fm10k: use macro for default Tx and Rx ITR values
  fm10k: change default Tx ITR to 25usec
  fm10k: TRIVIAL fix typo of hardware
  fm10k: TRIVIAL cleanup order at top of fm10k_xmit_frame

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  8 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 14 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 60 ++++++++++++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     |  4 ++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h     |  4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 31 ++++++----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 75 ++++++++++++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 34 ++++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    | 17 +++++-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      | 33 +++++++++--
 10 files changed, 211 insertions(+), 69 deletions(-)

-- 
2.5.0
