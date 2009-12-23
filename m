From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] iplink_can: add support to set one-shot mode
Date: Wed, 23 Dec 2009 13:02:58 +0100
Message-ID: <1261569778-23669-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the flag CAN_CTRLMODE_ONE_SHOT. It is used as mask
or flag in the "struct can_ctrlmode".

It also adds to "ip" the option to set a CAN controller into the special
"one-shot" mode. In this mode, if supported by the CAN controller,
tries only once to deliver a CAN frame and aborts it if an error
(e.g.: arbitration lost) happens.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 include/linux/can/netlink.h |    1 +
 ip/iplink_can.c             |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index 9ecbb78..c818335 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -80,6 +80,7 @@ struct can_ctrlmode {
 #define CAN_CTRLMODE_LOOPBACK	0x1	/* Loopback mode */
 #define CAN_CTRLMODE_LISTENONLY	0x2 	/* Listen-only mode */
 #define CAN_CTRLMODE_3_SAMPLES	0x4	/* Triple sampling mode */
+#define CAN_CTRLMODE_ONE_SHOT	0x8	/* One-Shot mode */
 
 /*
  * CAN device statistics
diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 50221e1..5d0d82c 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -30,6 +30,7 @@ static void usage(void)
 	        "\t[ loopback { on | off } ]\n"
 	        "\t[ listen-only { on | off } ]\n"
 	        "\t[ triple-sampling { on | off } ]\n"
+	        "\t[ one-shot { on | off } ]\n"
 		"\n"
 	        "\t[ restart-ms TIME-MS ]\n"
 	        "\t[ restart ]\n"
@@ -84,6 +85,7 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 	_PF(CAN_CTRLMODE_LOOPBACK, "LOOPBACK");
 	_PF(CAN_CTRLMODE_LISTENONLY, "LISTEN-ONLY");
 	_PF(CAN_CTRLMODE_3_SAMPLES, "TRIPLE-SAMPLING");
+	_PF(CAN_CTRLMODE_ONE_SHOT, "ONE-SHOT");
 #undef _PF
 	if (cm)
 		fprintf(f, "%x", cm);
@@ -142,6 +144,10 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			set_ctrlmode("triple-sampling", *argv, &cm,
 				     CAN_CTRLMODE_3_SAMPLES);
+		} else if (matches(*argv, "one-shot") == 0) {
+			NEXT_ARG();
+			set_ctrlmode("one-shot", *argv, &cm,
+				     CAN_CTRLMODE_ONE_SHOT);
 		} else if (matches(*argv, "restart") == 0) {
 			__u32 val = 1;
 
-- 
1.6.5.7
