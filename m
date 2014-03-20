From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next v3 8/9] dp83640: let external input pins from the module parameters be defaults.
Date: Thu, 20 Mar 2014 22:21:59 +0100
Message-ID: <d93688e0dd8b0bd78d7688b1bd59ac6fbc7bd3ac.1395350114.git.richardcochran@gmail.com>
References: <cover.1395350105.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Christian Riesch <christian.riesch@omicron.at>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395350105.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the driver to use the new pin configuration method when
programming the external time stamp input signals.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 43b583b..93db564 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -468,7 +468,10 @@ static int ptp_dp83640_enable(struct ptp_clock_info *ptp,
 		event_num = EXT_EVENT + index;
 		evnt = EVNT_WR | (event_num & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
 		if (on) {
-			gpio_num = gpio_tab[EXTTS0_GPIO + index];
+			gpio_num = 1 + ptp_find_pin(clock->ptp_clock,
+						    PTP_PF_EXTTS, index);
+			if (gpio_num < 1)
+				return -EINVAL;
 			evnt |= (gpio_num & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
 			if (rq->extts.flags & PTP_FALLING_EDGE)
 				evnt |= EVNT_FALL;
-- 
1.7.10.4
