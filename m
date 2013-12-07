From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Fri,  6 Dec 2013 18:17:09 -0800
Message-ID: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64593 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758032Ab3LGCR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Jacob provides a i40e patch to get 1588 work correctly by separating
TSYNVALID and TSYNINDX fields in the receive descriptor.

Jesse provides several i40e patches, first to correct the checking
of the multi-bit state.  The hash is reported correctly in the RSS
field if and only if the filter status is 3.  Other values of the
filter status mean different things and we should not depend on a
bitwise result.  Then provides a patch to enable a couple of
workarounds based on revision ID that allow the driver to work
more fully on early hardware.

Shannon provides several i40e patches as well.  First sets the media
type in the hardware structure based on the external connection type.
Then provides a patch to only setup the rings that will be used.  Lastly
provides a fix where the TESTING state was still set when exiting the
ethtool diagnostics.

Kevin Scott provides one i40e patch to add a new flag to the i40e_add_veb()
which allows the driver to request the hardware to filter on layer 2
parameters.

Anjali provides four i40e patches, first refactors the reset code in
order to re-size queues and vectors while the interface is still up.
Then provides a patch to enable all PCTYPEs expect FCoE for RSS.  Adds
a message to notify the user of how many VFs are initialized on each
port.  Lastly adds a new variable to track the number of PF instances,
this is a global counter on purpose so that each PF loaded has a
unique ID.

Catherine bumps the driver version.

The following are changes since commit 0d74c42f788caf3cad727c61c490d9459bc8918b:
  ether_addr_equal: Optimize implementation, remove unused compare_ether_addr
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (4):
  i40e: refactor reset code
  i40e: Enable all PCTYPEs except FCOE for RSS.
  i40e: add num_VFs message
  i40e: Add a new variable to track number of pf instances

Catherine Sullivan (1):
  i40e: Bump version

Jacob Keller (1):
  i40e: separate TSYNVALID and TSYNINDX fields in Rx descriptor

Jeff Kirsher (1):
  i40e: whitespace

Jesse Brandeburg (3):
  i40e: check multi-bit state correctly
  i40e: get media type during link info
  i40e: enable early hardware support

Kevin Scott (1):
  i40e: Add flag for L2 VEB filtering

Shannon Nelson (3):
  i40e: only set up the rings to be used
  i40e: clear test state bit after all ethtool tests
  i40e: refactor ethtool tests

 drivers/net/ethernet/intel/i40e/i40e.h           |   3 +
 drivers/net/ethernet/intel/i40e/i40e_common.c    |  77 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   |  66 ++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 241 +++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_register.h  |   7 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h      |  10 +-
 8 files changed, 316 insertions(+), 107 deletions(-)

-- 
1.8.3.1
