From: "Josef 'Jeff' Sipek" <jeffpc@optonline.net>
Subject: Re: [PATCH 2.6] watch64: generic variable monitoring system
Date: Fri, 03 Sep 2004 16:40:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409031640.30731.jeffpc@optonline.net>
References: <200409031307.01240.jeffpc@optonline.net>
 <20040903121657.355a6a8b@dell_ss3.pdx.osdl.net>
 <200409031618.47521.jeffpc@optonline.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <200409031618.47521.jeffpc@optonline.net>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following fixes watch64 patch previously submitted to follow CodingStyle
guidelines. BK repo is up to date as well

Jeff.

Signed-off-by: Josef "Jeff" Sipek <jeffpc@optonline.net>


--- 1.7/kernel/watch64.c 2004-07-14 16:41:26 -04:00
+++ edited/watch64.c 2004-09-03 16:12:39 -04:00
@@ -110,7 +110,8 @@
   return;
  }
  
- printk(KERN_WARNING "watch64: 2003/08/22 Josef 'Jeff' Sipek <jeffpc@optonline.net>\n");
+ printk(KERN_WARNING "watch64: 2003/08/22 Josef 'Jeff' Sipek "
+     "<jeffpc@optonline.net>\n");
  printk(KERN_WARNING "watch64: Enabling Watch64 extensions...");
 
  init_timer(&watch64_timer);
@@ -139,19 +140,21 @@
  rcu_read_lock();
  list_for_each_rcu(entry, &watch64_head) {
   watch_struct = list_entry(entry, struct watch64, list);
-  if (*watch_struct->ptr != watch_struct->oldval) {
-   tmp = *watch_struct->ptr;
-   if (tmp > watch_struct->oldval) {
-    write_seqlock(&watch_struct->lock);
-    watch_struct->total += tmp - watch_struct->oldval;
-    write_sequnlock(&watch_struct->lock);
-   } else if (tmp < watch_struct->oldval) {
-    write_seqlock(&watch_struct->lock);
-    watch_struct->total += ((u_int64_t) 1<<BITS_PER_LONG) - watch_struct->oldval + tmp;
-    write_sequnlock(&watch_struct->lock);
-   }
-   watch_struct->oldval = tmp;
+  if (*watch_struct->ptr == watch_struct->oldval)
+   continue;
+  
+  tmp = *watch_struct->ptr;
+  if (tmp > watch_struct->oldval) {
+   write_seqlock(&watch_struct->lock);
+   watch_struct->total += tmp - watch_struct->oldval;
+   write_sequnlock(&watch_struct->lock);
+  } else if (tmp < watch_struct->oldval) {
+   write_seqlock(&watch_struct->lock);
+   watch_struct->total += ((u_int64_t) 1<<BITS_PER_LONG)
+      - watch_struct->oldval + tmp;
+   write_sequnlock(&watch_struct->lock);
   }
+  watch_struct->oldval = tmp;
  }
  rcu_read_unlock();
  
@@ -181,7 +184,8 @@
   temp->interval = WATCH64_INTERVAL;
  else if (interval<WATCH64_MINIMUM) {
   temp->interval = WATCH64_MINIMUM;
-  printk("watch64: attempted to add new watch with interval below %d jiffies",WATCH64_MINIMUM);
+  printk("watch64: attempted to add new watch with "
+    "interval below %d jiffies",WATCH64_MINIMUM);
  } else
   temp->interval = interval;
 
