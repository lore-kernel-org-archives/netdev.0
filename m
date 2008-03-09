From: Joe Perches <joe@perches.com>
Subject: [PATCH] include/linux/igmp.h - remove duplicate include
Date: Sun, 09 Mar 2008 16:55:40 -0700
Message-ID: <1205106940.656.103.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755879AbYCIX5Q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed duplicate #include <linux/skbuff.h>	
Combined #ifdef __KERNEL__ blocks

Signed-off-by: Joe Perches <joe@perches.com>

 include/linux/igmp.h |   38 +++++++++++++++++---------------------
 1 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f510e7e..f5a1a0d 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -80,27 +80,6 @@ struct igmpv3_query {
 	__be32 srcs[0];
 };
 
-#ifdef __KERNEL__
-#include <linux/skbuff.h>
-
-static inline struct igmphdr *igmp_hdr(const struct sk_buff *skb)
-{
-	return (struct igmphdr *)skb_transport_header(skb);
-}
-
-static inline struct igmpv3_report *
-			igmpv3_report_hdr(const struct sk_buff *skb)
-{
-	return (struct igmpv3_report *)skb_transport_header(skb);
-}
-
-static inline struct igmpv3_query *
-			igmpv3_query_hdr(const struct sk_buff *skb)
-{
-	return (struct igmpv3_query *)skb_transport_header(skb);
-}
-#endif
-
 #define IGMP_HOST_MEMBERSHIP_QUERY	0x11	/* From RFC1112 */
 #define IGMP_HOST_MEMBERSHIP_REPORT	0x12	/* Ditto */
 #define IGMP_DVMRP			0x13	/* DVMRP routing */
@@ -151,6 +130,23 @@ static inline struct igmpv3_query *
 #include <linux/timer.h>
 #include <linux/in.h>
 
+static inline struct igmphdr *igmp_hdr(const struct sk_buff *skb)
+{
+	return (struct igmphdr *)skb_transport_header(skb);
+}
+
+static inline struct igmpv3_report *
+			igmpv3_report_hdr(const struct sk_buff *skb)
+{
+	return (struct igmpv3_report *)skb_transport_header(skb);
+}
+
+static inline struct igmpv3_query *
+			igmpv3_query_hdr(const struct sk_buff *skb)
+{
+	return (struct igmpv3_query *)skb_transport_header(skb);
+}
+
 extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
 
