From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 4/4]: ipt: convert jiffie values to USER_HZ when dumping
Date: Fri, 05 Nov 2004 00:25:32 +0100
Message-ID: <418ABA6C.8060402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050509080902080304040906"
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050509080902080304040906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Convert jiffie values to USER_HZ in ipt action.



--------------050509080902080304040906
Content-Type: text/x-patch;
 name="4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/05 00:17:18+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: ipt: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2004/11/05 00:17:10+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: ipt: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2004-11-05 00:19:01 +01:00
+++ b/net/sched/ipt.c	2004-11-05 00:19:01 +01:00
@@ -334,9 +334,9 @@
 	RTA_PUT(skb, TCA_IPT_HOOK, 4, &p->hook);
 	RTA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
 	RTA_PUT(skb, TCA_IPT_TABLE, IFNAMSIZ, p->tname);
-	tm.install = jiffies - p->tm.install;
-	tm.lastuse = jiffies - p->tm.lastuse;
-	tm.expires = p->tm.expires;
+	tm.install = jiffies_to_clock_t(jiffies - p->tm.install);
+	tm.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
+	tm.expires = jiffies_to_clock_t(p->tm.expires);
 	RTA_PUT(skb, TCA_IPT_TM, sizeof (tm), &tm);
 	return skb->len;
 

--------------050509080902080304040906--
