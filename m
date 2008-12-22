From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 4/9] mlx4_en: Verify number of RX rings doesn't
	exceed MAX_RX_RINGS
Date: Mon, 22 Dec 2008 12:00:49 +0200
Message-ID: <494F6551.3040500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Required in cases were dev->caps.num_comp_vectors > MAX_RX_RINGS.
For current values this would happen on machines that have more
then 16 cores.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index e44e018..34f3a19 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -170,7 +170,8 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
 			  mdev->profile.prof[i].tx_ring_num, i);
 		if (!mdev->profile.prof[i].rx_ring_num) {
-			mdev->profile.prof[i].rx_ring_num = dev->caps.num_comp_vectors;;
+			mdev->profile.prof[i].rx_ring_num =
+				min_t(int, dev->caps.num_comp_vectors, MAX_RX_RINGS);
 			mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
 				  mdev->profile.prof[i].rx_ring_num, i);
 		} else
-- 
1.5.4
