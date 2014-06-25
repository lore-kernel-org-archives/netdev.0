From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/14][pull request] Intel Wired LAN Driver Updates 2014-06-24
Date: Tue, 24 Jun 2014 18:26:11 -0700
Message-ID: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16460 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbaFYB0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 21:26:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Greg provides a patch to stop the VF device after setting its MAC address.
This is due to if the host VMM administrator has changed the VF device's MAC
address then the i40e driver needs to halt the VF device so that the
administrator will be forced to reload the VF driver so that the VF driver
will start using the newly assigned MAC address.

Shannon provides several patches for i40e, first makes prep_for_test() a
void function since the return value was being ignored for the most part
by all its callers.  Adds a log warning when the firmware's API minor/major
number is not what we expect to assist the user by informing them they
may need to update their NVM or SW.  Cleans up a stray print message
so that it is similar to other print messages.  Ensures to set the
WoL flag when setting LAA and allow the user to set LAA again.  So do
not short-circuit the LAA assignment when the driver thinks it has
already been done as it is possible that the user might want to force
the address setting again.  Provides a couple more LAA fixes to ensure
the LAA gets restored after resets.

Neerav provides a patch for i40e to add a PF reset when a malicious driver
event for the PF occurs.  As per the specification when the PF driver
receives a malicious driver event the queue that caused the event is
already stopped and it is expected that the function that owns the queue
will reset the queue, but in some cases it may not be possible to determine
the queue, so it is suggested to reset the whole function.

Carolyn fixes ethtool coalesce settings to allow 0 as a disable value and
adds message to user about invalid values.

Jesse removes a reserved type which was not removed from the code.

Catherine provides a patch to add the ability to enable/disable link from
set_link)restart_an() which will make it easy to toggle link without
calling set_phy_config() when no other link settings need to change.

Anjali provides a patch to ensure we do a PF reset on Tx hang and that
way we avoid any Malicious Driver Detect (MDD) events because of a Tx
queue disable failure.

v2:
 - fixed the un-needed return in patch 2 based on feedback from Sergei Shtylyov
 - added punctuation to print statements and code comment based on
   feedback from Sergei Shtylyov

The following are changes since commit 5433ba365f6dd9f30899188755eb4b093314732c:
  cxgb4: Fix endian bug introduced in cxgb4 dcb patchset
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Bypass timeout recovery level 0 so as to not cause MDD

Carolyn Wyborny (1):
  i40e: Fix ethtool coalesce settings

Catherine Sullivan (2):
  i40e: Add ablitity to enable/disable link from set_link_restart_an
  i40e/i40evf: Bump i40e to 0.4.17 and i40evf to 0.9.36

Greg Rose (1):
  i40e: Stop the VF device after setting its MAC address

Jesse Brandeburg (1):
  i40e/i40evf: remove reserved type

Neerav Parikh (1):
  i40e: Add PF reset when Malicious driver event for PF

Shannon Nelson (7):
  i40e: make prep_for_reset void
  i40e: warn on newer/older firmware API rev
  i40e: fix a stray print message
  i40e: use WoL flag when setting LAA
  i40e: allow user to set LAA again
  i40e: reapply LAA after reset
  i40e: no pf reset at pci remove

 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  31 ++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 125 +++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 11 files changed, 128 insertions(+), 49 deletions(-)

-- 
1.9.3
