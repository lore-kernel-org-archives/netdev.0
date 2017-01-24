From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/2] vxlan: do not age static remote mac entries
Date: Mon, 23 Jan 2017 20:44:33 -0800
Message-ID: <1485233073-11391-3-git-send-email-roopa@cumulusnetworks.com>
References: <1485233073-11391-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34282 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdAXEoq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:44:46 -0500
Received: by mail-pg0-f44.google.com with SMTP id 14so51221437pgg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:44:46 -0800 (PST)
In-Reply-To: <1485233073-11391-1-git-send-email-roopa@cumulusnetworks.com>
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
index b34822f..09aa52e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2268,7 +2268,7 @@ static void vxlan_cleanup(unsigned long arg)
 				= container_of(p, struct vxlan_fdb, hlist);
 			unsigned long timeout;
 
-			if (f->state & NUD_PERMANENT)
+			if (f->state & (NUD_PERMANENT | NUD_NOARP))
 				continue;
 
 			timeout = f->used + vxlan->cfg.age_interval * HZ;
-- 
1.9.1
