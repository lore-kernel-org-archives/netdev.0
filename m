From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 00/14] sfc: ndo_get_phys_port_id, vadaptor stats
 and PF unload when Vf's assigned to guest
Date: Mon, 1 Jun 2015 13:58:44 +0100
Message-ID: <556C5704.4060901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:12244 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751357AbbFAM7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 08:59:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the third and last instalment of SRIOV for EF10 patches.

This patch set includes implementation of ndo_get_phys_port_id
and changes to the MAC statistics code in order to support
vadaptor statistics.

It also includes code to deal with PF unload when Vf's are still
assigned to the guest.

The first couple of patches create sysfs files for physical port
and link control flags which are particularly useful when we have
enabled a large number of VF's.

These patches have been tested with and without CONFIG_SFC_SRIOV.
The creation and content of the sysfs files has been tested.
The statistics are tested using ethtool for monitoring.

Daniel Pieczko (11):
  sfc: add "port_" prefix to MAC stats
  sfc: set the port-id when calling MC_CMD_MAC_STATS
  sfc: display vadaptor statistics for all interfaces
  sfc: DMA the VF stats only when requested
  sfc: update netdevice statistics to use vadaptor stats
  sfc: suppress ENOENT error messages from MC_CMD_MAC_STATS
  sfc: suppress vadaptor stats when EVB is not present
  sfc: don't update stats on VF when called in atomic context
  sfc: do not allow VFs to be destroyed if assigned to guests
  sfc: force removal of VF and vport on driver removal
  sfc: leak vports if a VF is assigned during PF unload

Shradha Shah (3):
  sfc: Add code to export port_num in netdev->dev_port
  sfc: Add sysfs entry for flags (link control and primary)
  sfc: Implement ndo_gets_phys_port_id() for EF10 VFs

 drivers/net/ethernet/sfc/ef10.c       | 538 +++++++++++++++++++++++-----------
 drivers/net/ethernet/sfc/ef10_sriov.c |  57 +++-
 drivers/net/ethernet/sfc/ef10_sriov.h |   5 +
 drivers/net/ethernet/sfc/efx.c        |   8 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h  |  30 +-
 drivers/net/ethernet/sfc/mcdi_port.c  |  12 +-
 drivers/net/ethernet/sfc/net_driver.h |   2 +
 drivers/net/ethernet/sfc/nic.h        | 117 ++++----
 drivers/net/ethernet/sfc/sriov.c      |  11 +
 drivers/net/ethernet/sfc/sriov.h      |   2 +
 10 files changed, 554 insertions(+), 228 deletions(-)
