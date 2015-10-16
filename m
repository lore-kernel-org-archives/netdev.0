From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/16] mlxsw: Driver update, add initial support for Spectrum ASIC
Date: Fri, 16 Oct 2015 14:01:21 +0200
Message-ID: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38574 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbbJPMBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:41 -0400
Received: by wicll6 with SMTP id ll6so7342531wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Purpose of this patchset is to introduce initial support for Mellanox
Spectrum ASIC, including L2 bridge forwarding offload.

The only non-mlxsw patch in this patchset is the first one, introducing
pre-change upper notifier. That is used in last patch to ensure ports of
single ASIC are not bridged into multiple bridges, as that scenario is
currently not supported by driver.

Elad Raz (1):
  mlxsw: reg: Add Switch Port VID and Switch Port VLAN Membership
    registers definitions

Ido Schimmel (7):
  mlxsw: Enable configuration of flooding domains
  mlxsw: cmd: Introduce per-FID flooding tables
  mlxsw: cmd: Introduce FID-offset flooding tables
  mlxsw: reg: Add Switch FID Management register definition
  mlxsw: reg: Add Switch VID to FID Allocation register definition
  mlxsw: reg: Add Switch Virtual-Port Enabling register definition
  mlxsw: reg: Add Switch Port VLAN MAC Learning register definition

Jiri Pirko (8):
  net: introduce pre-change upper device notifier
  mlxsw: item: Make src arg of memcpy_to helper const
  mlxsw: item: Add MLXSW_ITEM_BUF_INDEXED helper
  mlxsw: reg: Add Switch Filtering Database register definition
  mlxsw: reg: Add Switch FDB Notification register definition
  mlxsw: reg: Add shared buffer configuration registers definitions
  mlxsw: reg: Add Switch Filtering Database Aging Time register
    definition
  mlxsw: spectrum: Add initial support for Spectrum ASIC

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   11 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    3 +
 drivers/net/ethernet/mellanox/mlxsw/cmd.h          |   25 +
 drivers/net/ethernet/mellanox/mlxsw/core.h         |    5 +
 drivers/net/ethernet/mellanox/mlxsw/item.h         |   50 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |   11 +
 drivers/net/ethernet/mellanox/mlxsw/pci.h          |    1 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 1142 +++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 1948 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  121 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  422 +++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  863 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |    3 +-
 drivers/net/ethernet/mellanox/mlxsw/txheader.h     |    1 +
 include/linux/netdevice.h                          |    1 +
 net/core/dev.c                                     |    9 +
 16 files changed, 4604 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c

-- 
1.9.3
