From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates
Date: Mon,  5 May 2014 13:07:36 -0700
Message-ID: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59533 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466AbaEEUHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 16:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e only.

David provides four fixes for e1000e, first is a workaround for a hardware
erratum on 82579 devices which experienced packet loss in gigabit and 100
speeds when interconnect between the PHY and MAC is exiting K1 power saving
state.  Second expands the scope of a workaround to include i217 and i218
parts as well to address over aggressive transmit behavior when connecting
at 10Mbs half-duplex.  Next is to resolve a reported link flap issue on
82579 parts which was root caused as an interoperability problem between
82579 and at least some Broadcom PHYs in the Energy Efficient Ethernet wake
mechanism.  Lastly, restricts the workaround of putting the PHY into MDIO
slow mode to access the PHY id to relevant parts since this issue has been
fixed on the newer hardware.

The following are changes since commit 9d4619c492c84e4c1e6d7127f1cbf55da04599d0:
  Altera TSE: ALTERA_TSE should depend on HAS_DMA
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

David Ertman (4):
  e1000e: Workaround for dropped packets in Gig/100 speeds on 82579
  e1000e: Expand workaround for 10Mb HD throughput bug
  e1000e: Fix issue with link flap on 82579
  e1000e: Restrict MDIO Slow Mode workaround to relevant parts

 drivers/net/ethernet/intel/e1000e/ich8lan.c | 71 +++++++++++++++++------------
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  3 ++
 drivers/net/ethernet/intel/e1000e/phy.h     |  1 +
 3 files changed, 46 insertions(+), 29 deletions(-)

-- 
1.9.0
