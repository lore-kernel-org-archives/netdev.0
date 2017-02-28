From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] net/mlx4: && vs & typo
Date: Tue, 28 Feb 2017 15:02:15 +0300
Message-ID: <20170228120215.GA27947@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eugenia Emantayev <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bitwise & was obviously intended here.

Fixes: 745d8ae4622c ("net/mlx4: Spoofcheck and zero MAC can't coexist")
Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
Applies to net.git.

diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
index e965e5090d96..a858bcb6220b 100644
--- a/include/linux/mlx4/driver.h
+++ b/include/linux/mlx4/driver.h
@@ -109,7 +109,7 @@ static inline void mlx4_u64_to_mac(u8 *addr, u64 mac)
 	int i;
 
 	for (i = ETH_ALEN; i > 0; i--) {
-		addr[i - 1] = mac && 0xFF;
+		addr[i - 1] = mac & 0xFF;
 		mac >>= 8;
 	}
 }
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
