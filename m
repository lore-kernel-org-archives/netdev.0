From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] Introduce Mellanox Technologies Switch ASICs switchdev drivers
Date: Thu, 23 Jul 2015 17:43:32 +0200
Message-ID: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com, tgraf@suug.ch,
	ast@plumgrid.com, jhs@mojatatu.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, simon.horman@netronome.com,
	linville@tuxdriver.com, andy@greyhouse.net,
	shm@cumulusnetworks.com, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:32815 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbGWPnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 11:43:41 -0400
Received: by wicmv11 with SMTP id mv11so29734205wic.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 08:43:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces Mellanox Technologies Switch driver infrastructure
and support for SwitchX-2 ASIC.

The driver is divided into 3 logical parts:
1) Bus - implements switch bus interface. Currently only PCI bus is
   implemented, but more buses will be added in the future. Namely I2C
   and SGMII.
   (patch #2)
2) Driver - implemements of ASIC-specific functions.
   Currently SwitchX-2 ASIC is supported, but a plan exists to introduce
   support for Spectrum ASIC in the near future.
   (patch #4)
3) Core - infrastructure that glues buses and drivers together.
   It implements register access logic (EMADs) and takes care of RX traps
   and events.
   (patch #1 and #3)

Ido Schimmel (1):
  mlxsw: Add interface to access registers and process events

Jiri Pirko (3):
  mlxsw: Introduce Mellanox switch driver core
  mlxsw: Add PCI bus implementation
  mlxsw: Introduce Mellanox SwitchX-2 ASIC support

 MAINTAINERS                                    |    9 +
 drivers/net/ethernet/mellanox/Kconfig          |    1 +
 drivers/net/ethernet/mellanox/Makefile         |    1 +
 drivers/net/ethernet/mellanox/mlxsw/Kconfig    |   32 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile   |    6 +
 drivers/net/ethernet/mellanox/mlxsw/cmd.h      | 1090 +++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 1287 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  203 +++
 drivers/net/ethernet/mellanox/mlxsw/emad.h     |  127 ++
 drivers/net/ethernet/mellanox/mlxsw/item.h     |  405 ++++++
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 1789 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/pci.h      |  221 +++
 drivers/net/ethernet/mellanox/mlxsw/port.h     |   73 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 1289 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1541 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |   68 +
 drivers/net/ethernet/mellanox/mlxsw/txheader.h |   80 ++
 17 files changed, 8222 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/cmd.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/emad.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/item.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/pci.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/pci.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/port.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/reg.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/switchx2.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/trap.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/txheader.h

-- 
1.9.3
