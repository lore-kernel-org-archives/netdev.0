From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-19
Date: Fri, 19 Feb 2016 01:53:55 -0800
Message-ID: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35306 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427400AbcBSJyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e/i40evf only.

Alex Duyck splits up the descriptor count function from the function that
stops the ring to have access to the descriptor count used for the data
portion of the frame.  The rewrites the logic for how we determine if we
can transmit the frame or if it needs to be linearized.  Place the checksum
close to TSO since they have a lot in common and it can help to reduce the
decision tree for how to handle the frame as the first check in TSO is to
see if checksumming is offloaded.

Carolyn adds functions to blink leds on devices using 10GBaseT PHY since
MAC registers used in other designs do not work in this device configuration.
Fixes an issue where a previously removed message has returned.

Kevin increases the timeout when checking GLGEN_RSTAT_DEVSTATE bit since
linking with particular PHY types, the amount of time it takes for the
GLGEN_RSTAT_DEVSTATE to be set increases greatly.

Neerav changes the receive queues to not wait to be disabled before DCB
has been reconfigured, like transmit queues.

Anjali adds new register definitions for programming the parser, flow
director and RSS blocks in the hardware.

Shannon adds the new opcodes and structures used for asking the firmware
to update receive control registers that need extra care when being
accessed while under heavy traffic.  Integrates the new AdminQ functions
for safely accessing the receive control registers that may be affected
by heavy small packet traffic.

Mitch provides another colorful patch description on letting go of 
the stale local VSI pointer when the VF resets.

The following are changes since commit d289cbed9d55a94e44c0ff2c9803e1d68e4b57fe:
  Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (3):
  i40e/i40evf: Break up xmit_descriptor_count from maybe_stop_tx
  i40e/i40evf: Rewrite logic for 8 descriptor per packet check
  i40e/i40evf: Move Tx checksum closer to TSO

Anjali Singhai Jain (1):
  i40e: Expose some registers to program parser, FD and RSS logic

Carolyn Wyborny (3):
  i40e: Add functions to blink led on 10GBaseT PHY
  i40e: Fix led blink capability for 10GBaseT PHY
  i40e: Fix for unexpected messaging

Jesse Brandeburg (1):
  i40e/i40evf: Bump i40e to 1.4.25 and i40evf to 1.4.15

John Underwood (1):
  i40e: add check for null VSI

Kevin Scott (1):
  i40e: Increase timeout when checking GLGEN_RSTAT_DEVSTATE bit

Mitch Williams (1):
  i40e: let go of the past

Neerav Parikh (1):
  i40e: Do not wait for Rx queue disable in DCB reconfig

Pandi Kumar Maharajan (1):
  i40e: suspend scheduling during driver unload

Shannon Nelson (3):
  i40e: add adminq commands for Rx CTL registers
  i40e: implement and use Rx CTL helper functions
  i40e: Use the new rx ctl register helpers. Don't use AQ calls from
    clear_hw.

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  16 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 489 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  44 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  28 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  80 ++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  21 +
 drivers/net/ethernet/intel/i40e/i40e_register.h    |  48 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 188 ++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  63 ++-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  16 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   9 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  16 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 125 ++++++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  15 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 179 ++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  61 +++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 18 files changed, 1140 insertions(+), 263 deletions(-)

-- 
2.5.0
