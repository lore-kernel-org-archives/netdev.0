From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: fix handling of unmodifiable configuration options fix
Date: Thu, 23 Jun 2016 11:22:19 +0200
Message-ID: <1466673741-23115-2-git-send-email-mkl@pengutronix.de>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	stable@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

With upstream commit bb208f144cf3f59 (can: fix handling of unmodifiable
configuration options) a new can_validate() function was introduced.

When invoking 'ip link set can0 type can' without any configuration data
can_validate() tries to validate the content without taking into account that
there's totally no content. This patch adds a check for missing content.

Reported-by: ajneu <ajneu1@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 910c12e2638e..348dd5001fa4 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -798,6 +798,9 @@ static int can_validate(struct nlattr *tb[], struct nlattr *data[])
 	 * - control mode with CAN_CTRLMODE_FD set
 	 */
 
+	if (!data)
+		return 0;
+
 	if (data[IFLA_CAN_CTRLMODE]) {
 		struct can_ctrlmode *cm = nla_data(data[IFLA_CAN_CTRLMODE]);
 
-- 
2.8.1
