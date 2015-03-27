From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates 2015-03-27
Date: Fri, 27 Mar 2015 03:02:46 -0700
Message-ID: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13066 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbbC0KDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:03:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Jesse adds new device IDs to handle the new 20G speed for KR2.

Mitch provides a fix for an issue that shows up as a panic or memory
corruption when the device is brought down while under heavy stress.
This is resolved by delaying the releasing of resources until we
receive acknowledgment from the PF driver that the rings have indeed
been stopped.  Also adds firmware version information to ethtool
reporting to align with ixgbevf behavior.

Akeem increases the polling loop limiter, sine we found that in
certain circumstances the firmware can take longer to be ready after
a reset.

The following are changes since commit 5a352dd0a3aac03b443c94828dfd7144261c8636:
  ipv6: hash net ptr into fragmentation bucket selection
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

master

Akeem G Abodunrin (1):
  i40e: Increase PF reset max loop limit

Catherine Sullivan (1):
  i40e: Bump version to 1.2.43

Jesse Brandeburg (1):
  i40e/i40evf: implement KR2 support

Mitch Williams (3):
  i40evf: delay releasing rings
  i40evf: resequence close operations
  i40evf: add FW version to ethtool info

 drivers/net/ethernet/intel/i40e/i40e_common.c      |  4 ++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 16 +++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  6 +++-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  3 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  2 ++
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 33 +++++++++-------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  2 ++
 10 files changed, 46 insertions(+), 24 deletions(-)

-- 
1.9.3
