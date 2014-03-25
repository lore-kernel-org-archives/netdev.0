From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next v3 0/2] be2net: add vxlan offload support
Date: Tue, 25 Mar 2014 19:20:28 +0530
Message-ID: <1395755430-17451-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:1563 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbaCYNqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:46:38 -0400
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

Pls apply. Thanks.

Sathya Perla (2):
  be2net: add FW cmds needed for VxLAN offloads
  be2net: csum, tso and rss steering offload support for VxLAN

 drivers/net/ethernet/emulex/benet/be.h      |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |  135 ++++++++++++++++++++-------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   69 ++++++++++----
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  130 +++++++++++++++++++++++---
 5 files changed, 277 insertions(+), 67 deletions(-)
