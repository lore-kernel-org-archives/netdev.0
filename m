From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] 40GbE Intel Wired LAN Driver Updates 2017-04-06
Date: Thu,  6 Apr 2017 20:23:21 -0700
Message-ID: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43971 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752013AbdDGDX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:23:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Preethi adds support for the outer checksum and TSO offloads for
encapsulated packets for the VF.

Mitch fixes a possible memory leak, where we need to remove the client
instance when the driver unloads.  Also we need to check to see if the
client (i40iw) is already present during probe, and add a client instance
if necessary.  Lastly, make sure we close any attached clients when the
driver is removed or shut down to prevent a kernel panic.

The following are changes since commit dc423b6be10c56d0dd957caf307f12d16f728f07:
  Merge branch 'ftgmac-rework-batch2-rx-path'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Mitch Williams (3):
  i40e: remove client instance on driver unload
  i40e: register existing client on probe
  i40e: close client on remove and shutdown

Preethi Banala (1):
  i40e/i40evf: Add capability exchange for outer checksum

 drivers/net/ethernet/intel/i40e/i40e_client.c      |  9 ++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 62 +++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  7 +++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 61 +++++++++++----------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  4 +-
 7 files changed, 93 insertions(+), 56 deletions(-)

-- 
2.12.2
