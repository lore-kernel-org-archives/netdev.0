From: "Paul Rolland" <rol@as2917.net>
Subject: Re: [BUG]:   problem when shutting down ppp connection since 2.5.70
Date: Mon, 14 Jul 2003 13:43:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <018201c349fd$330a6a60$2101a8c0@witbe>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-ppp@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Paul Rolland'" <rol@as2917.net>,
   "'Stephen Hemminger'" <shemminger@osdl.org>, <cfriesen@nortelnetworks.com>,
   <paulus@samba.org>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm sorry, the patch was not complete, it should have considered the
BUG_ON too...

Here is one that is fine on my system :
--- dev.c.orig  2003-07-14 13:41:33.000000000 +0200
+++ dev.c       2003-07-14 13:34:27.000000000 +0200
@@ -2742,7 +2742,7 @@
        unsigned long rebroadcast_time, warning_time;
 
        rebroadcast_time = warning_time = jiffies;
-       while (atomic_read(&dev->refcnt) != 0) {
+       while (atomic_read(&dev->refcnt) > 0) {
                if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
                        rtnl_shlock();
                        rtnl_exlock();
@@ -2836,7 +2836,7 @@
                        dev->reg_state = NETREG_UNREGISTERED;
 
                        netdev_wait_allrefs(dev);
-                       BUG_ON(atomic_read(&dev->refcnt));
+                       BUG_ON(atomic_read(&dev->refcnt) > 0);
 
                        netdev_finish_unregister(dev);
                        break;

Still don't understand why refcnt is really bad (negative value),
but at least the machine is working...

Paul

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
I have a vitally important role serving as a bad example.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
