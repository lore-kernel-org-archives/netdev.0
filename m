From: akong@redhat.com
Subject: [PATCH] net: fix checking boundary of valid vlan id
Date: Sun, 30 Dec 2012 14:28:51 +0800
Message-ID: <1356848931-22193-1-git-send-email-akong@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328Ab2L3G26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2012 01:28:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amos Kong <akong@redhat.com>

4096 is not a valid vlan id.

Signed-off-by: Amos Kong <akong@redhat.com>
---
 net/bridge/netfilter/ebt_vlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index eae67bf..b279ec0 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -121,8 +121,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 	 * if_vlan.h: VLAN_N_VID 4096. */
 	if (GET_BITMASK(EBT_VLAN_ID)) {
 		if (!!info->id) { /* if id!=0 => check vid range */
-			if (info->id > VLAN_N_VID) {
-				pr_debug("id %d is out of range (1-4096)\n",
+			if (info->id >= VLAN_N_VID) {
+				pr_debug("id %d is out of range (1-4095)\n",
 					 info->id);
 				return -EINVAL;
 			}
-- 
1.7.11.7
