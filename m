From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH nf-next v10 1/8] netfilter: Remove IP_CT_NEW_REPLY definition.
Date: Thu, 10 Mar 2016 10:54:16 -0800
Message-ID: <1457636063-92746-2-git-send-email-jarno@ovn.org>
References: <1457636063-92746-1-git-send-email-jarno@ovn.org>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:49864 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbcCJSyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 13:54:51 -0500
In-Reply-To: <1457636063-92746-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the definition of IP_CT_NEW_REPLY from the kernel as it does
not make sense.  This allows the definition of IP_CT_NUMBER to be
simplified as well.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 include/uapi/linux/netfilter/nf_conntrack_common.h | 12 +++++++++---
 net/openvswitch/conntrack.c                        |  2 --
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 319f471..6d074d1 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -20,9 +20,15 @@ enum ip_conntrack_info {
 
 	IP_CT_ESTABLISHED_REPLY = IP_CT_ESTABLISHED + IP_CT_IS_REPLY,
 	IP_CT_RELATED_REPLY = IP_CT_RELATED + IP_CT_IS_REPLY,
-	IP_CT_NEW_REPLY = IP_CT_NEW + IP_CT_IS_REPLY,	
-	/* Number of distinct IP_CT types (no NEW in reply dirn). */
-	IP_CT_NUMBER = IP_CT_IS_REPLY * 2 - 1
+	/* No NEW in reply direction. */
+
+	/* Number of distinct IP_CT types. */
+	IP_CT_NUMBER,
+
+	/* only for userspace compatibility */
+#ifndef __KERNEL__
+	IP_CT_NEW_REPLY = IP_CT_NUMBER,
+#endif
 };
 
 #define NF_CT_STATE_INVALID_BIT			(1 << 0)
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index ee6ff8f..3045290 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -75,7 +75,6 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 	switch (ctinfo) {
 	case IP_CT_ESTABLISHED_REPLY:
 	case IP_CT_RELATED_REPLY:
-	case IP_CT_NEW_REPLY:
 		ct_state |= OVS_CS_F_REPLY_DIR;
 		break;
 	default:
@@ -92,7 +91,6 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 		ct_state |= OVS_CS_F_RELATED;
 		break;
 	case IP_CT_NEW:
-	case IP_CT_NEW_REPLY:
 		ct_state |= OVS_CS_F_NEW;
 		break;
 	default:
-- 
2.1.4
