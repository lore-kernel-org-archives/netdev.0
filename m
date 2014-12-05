From: Nikita Edward Baruzdin <nebaruzdin@gmail.com>
Subject: [PATCH] iproute2: Add support for CAN presume-ack feature
Date: Fri,  5 Dec 2014 11:41:42 +0300
Message-ID: <1417768902-5404-2-git-send-email-nebaruzdin@gmail.com>
References: <1417766390-4587-1-git-send-email-nebaruzdin@gmail.com>
 <1417768902-5404-1-git-send-email-nebaruzdin@gmail.com>
To: linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1417768902-5404-1-git-send-email-nebaruzdin@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes CAN_CTRLMODE_PRESUME_ACK netlink feature configurable.
When enabled, the feature sets CAN controller in mode in which
acknowledgement absence is ignored.

Signed-off-by: Nikita Edward Baruzdin <nebaruzdin@gmail.com>
---
 ip/iplink_can.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 5b92426..fb50332 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -37,6 +37,7 @@ static void print_usage(FILE *f)
 		"\t[ one-shot { on | off } ]\n"
 		"\t[ berr-reporting { on | off } ]\n"
 		"\t[ fd { on | off } ]\n"
+		"\t[ presume-ack { on | off } ]\n"
 		"\n"
 		"\t[ restart-ms TIME-MS ]\n"
 		"\t[ restart ]\n"
@@ -99,6 +100,7 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 	_PF(CAN_CTRLMODE_ONE_SHOT, "ONE-SHOT");
 	_PF(CAN_CTRLMODE_BERR_REPORTING, "BERR-REPORTING");
 	_PF(CAN_CTRLMODE_FD, "FD");
+	_PF(CAN_CTRLMODE_PRESUME_ACK, "PRESUME-ACK");
 #undef _PF
 	if (cm)
 		fprintf(f, "%x", cm);
@@ -201,6 +203,10 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			set_ctrlmode("fd", *argv, &cm,
 				     CAN_CTRLMODE_FD);
+		} else if (matches(*argv, "presume-ack") == 0) {
+			NEXT_ARG();
+			set_ctrlmode("presume-ack", *argv, &cm,
+				     CAN_CTRLMODE_PRESUME_ACK);
 		} else if (matches(*argv, "restart") == 0) {
 			__u32 val = 1;
 
-- 
2.1.3

