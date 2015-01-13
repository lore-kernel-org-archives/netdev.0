From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-01-13
Date: Tue, 13 Jan 2015 03:33:16 -0800
Message-ID: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41319 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbbAMLdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Mitch provides a fix for i40e to move the call to pci_disable_sriov() so
that it is called earlier to ensure that the PF driver won't free VF
resources before the VF remove routine can complete.  Also cleans up
redundant and duplicate code in the i40evf.  Refactors the i40evf
shutdown code and let the watchdog take care of shutting things down.
Fix a possible memory leak, if we are using VLANs and the communication
with the PF fail during shutdown.  On some versions of the firmware, the
VF admin send queue may become stalled.  In this case, the easiest
solution is to place another descriptor on the queue and the firmware
will then process both requests.

Greg adds a warning when the NPAR enabled partitions detected a link speed
less than 10 Gpbs.

Vasu removes redundant VN2VN MAC address which were already added by
the FCoE stack.

Shannon adds code to find how many partitions there are per port and
what is the current partition_id when in NPAR mode.  In multifunction
mode, make sure we only allow SR/IOV on the master PF of a port and
only allow partition 1 to set WoL, speed and flow control.

Kamil adds code to read the PBA block from shadow RAM and returns
the part number in a string format.

Catherine provides a fix to check if link state and link speed has
changed before exiting link event

The following are changes since commit d2c60b1350c9a3eb7ed407c18f50306762365646:
  Merge branch 'tuntap_queues'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Catherine Sullivan (1):
  i40e: Don't exit link event early if link speed has changed

Greg Rose (1):
  i40e: Add warning for NPAR partitions with link speed less than 10Gbps

Kamil Krawczyk (1):
  i40e: Adding function for reading PBA String

Mitch A Williams (8):
  i40e: disable IOV before freeing resources
  i40evf: remove redundant code
  i40evf: Remove some scary log messages
  i40evf: refactor shutdown code
  i40evf: remove leftover VLAN filters
  i40evf: don't fire traffic IRQs when the interface is down
  i40evf: enable interrupt 0 appropriately
  i40evf: kick a stalled admin queue

Shannon Nelson (3):
  i40e/i40evf: find partition_id in npar mode
  i40e: limit WoL and link settings to partition 1
  i40e: limit sriov to partition 1 of NPAR configurations

Vasu Dev (1):
  i40e: remove VN2VN related mac filters

 drivers/net/ethernet/intel/i40e/i40e_common.c      | 125 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  43 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  15 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   5 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  11 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   7 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  94 ++++++++--------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   6 +-
 10 files changed, 256 insertions(+), 61 deletions(-)

-- 
1.9.3
