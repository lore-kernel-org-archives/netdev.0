From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] phonet: sparse annotations of protocol, remove forward
 declaration
Date: Thu, 06 Nov 2008 17:53:13 -0800
Message-ID: <1226022793.5482.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:55997 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbYKGBxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 20:53:16 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1065800rvb.1
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2008 17:53:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/phonet/af_phonet.c:38:36: error: marked inline, but without a definition
net/phonet/pep-gprs.c:63:10: warning: incorrect type in return expression (different base types)
net/phonet/pep-gprs.c:63:10:    expected int
net/phonet/pep-gprs.c:63:10:    got restricted __be16 [usertype] <noident>
net/phonet/pep-gprs.c:65:10: warning: incorrect type in return expression (different base types)
net/phonet/pep-gprs.c:65:10:    expected int
net/phonet/pep-gprs.c:65:10:    got restricted __be16 [usertype] <noident>
net/phonet/pep-gprs.c:124:16: warning: incorrect type in assignment (different base types)
net/phonet/pep-gprs.c:124:16:    expected restricted __be16 [usertype] protocol
net/phonet/pep-gprs.c:124:16:    got unsigned short [unsigned] [usertype] protocol

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/phonet/af_phonet.c |   11 +++++------
 net/phonet/pep-gprs.c  |    8 ++++----
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index defeb7a..f400ff1 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -35,7 +35,11 @@
 
 static struct net_proto_family phonet_proto_family;
 static struct phonet_protocol *phonet_proto_get(int protocol);
-static inline void phonet_proto_put(struct phonet_protocol *pp);
+
+static inline void phonet_proto_put(struct phonet_protocol *pp)
+{
+	module_put(pp->prot->owner);
+}
 
 /* protocol family functions */
 
@@ -428,11 +432,6 @@ static struct phonet_protocol *phonet_proto_get(int protocol)
 	return pp;
 }
 
-static inline void phonet_proto_put(struct phonet_protocol *pp)
-{
-	module_put(pp->prot->owner);
-}
-
 /* Module registration */
 static int __init phonet_init(void)
 {
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 9978afb..a432407 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -49,14 +49,14 @@ struct gprs_dev {
 	unsigned		tx_max;
 };
 
-static int gprs_type_trans(struct sk_buff *skb)
+static __be16 gprs_type_trans(struct sk_buff *skb)
 {
 	const u8 *pvfc;
 	u8 buf;
 
 	pvfc = skb_header_pointer(skb, 0, 1, &buf);
 	if (!pvfc)
-		return 0;
+		return htons(0);
 	/* Look at IP version field */
 	switch (*pvfc >> 4) {
 	case 4:
@@ -64,7 +64,7 @@ static int gprs_type_trans(struct sk_buff *skb)
 	case 6:
 		return htons(ETH_P_IPV6);
 	}
-	return 0;
+	return htons(0);
 }
 
 /*
@@ -84,7 +84,7 @@ static void gprs_state_change(struct sock *sk)
 static int gprs_recv(struct gprs_dev *dev, struct sk_buff *skb)
 {
 	int err = 0;
-	u16 protocol = gprs_type_trans(skb);
+	__be16 protocol = gprs_type_trans(skb);
 
 	if (!protocol) {
 		err = -EINVAL;
-- 
1.6.0.3.756.gb776d



