From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] iucv: fix memory leak in cpu hotplug error path.
Date: Tue, 15 Jul 2008 17:10:25 +0900
Message-ID: <20080715081025.GB22068@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ursula Braun <ubraun@linux.vnet.ibm.com>, linux390@de.ibm.com,
	linux-s390@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:43399 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912AbYGOIKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 04:10:33 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5875919rvb.1
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 01:10:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix memory leak in error path in CPU_UP_PREPARE notifier.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: Ursula Braun <ubraun@linux.vnet.ibm.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
---
 net/iucv/iucv.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: 2.6-mmotm/net/iucv/iucv.c
===================================================================
--- 2.6-mmotm.orig/net/iucv/iucv.c
+++ 2.6-mmotm/net/iucv/iucv.c
@@ -567,8 +567,11 @@ static int __cpuinit iucv_cpu_notify(str
 			return NOTIFY_BAD;
 		iucv_param[cpu] = kmalloc_node(sizeof(union iucv_param),
 				     GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_param[cpu])
+		if (!iucv_param[cpu]) {
+			kfree(iucv_irq_data[cpu]);
+			iucv_irq_data[cpu] = NULL;
 			return NOTIFY_BAD;
+		}
 		break;
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
