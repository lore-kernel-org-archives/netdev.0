From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/62] bnx2x: Use static const
Date: Sat, 20 Nov 2010 18:38:09 -0800
Message-ID: <b7ef9dc976621ce37325c75d37aff093f7913908.1290305775.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
 147632	    349	  34240	 182221	  2c7cd	drivers/net/bnx2x/bnx2x_main.o.old
 147588	    349	  34240	 182177	  2c7a1	drivers/net/bnx2x/bnx2x_main.o.new

Changed bnx2x_set_mac_addr_gen to use const *

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 2a50231..fbcffc6 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -6055,7 +6055,7 @@ static int bnx2x_func_stop(struct bnx2x *bp)
  * @param cam_offset offset in a CAM to use
  * @param is_bcast is the set MAC a broadcast address (for E1 only)
  */
-static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, u8 *mac,
+static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, const u8 *mac,
 				   u32 cl_bit_vec, u8 cam_offset,
 				   u8 is_bcast)
 {
@@ -6181,7 +6181,9 @@ void bnx2x_set_eth_mac(struct bnx2x *bp, int set)
 
 	if (CHIP_IS_E1(bp)) {
 		/* broadcast MAC */
-		u8 bcast[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+		static const u8 bcast[ETH_ALEN] = {
+			0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+		};
 		bnx2x_set_mac_addr_gen(bp, set, bcast, 0, cam_offset + 1, 1);
 	}
 }
-- 
1.7.3.2.245.g03276.dirty
