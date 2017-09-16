From: Srishti Sharma <srishtishar@gmail.com>
Subject: [PATCH] Staging: irda: Use !x instead of NULL comparison
Date: Sat, 16 Sep 2017 12:04:27 +0530
Message-ID: <1505543667-4670-1-git-send-email-srishtishar@gmail.com>
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com,
        Srishti Sharma <srishtishar@gmail.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Test for NULL as !x where functions that return NULL on failure
are used. Done using the following semantic patch by coccinelle.

@ is_null @
expression E;
statement S;
@@

E = (\(kmalloc\|devm_kzalloc\|kmalloc_array\|devm_ioremap\|
usb_alloc_urb\|alloc_netdev\|dev_alloc_skb\)(...));

(
if(!E)
   S
|
-if(E==NULL)
+if(!E)
    S
)

Signed-off-by: Srishti Sharma <srishtishar@gmail.com>
---
 drivers/staging/irda/net/discovery.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/irda/net/discovery.c b/drivers/staging/irda/net/discovery.c
index 364d70a..1e54954 100644
--- a/drivers/staging/irda/net/discovery.c
+++ b/drivers/staging/irda/net/discovery.c
@@ -179,7 +179,7 @@ void irlmp_expire_discoveries(hashbin_t *log, __u32 saddr, int force)
 				/* Create the client specific buffer */
 				n = HASHBIN_GET_SIZE(log);
 				buffer = kmalloc(n * sizeof(struct irda_device_info), GFP_ATOMIC);
-				if (buffer == NULL) {
+				if (!buffer) {
 					spin_unlock_irqrestore(&log->hb_spinlock, flags);
 					return;
 				}
@@ -291,7 +291,7 @@ struct irda_device_info *irlmp_copy_discoveries(hashbin_t *log, int *pn,
 				/* Create the client specific buffer */
 				n = HASHBIN_GET_SIZE(log);
 				buffer = kmalloc(n * sizeof(struct irda_device_info), GFP_ATOMIC);
-				if (buffer == NULL) {
+				if (!buffer) {
 					spin_unlock_irqrestore(&log->hb_spinlock, flags);
 					return NULL;
 				}
-- 
2.7.4
