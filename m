From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Fix device leaks in mirred action
Date: Thu, 04 Nov 2004 07:30:02 +0100
Message-ID: <4189CC6A.9040007@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060200070306030602060705"
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060200070306030602060705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

When a mirred action is created it takes two references to the
device (dev_get_by_index + dev_hold), but only drops one when
it gets destroyed. It also leaks a reference when a mirred action
is replaced.



--------------060200070306030602060705
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/04 07:28:30+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix device leaks in mirred action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2004/11/04 07:28:24+01:00 kaber@coreworks.de +2 -1
#   [PKT_SCHED]: Fix device leaks in mirred action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2004-11-04 07:28:59 +01:00
+++ b/net/sched/mirred.c	2004-11-04 07:28:59 +01:00
@@ -138,8 +138,9 @@
 		p->eaction = parm->eaction;
 		if (parm->ifindex) {
 			p->ifindex = parm->ifindex;
+			if (ovr)
+				dev_put(p->dev);
 			p->dev = dev;
-			dev_hold(p->dev); 
 		}
 		spin_unlock(&p->lock);
 	}

--------------060200070306030602060705--
