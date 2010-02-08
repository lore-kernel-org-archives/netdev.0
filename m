From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 39/41] CAPI: Drop special controller lookup from capi20_put_message
Date: Mon,  8 Feb 2010 21:12:43 +0100
Message-ID: <721dec20fc415bbacdf9e8eef7dd3992e58ae4d8.1265659937.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This strange special rule to fall back to controller 1 cannot be derived
from the CAPI specs and looks a lot like it was once dedicated to some
out-of-tree driver, probably AVM's broken fcdsl2 (FRITZ!Card DSL v2.0).
I found no in-tree user that needs this check, and I'm now taking care
of the fcdsl2. So drop these bits from our stack.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 0b4c8a7..ce9b05b 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -777,11 +777,8 @@ u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 	 * synchronizes this service with capi20_release.
 	 */
 	ctr = get_capi_ctr_by_nr(CAPIMSG_CONTROLLER(skb->data));
-	if (!ctr || ctr->state != CAPI_CTR_RUNNING) {
-		ctr = get_capi_ctr_by_nr(1); /* XXX why? */
-		if (!ctr || ctr->state != CAPI_CTR_RUNNING)
-			return CAPI_REGNOTINSTALLED;
-	}
+	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
+		return CAPI_REGNOTINSTALLED;
 	if (ctr->blocked)
 		return CAPI_SENDQUEUEFULL;
 
-- 
1.6.0.2
