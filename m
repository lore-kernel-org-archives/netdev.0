From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] mlxsw: Introduce support for I2C bus
Date: Wed, 16 Nov 2016 15:20:42 +0100
Message-ID: <1479306046-13324-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, vadimp@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36200 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcKPOUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:20:49 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so11570303wma.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:20:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Vadim says:

This patchset adds I2C access support for SwitchX, SwitchX2, SwitchIB,
SwitchIB2 and Spectrum silicones.

It contains:
 - Small changes in mlxsw core code, needed for I2C bus support;
 - I2C driver, which obtains I2C input/output mailboxes setting and
   provides command interface implementation.
 - Minimal driver, which works on top of I2C driver and allows running
   of mlxsw command interface over I2C bus;

Use case:
On system, which does not have PCI to ASIC (BMC), hwmon functionality
(sensors, pwm, tacho) will be available through I2C.

Usage (manual probing):
echo mlxsw_minimal 0x48 > /sys/bus/i2c/devices/i2c-2/new_device

Sysfs interface:
/sys/bus/i2c/devices/2-0048/hwmon/hwmon5/pwm1
/sys/bus/i2c/devices/2-0048/hwmon/hwmon5/temp1_input

Vadim Pasternak (4):
  mlxsw: Add bus capability flag
  mlxsw: Introduce support for I2C bus
  mlxsw: Invoke driver's init/fini methods only if defined
  mlxsw: minimal: Add I2C support for Mellanox ASICs

 drivers/net/ethernet/mellanox/mlxsw/Kconfig   |  21 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile  |   4 +
 drivers/net/ethernet/mellanox/mlxsw/core.c    |  20 +-
 drivers/net/ethernet/mellanox/mlxsw/core.h    |   3 +
 drivers/net/ethernet/mellanox/mlxsw/i2c.c     | 582 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/i2c.h     |  60 +++
 drivers/net/ethernet/mellanox/mlxsw/minimal.c |  97 +++++
 drivers/net/ethernet/mellanox/mlxsw/pci.c     |   1 +
 8 files changed, 783 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/i2c.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/i2c.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/minimal.c

-- 
2.7.4
