From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] 40GbE Intel Wired LAN Driver Updates 2016-01-08
Date: Fri,  8 Jan 2016 02:14:38 -0800
Message-ID: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48697 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbcAHKO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 05:14:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Mitch adds a useful error message and return value when the VFs are being
reset, since there is a brief window of time when the VF cannot be
configured because they do not have a VSI to configure.  Also made a driver
change to allow the user to specify a zero MAC address for VFs, which
causes the existing MAC address to be removed and allows the VF to use a
random address (like libvirt).

Sowmini Varadhan from Oracle adds similar functionality/fix to i40e that
was added to ixgbe earlier.  The fix attempts to look up the MAC address
in the Open Firmware on systems that support it and use IDPROM on SPARC
if no OF address is found.

Anjali provides a fix the code path so that we do not call skb_set_hash()
if the feature is disabled.

Jesse removes a device ID that has never been productized and there are
no plans to use it, so just remove it.

The following are changes since commit 24759daa018f0fc8cccebc89d3dee0953e73785a:
  Merge branch 'macb-usrio-cap'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (1):
  i40e: Fix Rx hash reported to the stack by our driver

Jesse Brandeburg (1):
  i40e: remove forever unused ID

Mitch Williams (2):
  i40e: change log messages and error returns
  i40e: allow zero MAC address for VFs

Sowmini Varadhan (1):
  i40e: Look up MAC address in Open Firmware or IDPROM

 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 91 +++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 54 +++++++------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 38 +++++----
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 54 +++++++------
 9 files changed, 173 insertions(+), 69 deletions(-)

-- 
2.5.0
