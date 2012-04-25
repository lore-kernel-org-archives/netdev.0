From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 04/14 v2] usb/net: rndis: remove ambigous status codes
Date: Wed, 25 Apr 2012 17:30:25 +0200
Message-ID: <1335367825-4324-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:37310 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab2DYPa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 11:30:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RNDIS status codes are redefined with much stranged ifdeffery
and only one of these codes was used in the hyperv driver, and
there it is very clearly referring to the RNDIS variant, not some
other status. So clarify this by explictly using the RNDIS_*
prefixed status code in the hyperv drivera and delete the
duplicate defines.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/hyperv/rndis_filter.c |    4 ++--
 include/linux/rndis.h             |   31 +++----------------------------
 2 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index d6be64b..0d10348 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -267,11 +267,11 @@ static void rndis_filter_receive_response(struct rndis_device *dev,
 			    REMOTE_NDIS_RESET_CMPLT) {
 				/* does not have a request id field */
 				request->response_msg.msg.reset_complete.
-					status = STATUS_BUFFER_OVERFLOW;
+					status = RNDIS_STATUS_BUFFER_OVERFLOW;
 			} else {
 				request->response_msg.msg.
 				init_complete.status =
-					STATUS_BUFFER_OVERFLOW;
+					RNDIS_STATUS_BUFFER_OVERFLOW;
 			}
 		}
 
diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 430d72e..61b4185 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -268,32 +268,7 @@
 /* From drivers/net/hyperv/hyperv_net.h */
 
 /*  Status codes */
-
-#ifndef STATUS_SUCCESS
-#define STATUS_SUCCESS				(0x00000000L)
-#endif
-
-#ifndef STATUS_UNSUCCESSFUL
-#define STATUS_UNSUCCESSFUL			(0xC0000001L)
-#endif
-
-#ifndef STATUS_PENDING
-#define STATUS_PENDING				(0x00000103L)
-#endif
-
-#ifndef STATUS_INSUFFICIENT_RESOURCES
-#define STATUS_INSUFFICIENT_RESOURCES		(0xC000009AL)
-#endif
-
-#ifndef STATUS_BUFFER_OVERFLOW
-#define STATUS_BUFFER_OVERFLOW			(0x80000005L)
-#endif
-
-#ifndef STATUS_NOT_SUPPORTED
-#define STATUS_NOT_SUPPORTED			(0xC00000BBL)
-#endif
-
-#define RNDIS_STATUS_PENDING			(STATUS_PENDING)
+#define RNDIS_STATUS_PENDING			(0x00000103L)
 #define RNDIS_STATUS_NOT_RECOGNIZED		(0x00010001L)
 #define RNDIS_STATUS_NOT_COPIED			(0x00010002L)
 #define RNDIS_STATUS_NOT_ACCEPTED		(0x00010003L)
@@ -318,9 +293,9 @@
 #define RNDIS_STATUS_NOT_RESETTABLE		(0x80010001L)
 #define RNDIS_STATUS_SOFT_ERRORS		(0x80010003L)
 #define RNDIS_STATUS_HARD_ERRORS		(0x80010004L)
-#define RNDIS_STATUS_BUFFER_OVERFLOW		(STATUS_BUFFER_OVERFLOW)
+#define RNDIS_STATUS_BUFFER_OVERFLOW		(0x80000005L)
 
-#define RNDIS_STATUS_RESOURCES			(STATUS_INSUFFICIENT_RESOURCES)
+#define RNDIS_STATUS_RESOURCES			(0xC000009AL)
 #define RNDIS_STATUS_CLOSING			(0xC0010002L)
 #define RNDIS_STATUS_BAD_VERSION		(0xC0010004L)
 #define RNDIS_STATUS_BAD_CHARACTERISTICS	(0xC0010005L)
-- 
1.7.7.6
