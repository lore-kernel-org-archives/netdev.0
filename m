From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: fix unbalances spin_unlock_bh in __xfrm_find_acq_byseq
Date: Thu, 23 Sep 2004 06:10:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41524CC8.1070104@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020503090501010701010107"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020503090501010701010107
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an unbalanced spin_unlock_bh in
__xfrm_find_acq_byseq left over from the larval
state SA fix.

Regards
Patrick

--------------020503090501010701010107
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 06:05:52+02:00 kaber@coreworks.de 
#   [XFRM]: Fix unbalanced spin_unlock_bh
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_state.c
#   2004/09/23 06:05:25+02:00 kaber@coreworks.de +0 -1
#   [XFRM]: Fix unbalanced spin_unlock_bh
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2004-09-23 06:07:23 +02:00
+++ b/net/xfrm/xfrm_state.c	2004-09-23 06:07:23 +02:00
@@ -592,7 +592,6 @@
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
 			if (x->km.seq == seq) {
 				xfrm_state_hold(x);
-				spin_unlock_bh(&xfrm_state_lock);
 				return x;
 			}
 		}

--------------020503090501010701010107--
