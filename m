From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH cumulus-4.1.y 5/5] vxlan: do not age static remote mac entries
Date: Fri, 20 Jan 2017 23:40:10 -0800
Message-ID: <1484984410-3304-5-git-send-email-roopa@cumulusnetworks.com>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34046 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdAUHlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:41:06 -0500
Received: by mail-pg0-f46.google.com with SMTP id 14so29793935pgg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:40:22 -0800 (PST)
In-Reply-To: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakrishnan Raman <ramanb@cumulusnetworks.com>

Mac aging is applicable only for dynamically learnt remote mac
entries. Check for user configured static remote mac entries
and skip aging.

Signed-off-by: Balakrishnan Raman <ramanb@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3314090..312240c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2279,7 +2279,7 @@ static void vxlan_cleanup(unsigned long arg)
 				= container_of(p, struct vxlan_fdb, hlist);
 			unsigned long timeout;
 
-			if (f->state & NUD_PERMANENT)
+			if (f->state & (NUD_PERMANENT | NUD_NOARP))
 				continue;
 
 			timeout = f->used + vxlan->cfg.age_interval * HZ;
-- 
1.9.1
