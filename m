From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] net: 8390: use time_after() for time comparison
Date: Sun, 18 May 2014 12:45:48 +0200
Message-ID: <1400409948-29399-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tedheadster@gmail.com, joe@perches.com,
	paul.gortmaker@windriver.com, jg1.han@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are =
modified
to use time_after() instead of raw math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/net/ethernet/8390/ax88796.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet=
/8390/ax88796.c
index 455d4c3..1d162cc 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -157,7 +157,7 @@ static void ax_reset_8390(struct net_device *dev)
=20
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) =3D=3D 0) {
-		if (jiffies - reset_start_time > 2 * HZ / 100) {
+		if (time_after(jiffies, reset_start_time + 2 * HZ / 100)) {
 			netdev_warn(dev, "%s: did not complete.\n", __func__);
 			break;
 		}
@@ -293,7 +293,7 @@ static void ax_block_output(struct net_device *dev,=
 int count,
 	dma_start =3D jiffies;
=20
 	while ((ei_inb(nic_base + EN0_ISR) & ENISR_RDC) =3D=3D 0) {
-		if (jiffies - dma_start > 2 * HZ / 100) {		/* 20ms */
+		if (time_after(jiffies, dma_start + 2 * HZ / 100)) { /* 20ms */
 			netdev_warn(dev, "timeout waiting for Tx RDC.\n");
 			ax_reset_8390(dev);
 			ax_NS8390_init(dev, 1);
--=20
1.7.10.4
