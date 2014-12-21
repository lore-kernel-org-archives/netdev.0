From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 09/11] net: mlx4: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:47:04 +0100
Message-ID: <4992d674b60c48aed0d9babf0e4903726b20dfb2.1418504889.git.richardcochran@gmail.com>
References: <cover.1418504883.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418504883.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the driver to use the new and improved method
for adjusting the offset of a timecounter.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 9990144..df35d0e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -147,12 +147,9 @@ static int mlx4_en_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
 	unsigned long flags;
-	s64 now;
 
 	write_lock_irqsave(&mdev->clock_lock, flags);
-	now = timecounter_read(&mdev->clock);
-	now += delta;
-	timecounter_init(&mdev->clock, &mdev->cycles, now);
+	timecounter_adjtime(&mdev->clock, delta);
 	write_unlock_irqrestore(&mdev->clock_lock, flags);
 
 	return 0;
-- 
1.7.10.4
