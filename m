From: Shuah Khan <shuah.khan@hp.com>
Subject: [PATCH RFT]  net: Change niu_rbr_fill() to use unlikely() to check
 niu_rbr_add_page() return value
Date: Fri, 20 Jul 2012 17:34:32 -0600
Message-ID: <1342827272.5434.71.camel@lorien2>
Reply-To: shuah.khan@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	shuahkhan@gmail.com
To: davem@davemloft.net, mcarlson@broadcom.com,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change niu_rbr_fill() to use unlikely() to check niu_rbr_add_page() return
value to be consistent with the rest of the checks after niu_rbr_add_page()
calls in this file.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
---
 drivers/net/ethernet/sun/niu.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 60d5c03..c2a0fe3 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3517,7 +3517,7 @@ static int niu_rbr_fill(struct niu *np, struct rx_ring_info *rp, gfp_t mask)
 	err = 0;
 	while (index < (rp->rbr_table_size - blocks_per_page)) {
 		err = niu_rbr_add_page(np, rp, mask, index);
-		if (err)
+		if (unlikely(err))
 			break;
 
 		index += blocks_per_page;
-- 
1.7.9.5
