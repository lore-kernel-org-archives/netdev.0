From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 PKT_SCHED]: Fix overflow on 64bit in times reported to
 userspace by tc actions
Date: Tue, 09 Nov 2004 10:25:49 +0100
Message-ID: <41908D1D.50405@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002060207010401000005"
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090002060207010401000005
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes on overflow in tc actions times reported to
userspace on 64 bit architectures. struct tcf_t only contains
32-bit timestamps, but they are initialized to jiffies. When
jiffies is larger than 2^32-1 only the low 32 bit are saved,
and the diff between jiffies and the current timestamp becomes
very large. This happens immediately after boottime since jiffies
is initialized to 2^32-300. It was invisible until now because
only the lower 32bit were reported to userspace, but with the
USER_HZ conversion the reported times start somewhere around
4294967s.

This patch extends the timestamps to 64bit. It breaks userspace
compatibility for actions, but considering that most of this is
not even in iproute yet this should be acceptable.

Regards
Patrick


--------------090002060207010401000005
Content-Type: text/plain;
 name="y"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="y"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/09 09:30:28+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix overflow on 64bit in times reported to userspace by tc actions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/linux/pkt_cls.h
#   2004/11/09 09:30:21+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: Fix overflow on 64bit in times reported to userspace by tc actions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
--- a/include/linux/pkt_cls.h	2004-11-09 09:31:44 +01:00
+++ b/include/linux/pkt_cls.h	2004-11-09 09:31:44 +01:00
@@ -138,9 +138,9 @@
 
 struct tcf_t
 {
-	__u32   install;
-	__u32   lastuse;
-	__u32   expires;
+	__u64   install;
+	__u64   lastuse;
+	__u64   expires;
 };
 
 struct tc_cnt

--------------090002060207010401000005--
