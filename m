From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 10GbE Intel Wired LAN Driver Updates 2017-05-31
Date: Wed, 31 May 2017 14:19:21 -0700
Message-ID: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38747 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbdEaVTo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only.

Scott enables support for TSO & GSO for MPLS encapsulated packets for both
ixgbe and ixgbevf.

Liwei Song fixes an issue where seqcount/seqlock in ixgbe_get_stats64()
are not initialized in time, so move the initialization into probe routine
after the transmit and receive rings are initialized.

Paul cleans up led_[on|off] for X550EM_X, since the firmware configures
the PHY & MAC and we have no PHY access so LED on/off is not supported
with this device.

Emil provides several fixes, starting with enabling RSS on VF to VF
traffic on the same PF.  Fixed PHY identification, where the previous
method was unreliable, so use a different register to ensure proper
identification.  Cleaned up the logic which could cause us to
skip the link configuration, this skipping over the link configuration
was leaving SFP+ PHY's in an unstable state, so always call
setup_mac_link().  Added RS1 (rate select 1) support for ixgbe.  Lastly,
fixed incorrect logic in the setting up of SFP+ link speed.

Mark fixes the thermal sensor event logic, where it was being executed
when there really was no thermal event.  So simplify the logic to only
execute when there is a thermal event.

Tony adds additional error checks and reporting when setting a VF MAC
address to ensure that the MAC filter was successfully added.  Also
fixed possible truncation warnings, as well as implicit fallthrough
warnings.

The following are changes since commit ffe406457753a7ca2061ecc8c4d3971623066911:
  bnxt_en: Fix xmit_more with BQL.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Emil Tantilov (6):
  ixgbe: enable L3/L4 filtering for Tx switched packets
  ixgbe: correct CS4223/7 PHY identification
  ixgbe: add write flush when configuring CS4223/7
  ixgbe: always call setup_mac_link for multispeed fiber
  ixgbe: add missing configuration for rate select 1
  ixgbe: fix incorrect status check

Liwei Song (1):
  ixgbe: initialize u64_stats_sync structures early at ixgbe_probe

Mark Rustad (1):
  ixgbe: Correct thermal sensor event check

Paul Greenwalt (1):
  ixgbe: Remove MAC X550EM_X 1Gbase-t led_[on|off] support

Scott Peterson (1):
  ixgbe/ixgbevf: Enables TSO for MPLS encapsulated packets

Tony Nguyen (5):
  ixgbe: Add error checking to setting VF MAC
  ixgbe: Resolve truncation warning for q_vector->name
  ixgbe: Resolve warnings for -Wimplicit-fallthrough
  ixgbevf: Resolve truncation warning for q_vector->name
  ixgbevf: Resolve warnings for -Wimplicit-fallthrough

 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |  9 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   | 44 ++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  4 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 48 +++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |  5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 61 ++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 61 +++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 26 ++++++----
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  2 +
 9 files changed, 180 insertions(+), 80 deletions(-)

-- 
2.12.2
