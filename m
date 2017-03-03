From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 6/7] bnx2x: fix incorrect filter count in an error message
Date: Fri,  3 Mar 2017 17:08:33 +0100
Message-ID: <20170303160834.4125-7-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdCCQIo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:44 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

filters->count is the number of filters we were supposed to configure.
There is no reason to increase it by +1 when printing the count in an error
message.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2068bb8f54..bdfd53b46b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -473,7 +473,7 @@ int bnx2x_vf_mac_vlan_config_list(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	/* Rollback if needed */
 	if (i != filters->count) {
 		BNX2X_ERR("Managed only %d/%d filters - rolling back\n",
-			  i, filters->count + 1);
+			  i, filters->count);
 		while (--i >= 0) {
 			if (!filters->filters[i].applied)
 				continue;
-- 
2.9.3
