From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 100GbE Intel Wired LAN Driver Updates 2017-10-02
Date: Mon,  2 Oct 2017 08:42:23 -0700
Message-ID: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751085AbdJBPm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jake provides all but one of the changes in this series.  Most are small
fixes, starting with ensuring prompt transmission of messages queued up
after each VF message is received and handled.  Fix a possible race
condition between the watchdog task and the processing of mailbox
messages by just checking whether the mailbox is still open.  Fix a
couple of GCC v7 warnings, including misspelled "fall through" comments
and warnings about possible truncation of calls to snprintf().  Cleaned
up a convoluted bitshift and read for the PFVFLRE register.  Fixed a
potential divide by zero when finding the proper r_idx.

Markus Elfring fixes an issue which was found using Coccinelle, where
we should have been using seq_putc() instead of seq_puts().

The following are changes since commit 0929567a7a2dab8455a7313956973ff0d339709a:
  samples/bpf: fix warnings in xdp_monitor_user
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (12):
  fm10k: ensure we process SM mbx when processing VF mbx
  fm10k: reschedule service event if we stall the PF<->SM mailbox
  fm10k: stop spurious link down messages when Tx FIFO is full
  fm10k: fix typos on fall through comments
  fm10k: avoid possible truncation of q_vector->name
  fm10k: add missing fall through comment
  fm10k: avoid needless delay when loading driver
  fm10k: simplify reading PFVFLRE register
  fm10k: don't loop while resetting VFs due to VFLR event
  fm10k: avoid divide by zero in rare cases when device is resetting
  fm10k: move fm10k_prepare_for_reset and fm10k_handle_reset
  fm10k: prevent race condition of __FM10K_SERVICE_SCHED

Markus Elfring (1):
  fm10k: Use seq_putc() in fm10k_dbg_desc_break()

 drivers/net/ethernet/intel/fm10k/fm10k_common.c  |   6 +-
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |  35 ++++----
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |   1 +
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |   8 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 110 +++++++++++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      |  10 +--
 8 files changed, 101 insertions(+), 77 deletions(-)

-- 
2.14.2
