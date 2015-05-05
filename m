From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] mpls: Move reserved label definitions
Date: Tue, 5 May 2015 09:06:30 -0700
Message-ID: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <ebiederm@xmission.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50576 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2993189AbbEEQGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 12:06:43 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t45G6Ogf019850
	for <netdev@vger.kernel.org>; Tue, 5 May 2015 09:06:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u6kmesgmt-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 May 2015 09:06:42 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 b6e08ac8f34011e4a5670002c992ebde-638a31e0 for <netdev@vger.kernel.org>;	Tue,
 05 May 2015 09:06:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move to include/uapi/linux/mpls.h to be externally visibile.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/mpls.h | 10 ++++++++++
 net/mpls/af_mpls.c        | 18 +++++++++---------
 net/mpls/internal.h       | 10 ----------
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
index bc9abfe..0fe6ea5 100644
--- a/include/uapi/linux/mpls.h
+++ b/include/uapi/linux/mpls.h
@@ -31,4 +31,14 @@ struct mpls_label {
 #define MPLS_LS_TTL_MASK        0x000000FF
 #define MPLS_LS_TTL_SHIFT       0
 
+/* Reserved labels */
+#define MPLS_LABEL_IPV4_EXPLICIT_NULL	0 /* RFC3032 */
+#define MPLS_LABEL_ROUTER_ALERT		1 /* RFC3032 */
+#define MPLS_LABEL_IPV6_EXPLICIT_NULL	2 /* RFC3032 */
+#define MPLS_LABEL_IMPLICIT_NULL	3 /* RFC3032 */
+#define MPLS_LABEL_ENTROPY_INDICATOR	7 /* RFC6790 */
+#define MPLS_LABEL_GAL			13 /* RFC5586 */
+#define MPLS_LABEL_OAM_ALERT		14 /* RFC3429 */
+#define MPLS_LABEL_EXTENSION		15 /* RFC7274 */
+
 #endif /* _UAPI_MPLS_H */
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 954810c..b6eb761 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -647,7 +647,7 @@ int nla_get_labels(const struct nlattr *nla,
 			return -EINVAL;
 
 		switch (dec.label) {
-		case LABEL_IMPLICIT_NULL:
+		case MPLS_LABEL_IMPLICIT_NULL:
 			/* RFC3032: This is a label that an LSR may
 			 * assign and distribute, but which never
 			 * actually appears in the encapsulation.
@@ -935,7 +935,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	}
 
 	/* In case the predefined labels need to be populated */
-	if (limit > LABEL_IPV4_EXPLICIT_NULL) {
+	if (limit > MPLS_LABEL_IPV4_EXPLICIT_NULL) {
 		struct net_device *lo = net->loopback_dev;
 		rt0 = mpls_rt_alloc(lo->addr_len);
 		if (!rt0)
@@ -945,7 +945,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		rt0->rt_via_table = NEIGH_LINK_TABLE;
 		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
 	}
-	if (limit > LABEL_IPV6_EXPLICIT_NULL) {
+	if (limit > MPLS_LABEL_IPV6_EXPLICIT_NULL) {
 		struct net_device *lo = net->loopback_dev;
 		rt2 = mpls_rt_alloc(lo->addr_len);
 		if (!rt2)
@@ -973,15 +973,15 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	memcpy(labels, old, cp_size);
 
 	/* If needed set the predefined labels */
-	if ((old_limit <= LABEL_IPV6_EXPLICIT_NULL) &&
-	    (limit > LABEL_IPV6_EXPLICIT_NULL)) {
-		RCU_INIT_POINTER(labels[LABEL_IPV6_EXPLICIT_NULL], rt2);
+	if ((old_limit <= MPLS_LABEL_IPV6_EXPLICIT_NULL) &&
+	    (limit > MPLS_LABEL_IPV6_EXPLICIT_NULL)) {
+		RCU_INIT_POINTER(labels[MPLS_LABEL_IPV6_EXPLICIT_NULL], rt2);
 		rt2 = NULL;
 	}
 
-	if ((old_limit <= LABEL_IPV4_EXPLICIT_NULL) &&
-	    (limit > LABEL_IPV4_EXPLICIT_NULL)) {
-		RCU_INIT_POINTER(labels[LABEL_IPV4_EXPLICIT_NULL], rt0);
+	if ((old_limit <= MPLS_LABEL_IPV4_EXPLICIT_NULL) &&
+	    (limit > MPLS_LABEL_IPV4_EXPLICIT_NULL)) {
+		RCU_INIT_POINTER(labels[MPLS_LABEL_IPV4_EXPLICIT_NULL], rt0);
 		rt0 = NULL;
 	}
 
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 693877d..b064c34 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -1,16 +1,6 @@
 #ifndef MPLS_INTERNAL_H
 #define MPLS_INTERNAL_H
 
-#define LABEL_IPV4_EXPLICIT_NULL	0 /* RFC3032 */
-#define LABEL_ROUTER_ALERT_LABEL	1 /* RFC3032 */
-#define LABEL_IPV6_EXPLICIT_NULL	2 /* RFC3032 */
-#define LABEL_IMPLICIT_NULL		3 /* RFC3032 */
-#define LABEL_ENTROPY_INDICATOR		7 /* RFC6790 */
-#define LABEL_GAL			13 /* RFC5586 */
-#define LABEL_OAM_ALERT			14 /* RFC3429 */
-#define LABEL_EXTENSION			15 /* RFC7274 */
-
-
 struct mpls_shim_hdr {
 	__be32 label_stack_entry;
 };
-- 
1.8.1
