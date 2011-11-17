From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] ks8*/ksz8*: Casting (void *) value returned by kmalloc is
 useless
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.248.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/alloc/drop_kmalloc_cast.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
--- a/drivers/net/ethernet/micrel/ks8851_mll.c 2011-11-07 19:37:59.170122280 +0100
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c 2011-11-08 09:00:03.544702580 +0100
@@ -1500,8 +1500,7 @@ static int ks_hw_init(struct ks_net *ks)
 	ks->all_mcast = 0;
 	ks->mcast_lst_size = 0;
 
-	ks->frame_head_info = (struct type_frame_head *) \
-		kmalloc(MHEADER_SIZE, GFP_KERNEL);
+	ks->frame_head_info = kmalloc(MHEADER_SIZE, GFP_KERNEL);
 	if (!ks->frame_head_info) {
 		pr_err("Error: Fail to allocate frame memory\n");
 		return false;
