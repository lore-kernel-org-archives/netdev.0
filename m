From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/3] be2net: patch set
Date: Fri, 1 Aug 2014 17:47:29 +0530
Message-ID: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:43569 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbaHAMPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 08:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 fixes a regression caused by a previous commit on net-next.
Old versions of BE3 FW may not support cmds to re-provision (and hence
optimize) resources/queues in SR-IOV config. Do not treat this FW cmd
failure as fatal and fail the function initialization. Instead, just
enable SR-IOV with the resources provided by the FW.

Patch 2 ignores a VF mac address setting if the new mac is already active
on the VF.

Patch 3 adds support to delete a FW-dump via ethtool on Lancer adapters.

Please consider applying this patch-set to the net-next tree. Thanks!

Kalesh AP (1):
  be2net: support deleting FW dump via ethtool (only for Lancer)

Sathya Perla (1):
  be2net: ignore get/set profile FW cmd failures

Vasundhara Volam (1):
  be2net: ignore VF mac address setting for the same mac

 drivers/net/ethernet/emulex/benet/be.h         |    2 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   48 ++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   10 +++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   17 +++---
 drivers/net/ethernet/emulex/benet/be_main.c    |   75 ++++++++++++++----------
 5 files changed, 109 insertions(+), 43 deletions(-)
