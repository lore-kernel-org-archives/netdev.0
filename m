From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2] vxlan: dont migrate permanent fdb entries during learn
Date: Sun, 11 Jun 2017 16:32:50 -0700
Message-ID: <1497223970-40084-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, jbenc@redhat.com,
        hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35079 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdFKXcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 19:32:55 -0400
Received: by mail-pg0-f45.google.com with SMTP id k71so39640770pgd.2
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 16:32:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch fixes vxlan_snoop to not move permanent fdb entries
on learn events. This is consistent with the bridge fdb
handling of permanent entries.

Fixes: 26a41ae60438 ("vxlan: only migrate dynamic FDB entries")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
v2 - added Fixes tag

 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7cb21a0..e045c34 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -970,7 +970,7 @@ static bool vxlan_snoop(struct net_device *dev,
 			return false;
 
 		/* Don't migrate static entries, drop packets */
-		if (f->state & NUD_NOARP)
+		if (f->state & (NUD_PERMANENT | NUD_NOARP))
 			return true;
 
 		if (net_ratelimit())
-- 
1.9.1
