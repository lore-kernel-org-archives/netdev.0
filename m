From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates 2014-06-06
Date: Fri,  6 Jun 2014 02:04:09 -0700
Message-ID: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47729 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbaFFJEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Shannon sets the lan_veb index when the Virtual Ethernet Bridge (VEB) is
created for the basic LAN device and its Virtual Switch Interfaces (VSIs).
Also adds the VEB/VSI statistics in the ethtool stats output.  Increases the
reset wait time because the original time was too optimistic and resets
were failing after EMPR.  This won't delay the actual wait, just allows
us to poll more times as needed.  He fixes the attempted removal of the
HMC space and unhook IRQs when a reset recovery fails because the HMC space
never got setup and IRQs are already unhooked in the first place, so the
removal is not necessary.

Jesse adds a log message for pre-production hardware so that the user is
notified that there may be issues with the hardware, yet does not prevent
the user from using the hardware.  Add the printing of link messages
in the i40e driver like all the other Intel Ethernet drivers.

Mitch makes log message changes to i40evf to prevent confusion by making
the most common messages less scary by lowering them to a less terrifying
log level.  This is due to the fact that depending on the timing of what
the PF driver is doing, it may take a few tries before the VF driver is able
to communicate with the PF driver on init or reset recovery.

Kamil provides a change to prevent the driver from getting into a endless
loop while trying to send GetVersion AQ command, since BO silicon blocks
AQ registers when in Blank Flash mode.  So introduce a simple check for a
correct value in one of the AQ registers to be sure that AQ was configured
correctly.

Matt adds a function which indicates our intention to enable or disable a
particular transmit queue.  Also adds a function to notify the device's
transmit unit that we are about to enable or disable a transmit queue.

The following are changes since commit 9e89fd8b7db71038fd9f70f34e210963fa8fc980:
  ipv6: Shrink udp_v6_mcast_next() to one socket variable
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Catherine Sullivan (1):
  i40e/i40evf: Bump build version

Jesse Brandeburg (2):
  i40e: print message for pre-production hardware
  i40e: print full link message

Kamil Krawczyk (1):
  i40e/i40evf: check AQ register for valid data

Matt Jared (1):
  i40e/i40evf: add Tx pre queue disable function

Mitch Williams (1):
  i40evf: make messages less dire

Shannon Nelson (7):
  i40e: set lan_veb index
  i40e: add VEB stats to ethtool
  i40e: increase reset wait time
  i40e: add vsi x-cast stats
  i40e: add xcast stats for port
  i40e: don't remove HMC that doesn't exist
  i40e: remove irqs only when they are set up

 drivers/net/ethernet/intel/i40e/i40e.h            |   1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.c     |  34 +++++-
 drivers/net/ethernet/intel/i40e/i40e_common.c     |  33 ++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    | 140 +++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 128 +++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_prototype.h  |   1 +
 drivers/net/ethernet/intel/i40e/i40e_register.h   |   8 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c   |  34 +++++-
 drivers/net/ethernet/intel/i40evf/i40e_register.h |   8 ++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   6 +-
 10 files changed, 320 insertions(+), 73 deletions(-)

-- 
1.9.3
