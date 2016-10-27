From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates 2016-10-27
Date: Thu, 27 Oct 2016 14:27:53 -0700
Message-ID: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:29768 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031934AbcJ0V17 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:27:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to ixgbe and i40e.

Emil fixes a NULL pointer dereference when a macvlan interface is brought
up while the PF is still down.

David root caused the original panic that was fixed by commit id
(a036244c068612 "i40e: Fix kernel panic on enable/disable LLDP") and the
fix was not quite correct, so removed the get_default_tc() and replaced
it with a #define since there is only one TC supported as a default.

Guilherme Piccoli fixes an issue where if we modprobe the driver module
without enough MSI-X interrupts, then unload the module and reload it
again, the kernel would crash.  So if we fail to allocate enough MSI-X
interrupts, we should disable them since they were previously enabled.

Huaibin Wang found that the order of the arguments for
ndo_dflt_bridge_getlink() were in the correct order, so fix the order.

The following are changes since commit d5d32e4b76687f4df9ad3ba8d3702b7347f51fa6:
  net: ipv6: Do not consider link state for nexthop validation
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 40GbE

David Ertman (1):
  i40e: Fix configure TCs after initial DCB disable

Emil Tantilov (1):
  ixgbe: fix panic when using macvlan with l2-fwd-offload enabled

Guilherme G Piccoli (1):
  i40e: disable MSI-X interrupts if we cannot reserve enough vectors

Huaibin Wang (1):
  i40e: fix call of ndo_dflt_bridge_getlink()

 drivers/net/ethernet/intel/i40e/i40e.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 34 +++++----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++++----
 3 files changed, 15 insertions(+), 32 deletions(-)

-- 
2.7.4
