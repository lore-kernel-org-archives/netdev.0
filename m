From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/18] netfilter: Remove IP_CT_NEW_REPLY definition.
Date: Tue, 15 Mar 2016 02:27:54 +0100
Message-ID: <1458005282-24665-11-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33223 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933335AbcCOB2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 21:28:31 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 539A8114F5E
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 41822DA8F7
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 74D9FDA8F7
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:27 +0100 (CET)
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Remove the definition of IP_CT_NEW_REPLY from the kernel as it does
not make sense.  This allows the definition of IP_CT_NUMBER to be
simplified as well.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
