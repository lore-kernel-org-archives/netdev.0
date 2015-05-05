From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 00/14] sfc: Enabling EF10 Vf's, set up vswitching
 and bind the SFC driver to the VF's
Date: Wed, 6 May 2015 00:53:03 +0100
Message-ID: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:51967 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752526AbbEEXxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches makes way for the implementation of EF10
SR-IOV driver starting with some cleanup code.
NIC specific SR-IOV functions are moved to their own header
and netdev_ops are made generic instead of being NIC specific

Next in line comes the patch to enable VF's using sriov_configure.
VEB vswitching hierarchy is set up next followed by patches to
prepare sfc driver to bind to enabled VF's

This is followed by patch to support use of shared RSS contexts
which makes VF's use shared RSS contexts in all cases.

Patch series ends with a patch to bind the sfc driver to the
enabled VF's which creates network interfaces corresponding to
the VF's.

Coming up soon are the patches to set_vf_mac, set_vf_config,
set_vf_vlan, vf_spoofcheck, etc.

These patches have been tested with and without CONFIG_SFC_SRIOV.
In the case of CONFIG_SFC_SRIOV=y enabling of VF's using
sriov_configure is also tested. The enabled VF's bind to the
installed sfc driver succesfully to create network interfaces.
In the case of CONFIG_SFC_SRIOV=n enabling of VF's using
sriov_configure returns the correct error message:
"Function not implemented".

Daniel Pieczko (5):
  sfc: Move and rename efx_vf struct to siena_vf
  sfc: Record [rt]x_dpcpu_fw_id in EF10 nic_data
  sfc: record the PF's vport ID in nic_data
  sfc: create VEB vswitch and vport above default firmware setup
  sfc: get the PF number and record in nic_data

Edward Cree (1):
  sfc: Cope with permissions enforcement added to firmware for SR-IOV

Jon Cooper (1):
  sfc: Add use of shared RSS contexts.

Shradha Shah (7):
  sfc: Own header for nic-specific sriov functions, single instance of
    netdev_ops and sriov removed from Falcon code
  sfc: Enable VF's via a write to the sysfs file sriov_numvfs
  sfc: Use MCDI to set FILTER_OP_IN_TX_DOMAIN
  sfc: Prepare to bind the sfc driver to the VF.
  sfc: create vports for VFs and assign random MAC addresses
  sfc: manually allocate and free vadaptors
  sfc: Bind the sfc driver to any available VF's

 drivers/net/ethernet/sfc/Makefile      |   2 +-
 drivers/net/ethernet/sfc/ef10.c        | 373 +++++++++++++++++++++++++---
 drivers/net/ethernet/sfc/ef10_sriov.c  | 430 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h  |  70 ++++++
 drivers/net/ethernet/sfc/efx.c         | 198 +++++++++------
 drivers/net/ethernet/sfc/efx.h         |  10 +
 drivers/net/ethernet/sfc/ethtool.c     |   5 +-
 drivers/net/ethernet/sfc/falcon.c      |  33 ++-
 drivers/net/ethernet/sfc/farch.c       |  64 +++--
 drivers/net/ethernet/sfc/mcdi.c        | 118 ++++++---
 drivers/net/ethernet/sfc/mcdi.h        |   2 +
 drivers/net/ethernet/sfc/mcdi_pcol.h   |  23 ++
 drivers/net/ethernet/sfc/net_driver.h  |  21 +-
 drivers/net/ethernet/sfc/nic.h         | 133 ++--------
 drivers/net/ethernet/sfc/siena.c       |  25 +-
 drivers/net/ethernet/sfc/siena_sriov.c | 142 ++++++-----
 drivers/net/ethernet/sfc/siena_sriov.h |  79 ++++++
 drivers/net/ethernet/sfc/sriov.c       |  60 +++++
 drivers/net/ethernet/sfc/sriov.h       |  27 +++
 19 files changed, 1455 insertions(+), 360 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.c
 create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.h
 create mode 100644 drivers/net/ethernet/sfc/siena_sriov.h
 create mode 100644 drivers/net/ethernet/sfc/sriov.c
 create mode 100644 drivers/net/ethernet/sfc/sriov.h
