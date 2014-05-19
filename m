From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH 1/3] net: vxge: Use time_is_before_jiffies() for time comparison
Date: Mon, 19 May 2014 18:47:36 +0200
Message-ID: <1400518056-12089-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are =
modified
to use time_is_before_jiffies() instead of plain, error-prone math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/n=
et/ethernet/neterion/vxge/vxge-main.c
index d107bcb..79f42db 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2122,7 +2122,7 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 static void adaptive_coalesce_tx_interrupts(struct vxge_fifo *fifo)
 {
 	fifo->interrupt_count++;
-	if (jiffies > fifo->jiffies + HZ / 100) {
+	if (time_is_before_jiffies(fifo->jiffies + HZ / 100)) {
 		struct __vxge_hw_fifo *hw_fifo =3D fifo->handle;
=20
 		fifo->jiffies =3D jiffies;
@@ -2150,7 +2150,7 @@ static void adaptive_coalesce_tx_interrupts(struc=
t vxge_fifo *fifo)
 static void adaptive_coalesce_rx_interrupts(struct vxge_ring *ring)
 {
 	ring->interrupt_count++;
-	if (jiffies > ring->jiffies + HZ / 100) {
+	if (time_is_before_jiffies(ring->jiffies + HZ / 100)) {
 		struct __vxge_hw_ring *hw_ring =3D ring->handle;
=20
 		ring->jiffies =3D jiffies;
--=20
1.7.10.4
