From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates 2016-07-14
Date: Fri, 15 Jul 2016 00:02:00 -0700
Message-ID: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56902 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbcGOHCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 03:02:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to i40e and ixgbe.

Alex fixes issues found in i40e_rx_checksum() which was broken, where the
checksum was being returned valid when it was not.

Kiran fixes a bug which was found when we abruptly remove a cable which
caused a panic.  Set the VSI broadcast promiscuous mode during VSI add
sequence and prevents adding MAC filter if specified MAC address is
broadcast.

Paolo Abeni fixes a bug by returning the actual work done, capped to
weight - 1, since the core doesn't allow to return the full budget when
the driver modifies the NAPI status.

Guilherme Piccoli fixes an issue where the q_vector initialization
routine sets the affinity _mask of a q_vector based on v_idx value.
This means a loop iterates on v_idx, which is an incremental value, and
the cpumask is created based on this value.  This is a problem in
systems with multiple logical CPUs per core (like in SMT scenarios).
Changed the way q_vector's affinity_mask is created to resolve the issue.

The following are changes since commit 005db31d5f5f7c31cfdc43505d77eb3ca5cf8ec6:
  bonding: set carrier off for devices created through netlink
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Alexander Duyck (1):
  i40e/i40evf: Fix i40e_rx_checksum

Guilherme G. Piccoli (1):
  i40e: use valid online CPU on q_vector initialization

Kiran Patil (1):
  i40e: enable VSI broadcast promiscuous mode instead of adding
    broadcast filter

Paolo Abeni (1):
  ixgbe: napi_poll must return the work done

 drivers/net/ethernet/intel/i40e/i40e_main.c   | 48 +++++++++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 30 +++++++++--------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 30 +++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  2 +-
 4 files changed, 66 insertions(+), 44 deletions(-)

-- 
2.5.5
