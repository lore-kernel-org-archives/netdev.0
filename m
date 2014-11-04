From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] igmp: remove camel case definitions
Date: Tue,  4 Nov 2014 20:52:14 +0100
Message-ID: <1415130734-17124-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use standard uppercase for definitions

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/igmp.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index fb70e3e..3f80513 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -112,17 +112,17 @@
 #ifdef CONFIG_IP_MULTICAST
 /* Parameter names and values are taken from igmp-v2-06 draft */
 
-#define IGMP_V1_Router_Present_Timeout		(400*HZ)
-#define IGMP_V2_Router_Present_Timeout		(400*HZ)
-#define IGMP_V2_Unsolicited_Report_Interval	(10*HZ)
-#define IGMP_V3_Unsolicited_Report_Interval	(1*HZ)
-#define IGMP_Query_Response_Interval		(10*HZ)
-#define IGMP_Query_Robustness_Variable		2
+#define IGMP_V1_ROUTER_PRESENT_TIMEOUT		(400*HZ)
+#define IGMP_V2_ROUTER_PRESENT_TIMEOUT		(400*HZ)
+#define IGMP_V2_UNSOLICITED_REPORT_INTERVAL	(10*HZ)
+#define IGMP_V3_UNSOLICITED_REPORT_INTERVAL	(1*HZ)
+#define IGMP_QUERY_RESPONSE_INTERVAL		(10*HZ)
+#define IGMP_QUERY_ROBUSTNESS_VARIABLE		2
 
 
-#define IGMP_Initial_Report_Delay		(1)
+#define IGMP_INITIAL_REPORT_DELAY		(1)
 
-/* IGMP_Initial_Report_Delay is not from IGMP specs!
+/* IGMP_INITIAL_REPORT_DELAY is not from IGMP specs!
  * IGMP specs require to report membership immediately after
  * joining a group, but we delay the first report by a
  * small interval. It seems more natural and still does not
@@ -879,15 +879,15 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 		if (ih->code == 0) {
 			/* Alas, old v1 router presents here. */
 
-			max_delay = IGMP_Query_Response_Interval;
+			max_delay = IGMP_QUERY_RESPONSE_INTERVAL;
 			in_dev->mr_v1_seen = jiffies +
-				IGMP_V1_Router_Present_Timeout;
+				IGMP_V1_ROUTER_PRESENT_TIMEOUT;
 			group = 0;
 		} else {
 			/* v2 router present */
 			max_delay = ih->code*(HZ/IGMP_TIMER_SCALE);
 			in_dev->mr_v2_seen = jiffies +
-				IGMP_V2_Router_Present_Timeout;
+				IGMP_V2_ROUTER_PRESENT_TIMEOUT;
 		}
 		/* cancel the interface change timer */
 		in_dev->mr_ifc_count = 0;
@@ -899,7 +899,7 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 		return true;	/* ignore bogus packet; freed by caller */
 	} else if (IGMP_V1_SEEN(in_dev)) {
 		/* This is a v3 query with v1 queriers present */
-		max_delay = IGMP_Query_Response_Interval;
+		max_delay = IGMP_QUERY_RESPONSE_INTERVAL;
 		group = 0;
 	} else if (IGMP_V2_SEEN(in_dev)) {
 		/* this is a v3 query with v2 queriers present;
@@ -1218,7 +1218,7 @@ static void igmp_group_added(struct ip_mc_list *im)
 		return;
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
 		spin_lock_bh(&im->lock);
-		igmp_start_timer(im, IGMP_Initial_Report_Delay);
+		igmp_start_timer(im, IGMP_INITIAL_REPORT_DELAY);
 		spin_unlock_bh(&im->lock);
 		return;
 	}
@@ -1541,7 +1541,7 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 int sysctl_igmp_max_memberships __read_mostly = IP_MAX_MEMBERSHIPS;
 int sysctl_igmp_max_msf __read_mostly = IP_MAX_MSF;
 #ifdef CONFIG_IP_MULTICAST
-int sysctl_igmp_qrv __read_mostly = IGMP_Query_Robustness_Variable;
+int sysctl_igmp_qrv __read_mostly = IGMP_QUERY_ROBUSTNESS_VARIABLE;
 #endif
 
 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
-- 
1.9.3
