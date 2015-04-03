From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-04-03
Date: Fri,  3 Apr 2015 05:04:43 -0700
Message-ID: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10571 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbbDCMFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Anjali provides a fix for verifying outer UDP receive checksum.  Also
adds helpful information to display when figuring out the cause of
HMC errors.

Mitch provides a fix to prevent a malicious or buggy VF driver from
sending an invalid index into the VSI array which could panic the host.
Cleans up the code where a function was moved, but the message did
not follow.  Adds protection to the VLAN filter list, same as the
MAC filter list, to protect from corruption if the watchdog happens
to run at the same time as a VLAN filter is being added/deleted.

Jesse changes several memcpy() statements to struct assignments which
are type safe and preferable.  Fixed a bug when skb allocation fails,
where we should not continue using the skb pointer.  Also fixed a void
function in FCoE which should not be returning anything.

Greg fixes both i40e and i40evf to set the Ethernet protocol correctly
when transmit VLAN offloads are disabled.

Shannon fixes up VLAN messages when ports are added or removed, which
were giving bogus index info.  Also aligned the message text style
with other messages in the driver.

The following are changes since commit 11a9c7821c583aa22b35f37fba20539def9e8f14:
  Merge branch 'mlx5-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (4):
  i40evf: Fix Outer UDP RX checksum code
  i40e: Print some more info to help figure out the cause of HMC error
  i40e: Communicate VSI id in place of VSI index to the VFs
  i40evf: Refactor VF RSS code

Catherine Sullivan (1):
  i40e: Bump to version 1.3.1

Greg Rose (1):
  i40e/i40evf: Set Ethernet protocol correctly when Tx VLAN offloads are
    disabled

Jesse Brandeburg (3):
  i40e: Change some memcpys to struct assignments
  i40e/i40evf: fix bug when skb allocation fails
  i40e: fix invalid void return in FCoE code

Mitch Williams (4):
  i40e: validate VSI param from VFs
  i40e: warn at the right time
  i40e: stop flow director on shutdown
  i40evf: protect VLAN filter list

Neerav Parikh (1):
  i40e: Don't register/de-register apps on NIC partitions in MFP mode

Shannon Nelson (1):
  i40e: fix up VXLAN messages

 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   8 ++
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  82 +++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  18 +++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 113 +++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  43 +++++---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  67 ++++++------
 9 files changed, 202 insertions(+), 135 deletions(-)

-- 
1.9.3
