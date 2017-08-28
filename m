From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-08-27
Date: Sun, 27 Aug 2017 17:15:48 -0700
Message-ID: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55214 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751493AbdH1AQR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Sudheer updates code comments and state variable so that adminq_subtask
will have accutate information whenever it gets scheduled.

Mariusz stores information about FEC modes, to be used to printing link
states information, so that we do not need to call admin queue when
reporting link status.  Adds VF support for controlling VLAN tag
stripping via ethtool.

Jake provides the majority of changes in this series, starting with
increasing the size of the prefix buffer so that it can hold enough
characters for every possible input, which prevents snprintf truncation.
Fixed other string truncation errors/warnings produced by GCC 7.x.
Removed an unnecessary workaround for resetting XPS.  Fixed an issue
where there is a mismatched affinity mask value, so initialize the value
to cpu_possible_mask and invert the logic for checking incorrect CPU vs
IRQ affinity so that the exceptional case is handled at the check.
Removed ULTRA latency mode due to several issues found and will be
looking at better solution for small packet workloads.

Akeem fixes an issue where the incorrect flag was being used to set
promiscuous mode for unicast, which was enabling promiscuous mode only
for multicast instead of unicast.

Carolyn fixes an issue where an error return value is set, but this
value can be overwritten before we actually do exit the function.  So
remove the error code assignment and add code comments for better
understanding on why we do not need to set and return the error.

The following are changes since commit ec15ecdee5eb9e33a565e1e8eaef39fd4de565cb:
  net: mvpp2: fix the packet size configuration for 10G
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Akeem G Abodunrin (1):
  i40e: Use correct flag to enable egress traffic for unicast promisc

Carolyn Wyborny (1):
  i40e: Fix for unused value issue found by static analysis

Jacob Keller (9):
  i40e: prevent snprintf format specifier truncation
  i40evf: fix possible snprintf truncation of q_vector->name
  i40e: force VMDQ device name truncation
  i40e: remove workaround for resetting XPS
  i40e: move enabling icr0 into i40e_update_enable_itr
  i40e: initialize our affinity_mask based on cpu_possible_mask
  i40e: invert logic for checking incorrect cpu vs irq affinity
  i40e/i40evf: remove ULTRA latency mode
  i40e/i40evf: avoid dynamic ITR updates when polling or low packet rate

Mariusz Stachura (3):
  i40e: Store the requested FEC information
  i40e/i40evf: support for VF VLAN tag stripping control
  i40e: 25G FEC status improvements

Sudheer Mogilappagari (1):
  i40e: Update state variable for adminq subtask

 drivers/net/ethernet/intel/i40e/i40e_common.c      |  8 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 58 ++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 10 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 78 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 62 ++++++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 69 +++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 61 +++++++++++++----
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 40 +++++++++++
 include/linux/avf/virtchnl.h                       |  5 ++
 15 files changed, 285 insertions(+), 122 deletions(-)

-- 
2.14.1
