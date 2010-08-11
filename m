From: Denis Kirjanov <dkirjanov-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] orinoco: Fix walking past the end of the buffer
Date: Wed, 11 Aug 2010 20:32:16 +0000
Message-ID: <20100811203216.GA25168@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: proski-mXXj517/zsQ@public.gmane.org, hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix walking past the end of the bitrate_table array
in the case when the loop counter == BITRATE_TABLE_SIZE.
Mark bitrate as invalid in this case for the orinoco_ioctl_setrate()

Signed-off-by: Denis Kirjanov <dkirjanov-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---

diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index 077baa8..191bc03 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -765,9 +765,12 @@ int orinoco_hw_get_act_bitrate(struct orinoco_private *priv, int *bitrate)
 			if (bitrate_table[i].intersil_txratectrl == val)
 				break;
 
-		if (i >= BITRATE_TABLE_SIZE)
+		if (i >= BITRATE_TABLE_SIZE) {
 			printk(KERN_INFO "%s: Unable to determine current bitrate (0x%04hx)\n",
 			       priv->ndev->name, val);
+			*bitrate = 100001; /* Mark as invalid */
+			break;
+		}
 
 		*bitrate = bitrate_table[i].bitrate * 100000;
 		break;
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
