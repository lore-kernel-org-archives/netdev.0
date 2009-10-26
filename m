From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the i2c tree
Date: Mon, 26 Oct 2009 13:37:57 +1100
Message-ID: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>,
	Jean Delvare <khali@linux-fr.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/sfc/sfe4001.c between commit
3f7c0648f727a6d5baf6117653e4001dc877b90b ("i2c: Prevent priority
inversion on top of bus lock") from the i2c tree and commit
c9597d4f89565b6562bd3026adbe6eac6c317f47 ("sfc: Merge sfe4001.c into
falcon_boards.c") from the net tree.

I have applied the following merge fixup patch (after removing
drivers/net/sfc/sfe4001.c) and can carry it as necessary.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 26 Oct 2009 12:24:55 +1100
Subject: [PATCH] net: merge fixup for drivers/net/sfc/falcon_boards.c

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/sfc/falcon_boards.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 99f7372..788b336 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -327,7 +327,7 @@ static int sfn4111t_reset(struct efx_nic *efx)
 	efx_oword_t reg;
 
 	/* GPIO 3 and the GPIO register are shared with I2C, so block that */
-	mutex_lock(&efx->i2c_adap.bus_lock);
+	rt_mutex_lock(&efx->i2c_adap.bus_lock);
 
 	/* Pull RST_N (GPIO 2) low then let it up again, setting the
 	 * FLASH_CFG_1 strap (GPIO 3) appropriately.  Only change the
@@ -343,7 +343,7 @@ static int sfn4111t_reset(struct efx_nic *efx)
 	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
 	msleep(1);
 
-	mutex_unlock(&efx->i2c_adap.bus_lock);
+	rt_mutex_unlock(&efx->i2c_adap.bus_lock);
 
 	ssleep(1);
 	return 0;
-- 
1.6.5
