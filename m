From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 00/16] sfc: Get/Set MAC address and ndo_[set/get]_vf_*
 entrypoint functions
Date: Wed, 20 May 2015 11:06:09 +0100
Message-ID: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:31126 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753832AbbETKG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:06:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second instalment of patches towards supporting EF10 SRIOV.

This patch series implements the ndo_get_vf_config, ndo_set_vf_mac,
ndo_set_vf_vlan and ndo_set_vf_spoofcheck function callbacks for
EF10.

This patch series also introduces privileges for the MCDI commands
based on which functions are allowed to call them, i.e. Link control
or primary function.

The patch series has been tested with and without CONFIG_SFC_SRIOV.

The ndo function callbacks are tested using ip link.

Daniel Pieczko (1):
  sfc: Enable a VF to get its own MAC address

Edward Cree (2):
  sfc: protect filter table against use-after-free
  sfc: add ndo_set_vf_link_state() function for EF10

Jon Cooper (2):
  sfc: Initialise MCDI buffers to 0 on declaration.
  sfc: Change entity reset on MC reboot to a new datapath-only reset.

Shradha Shah (11):
  sfc: Add permissions to MCDI commands
  sfc: change definition of MC_CMD_VADAPTOR_ALLOC
  sfc: MC_CMD_SET_MAC can only be called by the link control Function
  sfc: Store vf_index in nic_data for Ef10.
  sfc: save old MAC address in case sriov_mac_address_changed fails
  sfc: Store the efx_nic struct of the current VF in the VF data struct
  sfc: add ndo_set_vf_mac() function for EF10
  sfc: Add ndo_get_vf_config() function for EF10
  sfc: add ndo_set_vf_vlan() function for EF10
  sfc: Implement dummy disable of VF spoof check for EF10
  sfc: set the MAC address using MC_CMD_VADAPTOR_SET_MAC

 drivers/net/ethernet/sfc/ef10.c        | 279 ++++++++++++++++++++----
 drivers/net/ethernet/sfc/ef10_sriov.c  | 320 ++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/ef10_sriov.h  |  36 ++--
 drivers/net/ethernet/sfc/efx.c         |  65 ++++--
 drivers/net/ethernet/sfc/efx.h         |   5 +
 drivers/net/ethernet/sfc/enum.h        |   2 +
 drivers/net/ethernet/sfc/ethtool.c     |   2 +-
 drivers/net/ethernet/sfc/mcdi.c        |  12 +-
 drivers/net/ethernet/sfc/mcdi.h        |   8 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h   | 381 ++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/mcdi_port.c   |   1 +
 drivers/net/ethernet/sfc/net_driver.h  |  11 +-
 drivers/net/ethernet/sfc/nic.h         |   1 +
 drivers/net/ethernet/sfc/ptp.c         |   6 +-
 drivers/net/ethernet/sfc/siena.c       |   2 +-
 drivers/net/ethernet/sfc/siena_sriov.c |   6 +-
 drivers/net/ethernet/sfc/siena_sriov.h |   2 +-
 drivers/net/ethernet/sfc/sriov.c       |  12 ++
 drivers/net/ethernet/sfc/sriov.h       |   2 +
 19 files changed, 1055 insertions(+), 98 deletions(-)
