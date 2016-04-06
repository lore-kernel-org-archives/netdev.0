From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2016-04-05
Date: Tue,  5 Apr 2016 20:35:55 -0700
Message-ID: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48525 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527AbcDFDgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Colin Ian King cleaned up a redundant NULL check which was found by static
analysis.

Anjali enables geneve receive offload for XL710/X710 devices.

Mitch cleans up unused variable in i40e_vc_get_vf_resources_msg().
Fixed the driver to actually be able to adjust VLAN tagging features
through ethtool, as expected.  Fixed a problem where VF resets would
get lost by the PF preventing the VF driver from initializing.  Also
put users mind at ease by lowering some message levels since many of
these conditions can happen any time VFs are enabled or disabled and
are not really indicative a fatal problems, unless they happen
continuously.

Shannon disables the link polling to lessen the admin queue traffic
especially since the link event mask usage has been fixed recently.

Alex Duyck fixes the i40e and i40evf drivers to correctly update
checksums for frames up to 16776960 in length which should be more than
large enough for all possible TSO frames in the near future.

The following are changes since commit 4da46cebbd3b4dc445195a9672c99c1353af5695:
  net/core/dev: Warn on a too-short GRO frame
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (1):
  i40e/i40evf: Fix TSO checksum pseudo-header adjustment

Anjali Singhai Jain (1):
  i40e: Enable Geneve offload for FW API ver > 1.4 for XL710/X710
    devices

Avinash Dayanand (2):
  i40e: Fix for supported link modes in 10GBaseT PHY's
  i40e/i40evf: Bump patch from 1.5.1 to 1.5.2

Catherine Sullivan (2):
  i40e: Add new device ID for X722
  i40evf: Fix get_rss_aq

Colin King (1):
  i40e: remove redundant check on vsi->active_vlans

Mitch Williams (5):
  i40e: Remove unused variable
  i40evf: Fix VLAN features
  i40e: Make VF resets more reliable
  i40evf: Add longer wait after remove module
  i40e: Lower some message levels

Shannon Nelson (2):
  i40e: Disable link polling
  i40e: Request phy media event at reset time

 drivers/net/ethernet/intel/i40e/i40e_common.c      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  5 ++-
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 16 ++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 12 +++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 11 +++----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 37 ++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 11 +++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 31 +++++++++++++++---
 11 files changed, 84 insertions(+), 43 deletions(-)

-- 
2.5.5
