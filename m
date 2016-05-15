From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 40GbE Intel Wired LAN Driver Updates 2016-05-14
Date: Sat, 14 May 2016 21:57:22 -0700
Message-ID: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731AbcEOE5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Kevin adds support to disable link on all ports and changes bits set
for telling firmware the PHY needs to be modified by the driver.

Anjali adds a feature to enable/disable all multicast for a trusted
VF.  Added priv-flag knob to configure global true promiscuous
support.

Shannon adds the support code for calling the admin queue API call
aq_set_switch_config().

Mitch modifies the VF, to log a message if an untrusted VF attempts to
configure promiscuous mode, but lies to it and returns everything is ok
instead of returning an error.  Corrects the logic for reporting the
receive packet hash.  Fixed the adding of a broadcast filter for VFs,
since that all VSIs are configured to receive broadcasts as default,
so do not need to add a filter.

Catherine refactors the ethtool get_settings to report the possible
supported link modes from what we know about the current PHY type and
that with the firmware supported PHY types.

Jacob changes the driver to use WARN_ONCE in order to highlight the
issue, but do not display a warning every time when receive hang
message is received.

Akeem corrects receive ptype payload layer for non_tunneled IPv6, when
it should be layer 4 for UDP, instead of layer 3.

Dan Carpenter fixes an uninitialized variable bug.

The following are changes since commit 8ea658cea453e3deede3851b58113112ae1dd9cb:
  Merge branch '1GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Akeem G Abodunrin (1):
  i40e: Correct UDP packet header for non_tunnel-ipv6

Anjali Singhai Jain (2):
  i40e: Add allmulti support for the VF
  i40e: Add vf-true-promisc-support priv flag

Ashish Shah (1):
  i40e: set context to use VSI RSS LUT for SR-IOV

Bimmy Pujari (1):
  i40e: Bump version from 1.5.10 to 1.5.16

Catherine Sullivan (1):
  i40e: Refactor ethtool get_settings

Dan Carpenter (1):
  i40e: fix an uninitialized variable bug

Jacob Keller (1):
  i40e: change Rx hang message into a WARN_ONCE

Kevin Scott (1):
  i40e: Add support for disabling all link and change bits needed for
    PHY interactions

Mitch Williams (3):
  i40e: lie to the VF
  i40e/i40evf: properly report Rx packet hash
  i40e: don't add broadcast filter for VFs

Shannon Nelson (1):
  i40e: Implement the API function for aq_set_switch_config

 drivers/net/ethernet/intel/i40e/i40e.h             |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   3 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  40 ++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 332 +++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  35 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  21 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   3 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  15 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  15 +-
 13 files changed, 330 insertions(+), 165 deletions(-)

-- 
2.5.5
