From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69++] fixup for latest netdev change.
Date: Tue, 20 May 2003 11:23:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520112355.6d40d98b.shemminger@osdl.org>
References: <20030519.212814.26529040.davem@redhat.com>
	<20030520050238.D5BEF2C208@lists.samba.org>
	<20030519.232133.45877480.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030519.232133.45877480.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One driver was setting owner directly, so won't build now.
This should fix it.

diff -urNp -X dontdiff linux-2.5/drivers/net/ns83820.c linux-2.5-sysfs/drivers/net/ns83820.c
--- linux-2.5/drivers/net/ns83820.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/ns83820.c	2003-05-20 11:15:01.000000000 -0700
@@ -1788,7 +1788,7 @@ static int __devinit ns83820_init_one(st
 
 	dev->ee.cache = &dev->MEAR_cache;
 	dev->ee.lock = &dev->misc_lock;
-	dev->net_dev.owner = THIS_MODULE;
+	SET_MODULE_OWNER(dev->net_dev);
 	dev->net_dev.priv = dev;
 
 	INIT_WORK(&dev->tq_refill, queue_refill, dev);
