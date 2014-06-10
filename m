From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: xen-netback: include linux/vmalloc.h again
Date: Tue, 10 Jun 2014 10:34:36 +0200
Message-ID: <5508988.K5Wec8A6hA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, Wei Liu <wei.liu2@citrix.com>,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	xen-devel@lists.xenproject.org,
	Josh Boyer <jwboyer@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:58871 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934267AbaFJIew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 04:34:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into
queue struct") added a use of vzalloc/vfree to interface.c, but
removed the #include <linux/vmalloc.h> statement at the same time,
which causes this build error:

drivers/net/xen-netback/interface.c: In function 'xenvif_free':
drivers/net/xen-netback/interface.c:754:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
  vfree(vif->queues);
  ^
cc1: some warnings being treated as errors

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---

I haven't found another report of this bug, but if someone else already
submitted a fix, please ignore this one.

Incidentally, it's the same bug that Josh fixed before in January,
but it has reappeared now, see https://lkml.org/lkml/2014/1/5/36

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 6929bcb..852da34 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -34,6 +34,7 @@
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <xen/events.h>
 #include <asm/xen/hypercall.h>
