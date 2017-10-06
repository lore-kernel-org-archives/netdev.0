From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-10-06
Date: Fri,  6 Oct 2017 10:57:12 -0700
Message-ID: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17217 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751862AbdJFR5t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Rami fixes a typo in the code comments.

Mitch adds an ethtool private flag to control source pruning to resolve an
issue where our default behavior is to enable source pruning which breaks ARP
monitoring in channel bonding.  Fixes a couple of register definitions, which
were incorrect.

Jake fixes an issue with multiple logical CPUs per core (simultaneous
multithreading - SMT) and how we set an affinity hint based on the v_idx of
that q_vector, which is an incremental value and might lead to multiple
offline CPUs being assigned to a q_vector.  Instead, we should only assign
hints for CPUs which are online, so look to use cpumask_local_spread().
Also fixed a VF VLAN tag stripping issue, where the flag created to change
this feature was seen as unchangeable.  Lastly, organized and re-numbered
the feature flags.

Alan re-enables PTP L4 for XL710 devices with firmware version 6.0 or
greater, now that the previous bug in the older firmware is fixed.
Implements the PCI error handlers for reset_prepare() and reset_done() to
allow us to handle function level resets.

Alice cleans up code that was added to the incorrect function during a
merge.

Filip adds a change to display an error message when a module is inserted
that does not meet the thermal requirements, Talking Heads "Burning Down
the House" comes to mind.  Also fixed a flow director filter issue where
a variable was not being cleared which stores the filter number to be
removed from the list when the firmware refused to add the requested
filter.

The following are changes since commit cc71b7b071192ac1c288e272fdc3f3877eb96663:
  net/ipv6: remove unused err variable on icmpv6_push_pending_frames
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40e: re-enable PTP L4 capabilities for XL710 if FW >6.0
  i40e: implement split PCI error reset handler

Alice Michael (1):
  i40e: fix merge error

Filip Sadowski (2):
  i40e: Display error message if module does not meet thermal
    requirements
  i40e: Properly maintain flow director filters list

Jacob Keller (4):
  i40e/i40evf: spread CPU affinity hints across online CPUs only
  i40evf: enable support for VF VLAN tag stripping control
  i40e: ignore skb->xmit_more when deciding to set RS bit
  i40e/i40evf: organize and re-number feature flags

Jesse Brandeburg (1):
  i40e/i40evf: use DECLARE_BITMAP for state

Mariusz Stachura (1):
  i40e: do not enter PHY debug mode while setting LEDs behaviour

Mitch Williams (3):
  i40e: add private flag to control source pruning
  i40e: redfine I40E_PHY_TYPE_MAX
  i40e: fix incorrect register definition

Rami Rosen (1):
  i40e: fix a typo in i40e_pf documentation

 drivers/net/ethernet/intel/i40e/i40e.h             |  98 +++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  20 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 104 +++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_register.h    |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  34 +------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   3 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  32 +++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  31 +++---
 12 files changed, 203 insertions(+), 138 deletions(-)

-- 
2.14.2
