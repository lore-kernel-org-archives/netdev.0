From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Fri,  6 Dec 2013 00:06:13 -0800
Message-ID: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42215 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490Ab3LFIGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Christopher Pau provides a patch to set pf_id based on device and
function numbers since NICs with ARI enabled can have function
numbers larger than 8.

Anjali provides 3 i40e patches to update hardware defines to keep
in sync with hardware updates.

Shannon provides the majority of i40e patches, with 7.  First patch
clears the admin queue head and tail registers during admin queue
shutdown. Then simplifies the admin queue head-tail-len setups to
use more virtual registers.  Provides several patches to cleanup
and fix driver load and reset procedures to make more robust.  Lastly,
provides an ethtool test for interrupts using the software interrupt.

Mitch provides some i40e patches which fixes up VF code in the PF
driver, specifically the number of vectors per VF are reported by the
hardware does not include vector 0, so we need to account for this
when checking.  In addition, cleans up debugging messages.

Kamil provides an i40e patch to fix the diagnostics test by restricting
the diagnostic test length.

The following are changes since commit d70f2cf520cf8c86c6b467fc5dcea524ec51dc2f:
  macvlan: Support creating macvtaps from macvlans
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (3):
  i40e: sync header files with hardware
  i40e: register file updates
  i40e: firmware version fields offsets update

Christopher Pau (1):
  i40e: set pf_id based on device and function numbers

Kamil Krawczyk (1):
  i40e: restrict diag test length

Mitch Williams (3):
  i40e: allow one more vector for VFs
  i40e: properly add VF MAC addresses
  i40e: fix debugging messages

Shannon Nelson (7):
  i40e: clear AQ head and tail registers
  i40e: simplify aq head-tail-len setups
  i40e: select reset counters correctly
  i40e: retry call on timeout
  i40e: default debug mask setting
  i40e: add interrupt test
  i40e: add support for triggering EMPR

 drivers/net/ethernet/intel/i40e/i40e.h             |  19 +--
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  66 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   4 +
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  37 +++++-
 drivers/net/ethernet/intel/i40e/i40e_register.h    | 134 +++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   8 +-
 12 files changed, 155 insertions(+), 153 deletions(-)

-- 
1.8.3.1
