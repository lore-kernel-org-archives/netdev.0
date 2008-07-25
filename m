From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [build error] ERROR: "NS8390_init" [drivers/net/ne.ko] undefined!
Date: Fri, 25 Jul 2008 13:48:51 +0800
Message-ID: <48896943.7090902@cn.fujitsu.com>
References: <4889437A.5060907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	torvalds@linux-foundation.org, NETDEV <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Alan Cox <alan@redhat.com>
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65084 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbYGYFu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 01:50:28 -0400
In-Reply-To: <4889437A.5060907@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff

commit "net 8390p: fix interface usage"(f0084a36d4d7) fixed some drivers which
use wrong API of NS8390p.
But ne.c seems didn't be fixed completely.
I've got the following build err:
---
Kernel: arch/x86/boot/bzImage is ready  (#21)
  Building modules, stage 2.
  MODPOST 423 modules
ERROR: "NS8390_init" [drivers/net/ne.ko] undefined!
WARNING: modpost: Found 2 section mismatch(es).
To see full details build your kernel with:
'make CONFIG_DEBUG_SECTION_MISMATCH=y'
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2
---

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@redhat.com>
---
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 2fec612..4a8a4b1 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = eip_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
 
 	ret = register_netdev(dev);
 	if (ret)
@@ -794,7 +794,7 @@ retry:
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			NS8390p_init(dev,1);
 			break;
 		}
 
@@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform_device *pdev)
 
 	if (netif_running(dev)) {
 		ne_reset_8390(dev);
-		NS8390_init(dev, 1);
+		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
 	}
 	return 0;



