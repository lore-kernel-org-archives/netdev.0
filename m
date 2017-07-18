From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v3 10/10] net: chelsio: cxgb3: constify attribute_group structures.
Date: Tue, 18 Jul 2017 15:16:19 +0530
Message-ID: <1500371179-14932-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, santosh@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  28720	    985	     12	  29717	   7415	net/.../cxgb3/cxgb3_main.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  28848	    857	     12	  29717	   7415	net/.../cxgb3/cxgb3_main.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.
Changes in v3:
              net-next was closed. Now resubmitting it.

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
