From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 1/4]: pedit: convert jiffie values to USER_HZ when dumping
Date: Fri, 05 Nov 2004 00:25:14 +0100
Message-ID: <418ABA5A.70800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020803060501050404010200"
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020803060501050404010200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Convert jiffie values to USER_HZ in pedit action.



--------------020803060501050404010200
Content-Type: text/x-patch;
 name="1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="1.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/04 20:18:34+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: pedit: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2004/11/04 20:18:27+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: pedit: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2004-11-05 00:18:46 +01:00
+++ b/net/sched/pedit.c	2004-11-05 00:18:46 +01:00
@@ -244,9 +244,9 @@
 #endif
 
 	RTA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
-	t.install = jiffies - p->tm.install;
-	t.lastuse = jiffies - p->tm.lastuse;
-	t.expires = p->tm.expires;
+	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tm.expires);
 	RTA_PUT(skb, TCA_PEDIT_TM, sizeof (t), &t);
 	return skb->len;
 

--------------020803060501050404010200--
