From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 06/11] openvswitch: Fix key size computation in key_attr_size()
Date: Wed, 16 Jul 2014 17:18:40 -0700
Message-ID: <1405556320-1827-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:33337 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753720AbaGQAS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 20:18:56 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so2068544pdj.22
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 17:18:55 -0700 (PDT)
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
index 911f192..995dfa1 100644
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
