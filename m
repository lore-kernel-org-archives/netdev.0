From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 2/4]: cls_api.c: fix module reference leak on module
 load
Date: Wed, 19 Jan 2005 05:38:44 +0100
Message-ID: <41EDE454.5070004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050308090500020407000506"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050308090500020407000506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------050308090500020407000506
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/19 03:58:05+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: cls_api.c: fix module reference leak on module load
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2005/01/19 03:57:58+01:00 kaber@coreworks.de +3 -1
#   [PKT_SCHED]: cls_api.c: fix module reference leak on module load
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2005-01-19 05:29:50 +01:00
+++ b/net/sched/cls_api.c	2005-01-19 05:29:50 +01:00
@@ -239,8 +239,10 @@
 				 * replay the request.  We indicate this using
 				 * -EAGAIN.
 				 */
-				if (tp_ops != NULL)
+				if (tp_ops != NULL) {
+					module_put(tp_ops->owner);
 					err = -EAGAIN;
+				}
 			}
 #endif
 			kfree(tp);

--------------050308090500020407000506--
