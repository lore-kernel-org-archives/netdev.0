From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 3/4]: cls_route: fix tcf_exts fallout
Date: Wed, 19 Jan 2005 05:38:46 +0100
Message-ID: <41EDE456.3050600@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080206020809050403010709"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080206020809050403010709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------080206020809050403010709
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/19 04:53:51+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: cls_route: fix tcf_exts fallout
#   
#   handle is computed wrong, this makes creating a filter not using
#   "from" fail.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_route.c
#   2005/01/19 04:53:43+01:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: cls_route: fix tcf_exts fallout
#   
#   handle is computed wrong, this makes creating a filter not using
#   "from" fail.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_route.c b/net/sched/cls_route.c
--- a/net/sched/cls_route.c	2005-01-19 05:29:55 +01:00
+++ b/net/sched/cls_route.c	2005-01-19 05:29:55 +01:00
@@ -384,9 +384,9 @@
 		id = *(u32*)RTA_DATA(tb[TCA_ROUTE4_IIF-1]);
 		if (id > 0x7FFF)
 			goto errout;
-		nhandle = (id | 0x8000) << 16;
+		nhandle |= (id | 0x8000) << 16;
 	} else
-		nhandle = 0xFFFF << 16;
+		nhandle |= 0xFFFF << 16;
 
 	if (handle && new) {
 		nhandle |= handle & 0x7F00;

--------------080206020809050403010709--
