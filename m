From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 01/10] net: cdc_ncm: constify attribute_group structures.
Date: Tue, 11 Jul 2017 12:52:42 +0530
Message-ID: <1499757762-24610-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1499757762-24610-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org
To: davem@davemloft.net, oliver@neukum.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499757762-24610-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  13275	    928	      1	  14204	   377c	drivers/net/usb/cdc_ncm.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  13339	    864	      1	  14204	   377c	drivers/net/usb/cdc_ncm.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.

 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d103a1d..b401ba9 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -367,7 +367,7 @@ static DEVICE_ATTR(name, S_IRUGO, cdc_ncm_show_##name, NULL)
 	NULL,
 };
 
-static struct attribute_group cdc_ncm_sysfs_attr_group = {
+static const struct attribute_group cdc_ncm_sysfs_attr_group = {
 	.name = "cdc_ncm",
 	.attrs = cdc_ncm_sysfs_attrs,
 };
-- 
1.9.1
