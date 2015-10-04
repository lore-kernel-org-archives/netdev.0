From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates 2015-10-03
Date: Sat,  3 Oct 2015 19:54:38 -0700
Message-ID: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19539 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbbJDCyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 22:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf, some of which are to
resolve more Red Hat bugzilla issues.

Jiang Liu updates the i40e and i40evf drivers to use numa_mem_id()
instead of numa_node_id() to get the nearest node with memory which
better supports memoryless nodes.

Anjali fixes an issue from Dan Carpenter <dan.carpenter@oracle.com>,
to resolve a memory leak in X722 RSS configuration path, where we should
free the memory allocated before exiting.

Shannon modifies the drivers to ensure we have the spinlocks before we
clear the ARQ and ASQ management registers.  In addition, we widen the
locked portion insert a sanity check to ensure we are working with safe
register values.

Mitch fixes an issue where under certain circumstances, we can get an
extra VF_RESOURCES message from the PF driver at runtime.  When this
occurs, we need to parse it because our VSI may have changed and that
will affect the relationship with the PF driver.  But this parsing also
blows away our current MAC address, so resolve the issue by restoring
the current MAC address from the netdev struct after we parse the
resource message.

The following are changes since commit e96f78ab2703f3b0d512f6b469bc685d2ef20475:
  tcp/dccp: add SLAB_DESTROY_BY_RCU flag for request sockets
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai (1):
  i40e: Fix a memory leak in X722 rss config path

Jiang Liu (2):
  i40e: Use numa_mem_id() to better support memoryless node
  i40evf: Use numa_mem_id() to better support memoryless node

Mitch Williams (1):
  i40evf: don't blow away MAC address

Shannon Nelson (1):
  i40e/i40evf: grab the AQ spinlocks before clearing registers

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      | 45 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    | 45 +++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  2 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  2 +
 6 files changed, 53 insertions(+), 47 deletions(-)

-- 
2.4.3
