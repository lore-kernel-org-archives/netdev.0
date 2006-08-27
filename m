From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an
 "eth" device name
Date: Sun, 27 Aug 2006 00:38:00 -0700 (PDT)
Message-ID: <20060827.003800.95504796.davem@davemloft.net>
References: <a44ae5cd0608270007gc6a919fx9e36562d8023635d@mail.gmail.com>
	<20060827001943.c559d37d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jeremy@goop.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751059AbWH0HiL@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20060827001943.c559d37d.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sun, 27 Aug 2006 00:19:43 -0700

> Jeremy reported that a while back too.  I do not know what is causing it
> and as far as I know no net developers have yet looked into it.

A debugging patch like this one should help figure out the culprit.

If we don't see the gibberish netdevice name printed in the kernel
logs, then likely something is corrupting the netdevice structure or
the memory holding the name.

diff --git a/net/core/dev.c b/net/core/dev.c
index d4a1ec3..45f9b19 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -738,6 +738,11 @@ int dev_change_name(struct net_device *d
 
 	if (!dev_valid_name(newname))
 		return -EINVAL;
+#if 1
+	printk("[%s:%d]: Changing netdevice name from [%s] to [%s]\n",
+	       current->comm, current->pid,
+	       dev->name, newname);
+#endif
 
 	if (strchr(newname, '%')) {
 		err = dev_alloc_name(dev, newname);
