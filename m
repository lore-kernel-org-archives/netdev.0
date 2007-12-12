From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] HDLC driver: use unregister_netdev instead of unregister_netdevice
Date: Wed, 12 Dec 2007 10:35:56 +0800
Message-ID: <475F490C.2020305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:60463 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757421AbXLLCjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 21:39:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] HDLC driver: use unregister_netdev instead of unregister_netdevice

Since the caller and the upper caller doesn't hod the rtnl semaphore.
We should use unregister_netdev instead of unregister_netdevice.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 hdlc_fr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.24.rc5.org/drivers/net/wan/hdlc_fr.c	2007-10-10 04:31:38.000000000 +0800
+++ linux-2.6.24.rc5/drivers/net/wan/hdlc_fr.c	2007-12-12 10:25:13.000000000 +0800
@@ -1177,7 +1177,7 @@ static int fr_del_pvc(hdlc_device *hdlc,
 	if (dev->flags & IFF_UP)
 		return -EBUSY;		/* PVC in use */
 
-	unregister_netdevice(dev); /* the destructor will free_netdev(dev) */
+	unregister_netdev(dev); /* the destructor will free_netdev(dev) */
 	*get_dev_p(pvc, type) = NULL;
 
 	if (!pvc_is_used(pvc)) {
@@ -1202,10 +1202,10 @@ static void fr_destroy(struct net_device
 		pvc_device *next = pvc->next;
 		/* destructors will free_netdev() main and ether */
 		if (pvc->main)
-			unregister_netdevice(pvc->main);
+			unregister_netdev(pvc->main);
 
 		if (pvc->ether)
-			unregister_netdevice(pvc->ether);
+			unregister_netdev(pvc->ether);
 
 		kfree(pvc);
 		pvc = next;

