From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: chelsio: cxgb3: constify attribute_group structures.
Date: Mon, 10 Jul 2017 16:04:11 +0530
Message-ID: <0e68326e48e123c70191169a0c0da820237425ec.1499682619.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh@chelsio.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35599 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752658AbdGJKeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 06:34:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  28720	    985	     12	  29717	   7415	drivers/net/.../cxgb3/cxgb3_main.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  28848	    857	     12	  29717	   7415	drivers/net/.../cxgb3/cxgb3_main.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 0bc6a4f..6a01536 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -793,7 +793,9 @@ static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_method)
 	NULL
 };
 
-static struct attribute_group cxgb3_attr_group = {.attrs = cxgb3_attrs };
+static const struct attribute_group cxgb3_attr_group = {
+	.attrs = cxgb3_attrs,
+};
 
 static ssize_t tm_attr_show(struct device *d,
 			    char *buf, int sched)
@@ -880,7 +882,9 @@ static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_##name)
 	NULL
 };
 
-static struct attribute_group offload_attr_group = {.attrs = offload_attrs };
+static const struct attribute_group offload_attr_group = {
+	.attrs = offload_attrs,
+};
 
 /*
  * Sends an sk_buff to an offload queue driver
-- 
1.9.1
