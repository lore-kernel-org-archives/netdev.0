From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  0/9][pull request] Intel Wired LAN Driver Updates
Date: Wed,  4 Sep 2013 06:08:47 -0700
Message-ID: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17747 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757098Ab3IDNI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:08:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb only.

Todd provides a fix for igb to not look for a PBA in the iNVM on
devices that are flashless.

Akeem provides igb patches to add a new PHY id for i354, as well as
a couple of patches to implement the new PHY id.  He also provides
several patches to correctly report the appropriate media type as
well as correctly report advertised/supported link for i354 devices.
Lastly Akeem implements a 1 second delay mechanism for i210 devices
to avoid erroneous link issue with the link partner.

The following are changes since commit c995ae2259ee36caf48bbfacf40111998dacd4af:
  tcp: Change return value of tcp_rcv_established()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (8):
  igb: Implementation of 1-sec delay for i210 devices
  igb: New PHY_ID for i354 device
  igb: M88E1543 PHY downshift implementation
  igb: No PHPM support in i354 devices
  igb: Support to get 2_5G link status for appropriate media type
  igb: Get speed and duplex for 1G non_copper devices
  igb: Implementation to report advertised/supported link on i354
    devices
  igb: Update version number

Todd Fujinaka (1):
  igb: Don't look for a PBA in the iNVM when flashless

 drivers/net/ethernet/intel/igb/e1000_82575.c   | 81 ++++++++++++++++++++------
 drivers/net/ethernet/intel/igb/e1000_defines.h |  8 +--
 drivers/net/ethernet/intel/igb/e1000_mac.c     | 11 ----
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 31 ++++++----
 drivers/net/ethernet/intel/igb/igb.h           |  3 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 26 +++++----
 drivers/net/ethernet/intel/igb/igb_main.c      | 43 ++++++++++++--
 7 files changed, 143 insertions(+), 60 deletions(-)

-- 
1.8.3.1
