From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/6] be2net: fix pmac_id for BE3 VFs
Date: Tue, 23 Jul 2013 15:25:01 +0530
Message-ID: <1374573304-6865-4-git-send-email-sathya.perla@emulex.com>
References: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:49012 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977Ab3GWJvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 05:51:50 -0400
In-Reply-To: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For BE3 VFs, the permanent MAC is added by its PF. The VF can retrieve its
pmac_id only via the IFACE_CREATE cmd. This is not true for Lancer and SH-R
VFs which get the pmac_id by issuing a ADD_IFACE_MAC cmd. So, use this
hack only for BE3 VFs.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 5d37601..b384ae7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1339,6 +1339,10 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 	if (!status) {
 		struct be_cmd_resp_if_create *resp = embedded_payload(wrb);
 		*if_handle = le32_to_cpu(resp->interface_id);
+
+		/* Hack to retrieve VF's pmac-id on BE3 */
+		if (BE3_chip(adapter) && !be_physfn(adapter))
+			adapter->pmac_id[0] = le32_to_cpu(resp->pmac_id);
 	}
 
 err:
-- 
1.7.1
