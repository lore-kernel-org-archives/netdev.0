From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] mlx4_core: return a negative error value
Date: Sat, 12 Dec 2009 20:09:05 +0100
Message-ID: <4B23EA51.30504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, yevgenyp@mellanox.co.il,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935306AbZLMB6k@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value should be negative.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/mlx4/sense.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

This is a cleanup, its only caller, mlx4_do_sense_ports()
acts on any non-zero error values as well.

diff --git a/drivers/net/mlx4/sense.c b/drivers/net/mlx4/sense.c
index f36ae69..015fbe7 100644
--- a/drivers/net/mlx4/sense.c
+++ b/drivers/net/mlx4/sense.c
@@ -53,7 +53,7 @@ static int mlx4_SENSE_PORT(struct mlx4_dev *dev, int port,
 
 	if (out_param > 2) {
 		mlx4_err(dev, "Sense returned illegal value: 0x%llx\n", out_param);
-		return EINVAL;
+		return -EINVAL;
 	}
 
 	*type = out_param;
