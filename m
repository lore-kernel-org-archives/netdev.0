From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/10][pull request] 40GbE Intel Wired LAN Driver Updates 2016-09-22
Date: Thu, 22 Sep 2016 22:45:32 -0700
Message-ID: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:40400 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754378AbcIWFpo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 01:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Sridhar fixes link state event handling by updating the carrier and
starts/stops the Tx queues based on the link state notification from PF.

Brady fixes an issue where a user defined RSS hash key was not being
set because a user defined indirection table is not supplied when changing
the hash key, so if an indirection table is not supplied now, then a
default one is created and the hash key is correctly set.  Also fixed
an issue where when NPAR was enabled, we were still using pf->mac_seid
to perform the dump port query. Instead, go through the VSI to determine
the correct ID to use in either case.

Mitch provides one fix where a conditional return code was reversed, so
he does a "switheroo" to fix the issue.

Carolyn has two fixes, first fixes an issue in the virt channel code,
where a return code was not checked for NULL when applicable.  Second,
fixes an issue where we were byte swapping the port parameter, then
byte swapping it again in function execution.

Colin Ian King fixes a potential NULL pointer dereference.

Bimmy changes up i40evf_up_complete() to be void since it always returns
success anyways, which allows cleaning up of code which checked the
return code from this function.

Alex fixed an issue where the driver was incorrectly assuming that we
would always be pulling no more than 1 descriptor from each fragment.
So to correct this, we just need to make certain to test all the way to
the end of the fragments as it is possible for us to span 2 descriptors
in the block before us so we need to guarantee that even the last 6
descriptors have enough data to fill a full frame.

v2: dropped patches 1-3, 10 and 12 from the original series since Or
    Gerlitz pointed out several areas of improvement in the implementation
    of the VF Port representor netdev.  Sridhar is re-working the series
    for later submission.

The following are changes since commit cdd0766d7da19085e88df86d1e5e21d9fe3d374f:
  Merge branch 'ftgmac100-ast2500-support'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40e: fix setting user defined RSS hash key
  i40e: fix "dump port" command when NPAR enabled

Alexander Duyck (1):
  i40e: Limit TX descriptor count in cases where frag size is greater
    than 16K

Bimmy Pujari (1):
  i40evf: remove unnecessary error checking against i40evf_up_complete

Carolyn Wyborny (2):
  i40e: Fix to check for NULL
  i40e: Fix for extra byte swap in tunnel setup

Colin Ian King (1):
  i40e: avoid potential null pointer dereference when assigning len

Lihong Yang (1):
  i40evf: remove unnecessary error checking against i40e_shutdown_adminq

Mitch Williams (1):
  i40e: return correct opcode to VF

Sridhar Samudrala (1):
  i40evf: Fix link state event handling

 drivers/net/ethernet/intel/i40e/i40e.h              |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c      |  7 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c      | 12 +++++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c         | 12 +++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c         |  7 ++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c  | 15 ++++++++++++---
 drivers/net/ethernet/intel/i40evf/i40e_common.c     |  3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c       |  7 ++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 18 ++++++++----------
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 10 +++++++---
 10 files changed, 53 insertions(+), 40 deletions(-)

-- 
2.7.4
