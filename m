From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] iproute2: can: Add support for CAN FD non-ISO feature
Date: Thu, 22 Jan 2015 19:04:33 +0100
Message-ID: <1421949873-4876-1-git-send-email-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
To: shemming@brocade.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:24803 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbbAVSLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 13:11:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes CAN_CTRLMODE_FD_NON_ISO netlink feature configurable.

During the CAN FD standardization process within the ISO it turned out that
the failure detection capability has to be improved.

The CAN in Automation organization (CiA) defined the already implemented CAN
FD controllers as 'non-ISO' and the upcoming improved CAN FD controllers as
'ISO' compliant. See at http://www.can-cia.com/index.php?id=1937

Starting with the - currently non-ISO - driver for M_CAN v3.0.1 introduced in
Linux 3.18 this bit needs to be propagated to userspace. In future drivers this
bit will become configurable depending on the CAN FD controllers capabilities.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 include/linux/can/netlink.h | 1 +
 ip/iplink_can.c             | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index 25fd52c..6d4ec2a 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -98,6 +98,7 @@ struct can_ctrlmode {
 #define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
 #define CAN_CTRLMODE_FD			0x20	/* CAN FD mode */
 #define CAN_CTRLMODE_PRESUME_ACK	0x40	/* Ignore missing CAN ACKs */
+#define CAN_CTRLMODE_FD_NON_ISO		0x80	/* CAN FD in non-ISO mode */
 
 /*
  * CAN device statistics
diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index fb50332..f1b089d 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -37,6 +37,7 @@ static void print_usage(FILE *f)
 		"\t[ one-shot { on | off } ]\n"
 		"\t[ berr-reporting { on | off } ]\n"
 		"\t[ fd { on | off } ]\n"
+		"\t[ fd-non-iso { on | off } ]\n"
 		"\t[ presume-ack { on | off } ]\n"
 		"\n"
 		"\t[ restart-ms TIME-MS ]\n"
@@ -100,6 +101,7 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 	_PF(CAN_CTRLMODE_ONE_SHOT, "ONE-SHOT");
 	_PF(CAN_CTRLMODE_BERR_REPORTING, "BERR-REPORTING");
 	_PF(CAN_CTRLMODE_FD, "FD");
+	_PF(CAN_CTRLMODE_FD_NON_ISO, "FD-NON-ISO");
 	_PF(CAN_CTRLMODE_PRESUME_ACK, "PRESUME-ACK");
 #undef _PF
 	if (cm)
@@ -203,6 +205,10 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			set_ctrlmode("fd", *argv, &cm,
 				     CAN_CTRLMODE_FD);
+		} else if (matches(*argv, "fd-non-iso") == 0) {
+			NEXT_ARG();
+			set_ctrlmode("fd-non-iso", *argv, &cm,
+				     CAN_CTRLMODE_FD_NON_ISO);
 		} else if (matches(*argv, "presume-ack") == 0) {
 			NEXT_ARG();
 			set_ctrlmode("presume-ack", *argv, &cm,
-- 
2.1.4
