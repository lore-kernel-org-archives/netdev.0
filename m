From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/16] mlxsw: Add Infiniband support for Mellanox switches
Date: Fri, 28 Oct 2016 21:17:34 +0200
Message-ID: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34239 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756330AbcJ1TSF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:18:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id p190so2418899wmp.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:18:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset adds basic Infiniband support for SwitchX-2, Switch-IB
and Switch-IB-2 ASIC drivers.

SwitchX-2 ASIC is VPI capable, which means each port can be either
Ethernet or Infiniband. When the port is configured as Infiniband,
the Subnet Management Agent (SMA) is managed by the SwitchX-2 firmware
and not by the host. Port configuration, MTU and more are configured
remotely by the Subnet Manager (SM).

Usage:
        $ devlink port show
        pci/0000:03:00.0/1: type eth netdev eth0
        pci/0000:03:00.0/3: type eth netdev eth1
        pci/0000:03:00.0/5: type eth netdev eth2
        pci/0000:03:00.0/6: type eth netdev eth3
        pci/0000:03:00.0/8: type eth netdev eth4

        $ devlink port set pci/0000:03:00.0/1 type ib

        $ devlink port show
        pci/0000:03:00.0/1: type ib

Switch-IB (FDR) and Switch-IB-2 (EDR 100Gbs) ASICs are Infiniband-only
switches. The support provided in the mlxsw_switchib.ko driver is port
initialization only. The firmware running in the Silicon implements
the SMA.

Please note that this patchset does only very basic port initialization.
ib_device or RDMA implementations are not part of this patchset.

Elad Raz (12):
  mlxsw: core: Zero payload buffers for couple of registers
  mlxsw: switchx2: Add support for physical port names
  mlxsw: switchx2: Fix port speed configuration
  mlxsw: reg: Add eth prefix to PTYS pack and unpack
  mlxsw: reg: Add Infiniband support to PTYS
  mlxsw: reg: Add local-port to Infiniband port mapping
  mlxsw: switchx2: Add Infiniband switch partition
  mlxsw: core: Add "eth" prefix to mlxsw_core_port_set
  mlxsw: core: Add port type (Eth/IB) set API
  mlxsw: switchx2: Add eth prefix to port create and remove
  mlxsw: switchx2: Add IB port support
  mlxsw: switchib: Introduce SwitchIB and SwitchIB silicon driver

Jiri Pirko (4):
  mlxsw: switchx2: Check if port is usable before calling port create
  mlxsw: switchx2: Move port used check outside port remove function
  mlxsw: spectrum: Move port used check outside port remove function
  mlxsw: Make devlink port instances independent of spectrum/switchx2
    port instances

 drivers/net/ethernet/mellanox/mlxsw/Kconfig      |  11 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/core.c       | 123 ++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h       |  32 +-
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/ib.h         |  39 ++
 drivers/net/ethernet/mellanox/mlxsw/pci.h        |   2 +
 drivers/net/ethernet/mellanox/mlxsw/port.h       |   4 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h        | 104 +++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c   |  95 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h   |   1 -
 drivers/net/ethernet/mellanox/mlxsw/switchib.c   | 598 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c   | 380 +++++++++++---
 13 files changed, 1258 insertions(+), 137 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/ib.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/switchib.c

-- 
2.5.5
