From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH v2 5/8] i2c-pnx.c: Fix suspend
Date: Mon,  2 Apr 2012 20:33:04 +0200
Message-ID: <1333391587-26290-6-git-send-email-stigge@antcom.de>
References: <1333391587-26290-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>, stable@vger.kernel.org
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
 gregkh@linuxfoundation.org, netdev@vger.kernel.org,
 rtc-linux@googlegroups.com, a.zummo@towertech.it,
 linux-watchdog@vger.kernel.org, wim@iguana.be, jonsmirl@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1333391587-26290-1-git-send-email-stigge@antcom.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

In the driver's suspend function, clk_enable() was used instead of
clk_disable(). This is corrected with this patch.

Signed-off-by: Roland Stigge <stigge@antcom.de>
CC: stable@vger.kernel.org

---

 Applies to v3.4-rc1

 drivers/i2c/busses/i2c-pnx.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- linux-2.6.orig/drivers/i2c/busses/i2c-pnx.c
+++ linux-2.6/drivers/i2c/busses/i2c-pnx.c
@@ -546,8 +546,7 @@ static int i2c_pnx_controller_suspend(st
 {
 	struct i2c_pnx_algo_data *alg_data = platform_get_drvdata(pdev);
 
-	/* FIXME: shouldn't this be clk_disable? */
-	clk_enable(alg_data->clk);
+	clk_disable(alg_data->clk);
 
 	return 0;
 }
