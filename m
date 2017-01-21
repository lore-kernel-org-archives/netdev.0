From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] vxlan: do not age static remote mac entries
Date: Fri, 20 Jan 2017 23:43:19 -0800
Message-ID: <1484984599-16712-3-git-send-email-roopa@cumulusnetworks.com>
References: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36429 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751043AbdAUHnl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:43:41 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so28121047pfu.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:43:40 -0800 (PST)
In-Reply-To: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com>
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
index 269e515..2c5bb0a 100644
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
