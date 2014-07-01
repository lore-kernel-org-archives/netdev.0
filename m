From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2014-07-01
Date: Tue,  1 Jul 2014 04:34:57 -0700
Message-ID: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbaGALfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf, igb and ixgbe.

Shannon adds the Base Address High and Low to the admin queue structure
to simplify the logic in the configuration routines.  Also adds code to
clear all queues and interrupts to help clean up after a PXE or other
early boot activity.

Kevin fixes mask assignment value since -1 cannot be used for unsigned
integer types.

Mitch fixes an issue where in some circumstances the reply from the PF
would come back before we were able to properly modify the admin queue
pending and required flags.  This would mess up the flags and put the
driver in an indeterminate state, so fix this by simply setting the flags
before sending the request to the admin queue.  Also changes the branding
string for i40evf to reduce confusion and to match up with our other
marketing materials.

Kamil adds a new variable defining admin send queue (ASQ) command write
back timeout to allow for dynamic modification of this timeout.

Anjali fix a bug in the flow director filter replay logic, so that we
call a replay after a sideband reset correctly.

Jesse adds code to initialize all members of the context descriptor to
prevent possible stale data.

Christopher fixes i40e to prevent writing to reserved bits, since the
queue index is only 0-127.

Jacob removes the unneeded header export.h from the i40e PTP code.
Fixes ixgbe PTP code where the PPS signal was not correct, as it
generates a one half HZ clock signal, it only generates one level
change per second.  To generate a full clock, we need two level changes
per second.

Todd provides a fix for igb to bring up link when the PHY has powered
up, which was reported by Jeff Westfahl.

The following are changes since commit 4135ab8208048a1586385fae1298726d7dacfc26:
  tcp: tcp_conn_request: fix build error when IPv6 is disabled
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: FD filter replay logic bug fix

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 0.4.19 and i40evf to 0.9.38

Christopher Pau (1):
  i40e: limit GLLAN_TXPRE_QDIS to QINDX 0-127

Jacob Keller (2):
  i40e: remove linux/export.h header from i40e_ptp.c
  ixgbe: change PTP NSECS_PER_SEC to IXGBE_PTP_PPS_HALF_SECOND

Jesse Brandeburg (1):
  i40e/i40evf: initialize context descriptor

Kamil Krawczyk (1):
  i40e/i40evf: add ASQ write back timeout variable to AQ structure

Kevin Scott (1):
  i40e: Correct mask assignment value

Mitch Williams (2):
  i40evf: set flags before sending message
  i40evf: change branding string

Shannon Nelson (3):
  i40e/i40evf: Add base address registers to aq struct
  i40e/i40evf: clear aq bah-bal on shutdown
  i40e: clear all queues and interrupts

Todd Fujinaka (1):
  igb: bring link up when PHY is powered up

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      | 67 +++++++--------
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  3 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 97 +++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  1 -
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 11 ++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    | 67 +++++++--------
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  3 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  4 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 33 ++++----
 drivers/net/ethernet/intel/igb/igb_main.c          |  2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       | 16 ++--
 15 files changed, 200 insertions(+), 113 deletions(-)

-- 
1.9.3
