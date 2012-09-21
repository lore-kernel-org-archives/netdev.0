From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] can: mscan-mpc5xxx: fix return value check in mpc512x_can_get_clock()
Date: Fri, 21 Sep 2012 15:09:47 +0800
Message-ID: <CAPgLHd9fRAvQ77rD_PCp45XW9-FsBisUATOT00Je39nbv5o28A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: wg@grandegger.com, mkl@pengutronix.de, grant.likely@secretlab.ca,
	rob.herring@calxeda.com
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function clk_get() returns ERR_PTR()
and never returns NULL pointer. The NULL test in the error
handling should be replaced with IS_ERR().

dpatch engine is used to auto generated this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/can/mscan/mpc5xxx_can.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 06adf88..524ef96 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -181,7 +181,7 @@ static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
 
 		if (!clock_name || !strcmp(clock_name, "sys")) {
 			sys_clk = clk_get(&ofdev->dev, "sys_clk");
-			if (!sys_clk) {
+			if (IS_ERR(sys_clk)) {
 				dev_err(&ofdev->dev, "couldn't get sys_clk\n");
 				goto exit_unmap;
 			}
@@ -204,7 +204,7 @@ static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
 
 		if (clocksrc < 0) {
 			ref_clk = clk_get(&ofdev->dev, "ref_clk");
-			if (!ref_clk) {
+			if (IS_ERR(ref_clk)) {
 				dev_err(&ofdev->dev, "couldn't get ref_clk\n");
 				goto exit_unmap;
 			}


