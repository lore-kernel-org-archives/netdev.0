From: Marcela Maslanova <mmaslano@redhat.com>
Subject: [PATCH] IPROUTE: tc correct error message
Date: Mon, 22 Sep 2008 15:52:36 +0200
Message-ID: <48D7A324.3050401@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060701050505060606020504"
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47758 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131AbYIVNwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 09:52:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060701050505060606020504
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

This warning message was removed in change 
083a5f00a15f6506815b0da2be82e7be761c5cbc
In this patch is checked, whether warning should be printed. Output
of "tc filter <type> help" isn't spoiled after my change.
-- 
Marcela Ma¹láòová
BaseOS team Brno

--------------060701050505060606020504
Content-Type: text/x-patch;
 name="0001-tc-error-message-protocol-is-needed.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-tc-error-message-protocol-is-needed.patch"

>From e007577ef506671896857808634f3326d69b5072 Mon Sep 17 00:00:00 2001
From: =?utf-8?q?Marcela=20Ma=C5=A1l=C3=A1=C5=88ov=C3=A1?= <mmaslano@redhat.com>
Date: Mon, 22 Sep 2008 15:41:04 +0200
Subject: [PATCH] tc error message: protocol is needed.
 This message was removed in change 083a5f00a15f6506815b0da2be82e7be761c5cbc
 but now it's checked, whether it should be print and don't spoil
 help messages.

---
 tc/tc_filter.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 177446e..ce30dd9 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -120,7 +120,9 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (parse_estimator(&argc, &argv, &est) < 0)
 				return -1;
 		} else if (matches(*argv, "help") == 0) {
+			protocol_set = 1;
 			usage();
+			return 0;
 		} else {
 			strncpy(k, *argv, sizeof(k)-1);
 
@@ -128,7 +130,6 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 			argc--; argv++;
 			break;
 		}
-
 		argc--; argv++;
 	}
 
@@ -153,6 +154,11 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 			return -1;
 		}
 	}
+	if (!protocol_set) {
+		fprintf(stderr, "\"protocol\" is required.\n");
+		return -1;
+	}
+
 	if (est.ewma_log)
 		addattr_l(&req.n, sizeof(req), TCA_RATE, &est, sizeof(est));
 
-- 
1.5.5.2


--------------060701050505060606020504--
