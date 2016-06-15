From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 00/17] sfc: RX VLAN filtering
Date: Wed, 15 Jun 2016 17:39:56 +0100
Message-ID: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:59973 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752631AbcFOQka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:40:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VLAN-qualified receive filters on EF10 hardware.
This is needed when running as a guest if the hypervisor has enabled
vfs-vlan-restrict, in which case the firmware rejects filters not qualified
with VLAN 0.

Andrew Rybchenko (12):
  sfc: Define macro with EF10 offload feature
  sfc: Move last mc_promisc flag to EF10 filter table state
  sfc: Add efx_nic member with fixed netdev features
  sfc: Forget filter ID when the filter is marked old
  sfc: Move filter IDs to per-VLAN data structure
  sfc: Store unicast and multicast promisc flag with address cache
  sfc: Make EF10 filter management helper functions VLAN-aware
  sfc: Implement list of VLANs added over interface
  sfc: Implement ndo_vlan_rx_{add,kill}_vid() callbacks
  sfc: Fix dup unknown multicast/unicast filters after datapath reset
  sfc: Disable VLAN filtering by default if not strictly required
  sfc: Fix VLAN filtering feature if vPort has VLAN_RESTRICT flag

Edward Cree (3):
  sfc: Assert filter_sem write locked when required
  sfc: Refactor checks for invalid filter ID
  sfc: Update MCDI protocol definitions

Martin Habets (2):
  sfc: Take mac_lock before calling efx_ef10_filter_table_probe
  sfc: VLAN filters must only be created if the firmware supports this.

 drivers/net/ethernet/sfc/ef10.c       |  744 +++++++++++++++---
 drivers/net/ethernet/sfc/ef10_sriov.c |   44 +-
 drivers/net/ethernet/sfc/ef10_sriov.h |    3 +
 drivers/net/ethernet/sfc/efx.c        |   66 +-
 drivers/net/ethernet/sfc/efx.h        |    9 +
 drivers/net/ethernet/sfc/mcdi_pcol.h  | 1327 +++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/net_driver.h |   19 +-
 drivers/net/ethernet/sfc/nic.h        |    5 +
 8 files changed, 2033 insertions(+), 184 deletions(-)
