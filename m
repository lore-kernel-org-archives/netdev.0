From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 3/4]: gact: convert jiffie values to USER_HZ when dumping
Date: Fri, 05 Nov 2004 00:25:28 +0100
Message-ID: <418ABA68.4040100@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010902060007020400060401"
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010902060007020400060401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Convert jiffie values to USER_HZ in gact action.



--------------010902060007020400060401
Content-Type: text/x-patch;
 name="3.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/04 20:22:38+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: gact: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2004/11/04 20:22:32+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: gact: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2004-11-05 00:18:57 +01:00
+++ b/net/sched/gact.c	2004-11-05 00:18:57 +01:00
@@ -203,9 +203,9 @@
 		RTA_PUT(skb, TCA_GACT_PROB, sizeof (p_opt), &p_opt);
 	} 
 #endif
-	t.install = jiffies - p->tm.install;
-	t.lastuse = jiffies - p->tm.lastuse;
-	t.expires = p->tm.expires;
+	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tm.expires);
 	RTA_PUT(skb, TCA_GACT_TM, sizeof (t), &t);
 	return skb->len;
 

--------------010902060007020400060401--
