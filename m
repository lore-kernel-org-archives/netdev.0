From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.{4,x5}.x] mod_timer cleanups for dst.c
Date: 04 May 2003 14:55:34 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1052040334.1119.71.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Just reposting what I earlier posted to the linux-kernel mailing list.
These are trivial patches converting {del,add}_timer to mod_timer.

Also kindly let me know whether this is the right platform to post the
PPP & FR related fixes or to linux-x25 mailing list.

vinay

PS: I am not subscribed to this mailing list

--- linux-2.5.68/net/core/dst.c	2003-03-25 10:08:35.000000000 +0530
+++ linux-2.5.68-mod/net/core/dst.c	2003-05-03 13:42:12.000000000 +0530
@@ -154,11 +154,9 @@
 	dst->next = dst_garbage_list;
 	dst_garbage_list = dst;
 	if (dst_gc_timer_inc > DST_GC_INC) {
-		del_timer(&dst_gc_timer);
 		dst_gc_timer_inc = DST_GC_INC;
 		dst_gc_timer_expires = DST_GC_MIN;
-		dst_gc_timer.expires = jiffies + dst_gc_timer_expires;
-		add_timer(&dst_gc_timer);
+		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
 	}
 	spin_unlock_bh(&dst_lock);
 }
