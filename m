From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/8] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 21:56:22 +0200
Message-ID: <20170523195630.6460-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36833 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967191AbdEWT4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:56:34 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so40769912wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:56:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add support for device firmware flash on mlxsw spectrum. The firmware files
are expected to be in the Mellanox Firmware Archive version 2 (MFA2)
format.

The firmware flash is triggered on driver initialization time if the device
firmware version does not meet the minimum firmware version supported by
the driver.

Currently, to activate the newly flashed firmware, the user needs to
reboot his system.

The first patch introduces the mlxfw module, which implements common logic
needed for the firmware flash process on Mellanox products, such as the
MFA2 format parsing and the firmware flash state machine logic. As the
module implements common logic which will be needed by various different
Mellanox drivers, it defines a set of callbacks needed to interact with the
specific device.

Patches 1-5 implement the needed mlxfw callbacks in the mlxsw spectrum
driver.

Patches 6 and 7 add boot-time firmware upgrade on the mlxsw spectrum
driver.

Patch 8 adds a fix needed for new firmware versions.

---
v1->v2:
- removed patch with the ethtool part

Ido Schimmel (1):
  mlxsw: spectrum_router: Adjust RIF configuration for new firmware
    versions

Yotam Gigi (7):
  Add the mlxfw module for Mellanox firmware flash process
  mlxsw: reg: Add Management Component Query Information register
  mlxsw: reg: Add Management Component Control register
  mlxsw: reg: Add Management Component Data Access register
  mlxsw: spectrum: Add the needed callbacks for mlxfw integration
  mlxsw: core: Create the mlxsw_fw_rev struct
  mlxsw: spectrum: Validate firmware revision on init

 MAINTAINERS                                        |   8 +
 drivers/net/ethernet/mellanox/Kconfig              |   1 +
 drivers/net/ethernet/mellanox/Makefile             |   1 +
 drivers/net/ethernet/mellanox/mlxfw/Kconfig        |   6 +
 drivers/net/ethernet/mellanox/mlxfw/Makefile       |   2 +
 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h        | 102 ++++
 drivers/net/ethernet/mellanox/mlxfw/mlxfw_fsm.c    | 273 +++++++++
 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c   | 620 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.h   |  66 +++
 .../net/ethernet/mellanox/mlxfw/mlxfw_mfa2_file.h  |  60 ++
 .../ethernet/mellanox/mlxfw/mlxfw_mfa2_format.h    | 103 ++++
 .../net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv.h   |  98 ++++
 .../ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.c | 126 +++++
 .../ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.h |  71 +++
 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   1 +
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  12 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 219 ++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 233 ++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  22 +
 19 files changed, 2019 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_fsm.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_file.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_format.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.h

-- 
2.9.3
