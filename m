From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 00/14] be2net: patch set
Date: Thu, 17 Jul 2014 16:20:18 +0530
Message-ID: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22735 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756708AbaGQKsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches 1 to 6 address issues with return values of some ndo/ethtool
driver methods. In error scenarios, either an inappropriate error or
a +ve return value (where the stack expects a -ve value) was being returned.

Patch 7 updates description strings for certain UE bits.

Patch 8 cleans up (reduces) argument passing for a few routines in be_cmds.c.

Patch 9 removes some unused code (unused definitions.)

Patch 10 updates NULL check in the driver to a consistent "if (!foo)" style.

Patchs 11 to 13 fix a few minor issues with the earlier patch bec84e6
("create optimal number of queues on SR-IOV config"):
	- patch 11 fixes BEx_get_resources() code to use be_max_vfs() macro
	- patch 12 skips SR-IOV config code for BE2 that doesn't support SRIOV
	- patch 13 uses adapter->flags to track SRIOV enabled state

Patch 14 updates the driver version.

Please consider applying to the net-next tree. Thanks.

Kalesh AP (9):
  be2net: use -ENETDOWN error status when interface is down
  be2net: fix error status for FW-download
  be2net: return -ETIMEDOUT when a FW-cmd times out
  be2net: return -ENOMEM for memory allocation failures
  be2net: fix return status of some ethtool methods
  be2net: fix return status of some ndo methods
  be2net: reduce arguments passed to FW-cmd routines
  be2net: remove unused structures in be_cmds.h
  be2net: use "if (!foo)" test style

Sathya Perla (1):
  be2net: update driver version to 10.4

Vasundhara Volam (4):
  be2net: update UE bit description strings
  be2net: use be_max_vfs() macro to access max-vfs
  be2net: avoid SRIOV config for BE2 chip
  be2net: use adapter->flags to track SRIOV state

 drivers/net/ethernet/emulex/benet/be.h         |    8 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   23 ++---
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   35 +-------
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   12 ++-
 drivers/net/ethernet/emulex/benet/be_main.c    |  116 +++++++++++++-----------
 5 files changed, 89 insertions(+), 105 deletions(-)
