From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 16/22]: ipt action: fix missing unlock on error
 path
Date: Mon, 10 Jan 2005 20:38:10 +0100
Message-ID: <41E2D9A2.305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080703090404030106050201"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080703090404030106050201
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------080703090404030106050201
Content-Type: text/x-patch;
 name="16.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="16.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 02:54:57+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: ipt action: fix missing unlock on error path
#   
#   Simply kill the pskb_expand_head, iptables targets already take care
#   of cloned packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2005/01/10 02:50:16+01:00 kaber@coreworks.de +0 -4
#   [PKT_SCHED]: ipt_action: fix missing unlock on error path
#   
#   Simply kill the pskb_expand_head, iptables targets already take care
#   of cloned packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2005-01-10 06:22:53 +01:00
+++ b/net/sched/ipt.c	2005-01-10 06:22:53 +01:00
@@ -202,10 +202,6 @@
 	p->bstats.bytes += skb->len;
 	p->bstats.packets++;
 
-	if (skb_cloned(skb) ) {
-		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-			return -1;
-	}
 	/* yes, we have to worry about both in and out dev
 	 worry later - danger - this API seems to have changed
 	 from earlier kernels */

--------------080703090404030106050201--
