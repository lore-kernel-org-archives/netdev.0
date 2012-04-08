From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/14] usb/net: rndis: remove ambigous status codes
Date: Sun,  8 Apr 2012 10:47:44 +0200
Message-ID: <1333874864-4503-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The RNDIS status codes are redefined with much stranged ifdeffery
and only one of these codes was used in the hyperv driver, and
there it is very clearly referring to the RNDIS variant, not some
other status. So clarify this by explictly using the RNDIS_*
prefixed status code in the hyperv drivera and delete the
duplicate defines.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
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
