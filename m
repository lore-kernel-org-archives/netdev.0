From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] hostap: Use memdup_user() rather than duplicating its
 implementation
Date: Sat, 20 Aug 2016 18:45:08 +0200
Message-ID: <efa66c16-7998-9ceb-0be6-d62dd249a2dc@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 18:19:43 +0200

Reuse existing functionality from memdup_user() instead of keeping
duplicate source code.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 .../net/wireless/intersil/hostap/hostap_ioctl.c    | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
index 3e5fa78..4e271f9 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
@@ -3041,14 +3041,9 @@ static int prism2_ioctl_priv_download(local_info_t *local, struct iw_point *p)
 	    p->length > 1024 || !p->pointer)
 		return -EINVAL;
 
-	param = kmalloc(p->length, GFP_KERNEL);
-	if (param == NULL)
-		return -ENOMEM;
-
-	if (copy_from_user(param, p->pointer, p->length)) {
-		ret = -EFAULT;
-		goto out;
-	}
+	param = memdup_user(p->pointer, p->length);
+	if (IS_ERR(param))
+		return PTR_ERR(param);
 
 	if (p->length < sizeof(struct prism2_download_param) +
 	    param->num_areas * sizeof(struct prism2_download_area)) {
@@ -3803,14 +3798,9 @@ static int prism2_ioctl_priv_hostapd(local_info_t *local, struct iw_point *p)
 	    p->length > PRISM2_HOSTAPD_MAX_BUF_SIZE || !p->pointer)
 		return -EINVAL;
 
-	param = kmalloc(p->length, GFP_KERNEL);
-	if (param == NULL)
-		return -ENOMEM;
-
-	if (copy_from_user(param, p->pointer, p->length)) {
-		ret = -EFAULT;
-		goto out;
-	}
+	param = memdup_user(p->pointer, p->length);
+	if (IS_ERR(param))
+		return PTR_ERR(param);
 
 	switch (param->cmd) {
 	case PRISM2_SET_ENCRYPTION:
-- 
2.9.3
