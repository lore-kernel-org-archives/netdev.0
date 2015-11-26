From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 5/7] net: ipmr: move pimsm_enabled to pim.h and rename
Date: Thu, 26 Nov 2015 15:23:48 +0100
Message-ID: <1448547830-21716-6-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38516 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbbKZOYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:06 -0500
Received: by wmec201 with SMTP id c201so24531450wme.1
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:05 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Move the inline pimsm_enabled() to pim.h and rename it to
ipmr_pimsm_enabled to show it's for the ipv4 ipmr code since pim.h is
used by IPv6 too.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/pim.h |  5 +++++
 net/ipv4/ipmr.c     | 11 +++--------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/pim.h b/include/linux/pim.h
index 252bf6644c51..e1d756f81348 100644
--- a/include/linux/pim.h
+++ b/include/linux/pim.h
@@ -13,6 +13,11 @@
 
 #define PIM_NULL_REGISTER	cpu_to_be32(0x40000000)
 
+static inline bool ipmr_pimsm_enabled(void)
+{
+	return IS_BUILTIN(CONFIG_IP_PIMSM_V1) || IS_BUILTIN(CONFIG_IP_PIMSM_V2);
+}
+
 /* PIMv2 register message header layout (ietf-draft-idmr-pimvsm-v2-00.ps */
 struct pimreghdr
 {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ff3dbbb9f11c..322fdc6ac75b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -75,11 +75,6 @@ struct ipmr_result {
 	struct mr_table		*mrt;
 };
 
-static inline bool pimsm_enabled(void)
-{
-	return IS_BUILTIN(CONFIG_IP_PIMSM_V1) || IS_BUILTIN(CONFIG_IP_PIMSM_V2);
-}
-
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
  * Note that the changes are semaphored via rtnl_lock.
  */
@@ -751,7 +746,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 
 	switch (vifc->vifc_flags) {
 	case VIFF_REGISTER:
-		if (!pimsm_enabled())
+		if (!ipmr_pimsm_enabled())
 			return -EINVAL;
 		/* Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
@@ -1377,7 +1372,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 		mrt->mroute_do_assert = val;
 		break;
 	case MRT_PIM:
-		if (!pimsm_enabled()) {
+		if (!ipmr_pimsm_enabled()) {
 			ret = -ENOPROTOOPT;
 			break;
 		}
@@ -1451,7 +1446,7 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 		val = 0x0305;
 		break;
 	case MRT_PIM:
-		if (!pimsm_enabled())
+		if (!ipmr_pimsm_enabled())
 			return -ENOPROTOOPT;
 		val = mrt->mroute_do_pim;
 		break;
-- 
2.4.3
