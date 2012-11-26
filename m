From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: bcm: initialize ifindex for timeouts without previous frame reception
Date: Mon, 26 Nov 2012 22:47:10 +0100
Message-ID: <1353966430-12601-3-git-send-email-mkl@pengutronix.de>
References: <1353966430-12601-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1353966430-12601-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

Set in the rx_ifindex to pass the correct interface index in the case of a
message timeout detection. Usually the rx_ifindex value is set at receive
time. But when no CAN frame has been received the RX_TIMEOUT notification
did not contain a valid value.

Cc: linux-stable <stable@vger.kernel.org>
Reported-by: Andre Naujoks <nautsch2@googlemail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/bcm.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 6f74758..969b7cd 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1084,6 +1084,9 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		op->sk = sk;
 		op->ifindex = ifindex;
 
+		/* ifindex for timeout events w/o previous frame reception */
+		op->rx_ifindex = ifindex;
+
 		/* initialize uninitialized (kzalloc) structure */
 		hrtimer_init(&op->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 		op->timer.function = bcm_rx_timeout_handler;
-- 
1.7.10.4
