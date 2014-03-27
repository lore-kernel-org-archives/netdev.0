From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next v4 0/2] be2net: add vxlan offload support
Date: Thu, 27 Mar 2014 10:46:17 +0530
Message-ID: <1395897379-29141-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:27670 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaC0FM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 01:12:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch adds the FW cmds needed to configure the Skyhawk-R
chip for supporting VxLAN offloads. The second patch implements the
ndo_add/del_vxlan_port() methods and the plumbing for supporting
RX/TX csum, TSO and RSS steering offloads for VxLAN traffic.

v2 changes:
NETIF_F_SG need not be set for hw_enc_features by the driver as it is
done by the stack.

v3 changes:
* Defer FW cmds needed for VxLAN offloads to a workqueue
* Reset FW to VxLAN offloads disabled state in the unload path

v4 changes:
* Revert the usage of workqueue (introduced in v3) to implement
ndo_add/del_vxlan_port() as it is currently not needed (none of the
FW cmd calls sleep.) Suggested by David M.

Pls apply. Thanks.

Sathya Perla (2):
  be2net: add FW cmds needed for VxLAN offloads
  be2net: csum, tso and rss steering offload support for VxLAN

 drivers/net/ethernet/emulex/benet/be.h      |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |  135 ++++++++++++++++++++-------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   69 ++++++++++----
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  132 ++++++++++++++++++++++++---
 5 files changed, 279 insertions(+), 67 deletions(-)
