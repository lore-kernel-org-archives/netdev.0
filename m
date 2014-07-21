From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v6 06/11] openvswitch: Fix key size computation in key_attr_size()
Date: Sun, 20 Jul 2014 23:17:28 -0700
Message-ID: <1405923448-2029-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:34590 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753218AbaGUGRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 02:17:30 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so8508049pdb.24
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 23:17:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

The key_attr_size() was not updated when RECIRC_ID and DP_HASH
key fields are added to support recircualtion. This patch fixes it.

Reported-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ae1a5bf..529ec1a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -376,6 +376,11 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 
 static size_t key_attr_size(void)
 {
+	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
+	 * updating this function.
+	 */
+	BUILD_BUG_ON(OVS_KEY_ATTR_IPV4_TUNNEL != 21);
+
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
 		  + nla_total_size(8)   /* OVS_TUNNEL_KEY_ATTR_ID */
@@ -387,6 +392,8 @@ static size_t key_attr_size(void)
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_8021Q */
-- 
1.9.3
