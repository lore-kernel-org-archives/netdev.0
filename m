From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 17/17]: Disable broken override bits in pedit action
Date: Thu, 30 Dec 2004 04:41:51 +0100
Message-ID: <41D378FF.3080205@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020300080003090501060808"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020300080003090501060808
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Disable broken override bits in pedit action. It misses
locking and needs to allocate new memory if nkeys increases.
Also disable it for now.


--------------020300080003090501060808
Content-Type: text/x-patch;
 name="17.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="17.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 03:56:27+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Disable broken override bits in pedit action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2004/12/30 03:56:20+01:00 kaber@coreworks.de +2 -0
#   [PKT_SCHED]: Disable broken override bits in pedit action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2004-12-30 04:02:10 +01:00
+++ b/net/sched/pedit.c	2004-12-30 04:02:10 +01:00
@@ -83,6 +83,8 @@
 
 	ret = -EEXIST;
 	if (ovr) {
+		/* FIXME: no locking, larger memory area might be required */
+		return -EOPNOTSUPP;
 		ret = 0;
 override:
 		p->flags = parm->flags;

--------------020300080003090501060808--
