From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 2/4]: mirred: convert jiffie values to USER_HZ when dumping
Date: Fri, 05 Nov 2004 00:25:25 +0100
Message-ID: <418ABA65.3090601@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050909090204030802000404"
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050909090204030802000404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Convert jiffie values to USER_HZ in mirred action.



--------------050909090204030802000404
Content-Type: text/x-patch;
 name="2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/04 20:21:35+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: mirred: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2004/11/04 20:21:29+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: mirred: convert jiffie values to USER_HZ when dumping
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2004-11-05 00:18:51 +01:00
+++ b/net/sched/mirred.c	2004-11-05 00:18:51 +01:00
@@ -257,9 +257,9 @@
 	opt.ifindex = p->ifindex;
 	DPRINTK(" tcf_mirred_dump index %d action %d eaction %d ifndex %d\n",p->index,p->action,p->eaction,p->ifindex);
 	RTA_PUT(skb, TCA_MIRRED_PARMS, sizeof (opt), &opt);
-	t.install = jiffies - p->tm.install;
-	t.lastuse = jiffies - p->tm.lastuse;
-	t.expires = p->tm.expires;
+	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tm.expires);
 	RTA_PUT(skb, TCA_MIRRED_TM, sizeof (t), &t);
 	return skb->len;
 

--------------050909090204030802000404--
