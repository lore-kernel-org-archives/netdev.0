From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net 1/3] macsec: limit ICV length to 16 octets
Date: Fri, 22 Jul 2016 15:07:56 +0200
Message-ID: <1da0e507d2159ca2fb238676930a35406386ace2.1469191850.git.dcaratti@redhat.com>
References: <cover.1469191850.git.dcaratti@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444AbcGVNJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 09:09:10 -0400
In-Reply-To: <cover.1469191850.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 802.1AE-2006 standard recommends that the ICV element in a MACsec
frame should not exceed 16 octets: add MACSEC_STD_ICV_LEN in uapi
definitions accordingly, and avoid accepting configurations where the ICV
length exceeds the standard value. Leave definition of MACSEC_MAX_ICV_LEN
unchanged for backwards compatibility with userspace programs.

Fixes: dece8d2b78d1 ("uapi: add MACsec bits")
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 drivers/net/macsec.c           | 4 ++--
 include/uapi/linux/if_macsec.h | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 8bcd78f..7c0e732 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -508,7 +508,7 @@ static bool macsec_validate_skb(struct sk_buff *skb, u16 icv_len)
 }
 
 #define MACSEC_NEEDED_HEADROOM (macsec_extra_len(true))
-#define MACSEC_NEEDED_TAILROOM MACSEC_MAX_ICV_LEN
+#define MACSEC_NEEDED_TAILROOM MACSEC_STD_ICV_LEN
 
 static void macsec_fill_iv(unsigned char *iv, sci_t sci, u32 pn)
 {
@@ -3199,7 +3199,7 @@ static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
 	case MACSEC_DEFAULT_CIPHER_ID:
 	case MACSEC_DEFAULT_CIPHER_ALT:
 		if (icv_len < MACSEC_MIN_ICV_LEN ||
-		    icv_len > MACSEC_MAX_ICV_LEN)
+		    icv_len > MACSEC_STD_ICV_LEN)
 			return -EINVAL;
 		break;
 	default:
diff --git a/include/uapi/linux/if_macsec.h b/include/uapi/linux/if_macsec.h
index f7d4831..02fc49c 100644
--- a/include/uapi/linux/if_macsec.h
+++ b/include/uapi/linux/if_macsec.h
@@ -26,6 +26,8 @@
 
 #define MACSEC_MIN_ICV_LEN 8
 #define MACSEC_MAX_ICV_LEN 32
+/* upper limit for ICV length as recommended by IEEE802.1AE-2006 */
+#define MACSEC_STD_ICV_LEN 16
 
 enum macsec_attrs {
 	MACSEC_ATTR_UNSPEC,
-- 
2.5.5
