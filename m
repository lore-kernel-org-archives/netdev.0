From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] 10GbE Intel Wired LAN Driver Updates 2016-01-08
Date: Fri,  8 Jan 2016 05:00:22 -0800
Message-ID: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26376 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbcAHNAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Vasu provides three fixes for ixgbe, first assigns a minimum credit to
a traffic class to resolve a Tx hang for CEE mode configuration.  Second
fix changes the driver to use netdev->fcoe_ddp_xid instead of our local
IXGBE_FCOE_DDP_MAX, since it is correctly set for our different devices
and avoids a DDP skip error on X550.  Lastly fix the PFC configuration
to include X550 devices.

Emil provides a fix for reporting the speed in ethtool by using the
stored value in out adapter structure.  This is due to external drivers
may end up with unknown speed when calling ethtool_get_settings().

Mark fixes the handling of any outer UDP checksum, by passing the
skb up with CHECKSUM_NONE when an outer UDP checksum is set.  This
will cause the stack to check the checksum, also do not increment an
error counter because we do not really know if there is an actual error.
Ixgbe ATR was not handling IPv6 extended headers, so ATR is not being
performed on such packets.  Fix this by skipping extended headers
when they are present.

Usha fixes an issue with X550 and getting FDMI HBA attributes when
FCoE support is enabled.

Neerav fixes an issue for X550 when FCoE and SR-IOV are enabled, which
the hardware generates MDD events.  Resolve this by setting the expected
values in the transmit context descriptors for FCoE/FIP frames and
adding a flush after writing the RDLEN register.

The following are changes since commit 24759daa018f0fc8cccebc89d3dee0953e73785a:
  Merge branch 'macb-usrio-cap'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Emil Tantilov (1):
  ixgbe: do not call check_link for ethtool in ixgbe_get_settings()

Mark Rustad (2):
  ixgbe: Correct handling of any outer UDP checksum setting
  ixgbe: Make ATR recognize IPv6 extended headers

Neerav Parikh (1):
  ixgbe: Fix MDD events generated when FCoE+SRIOV are enabled

Usha Ketineni (1):
  ixgbe: Fix to get FDMI HBA attributes information with X550

Vasu Dev (3):
  ixgbe: Fill at least min credits to a TC credit refills
  ixgbe: use correct FCoE DDP max check
  ixgbe: fix broken PFC with X550

 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |  7 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |  6 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  7 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      | 16 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 52 +++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |  1 +
 6 files changed, 64 insertions(+), 25 deletions(-)

-- 
2.5.0
