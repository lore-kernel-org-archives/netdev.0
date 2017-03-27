From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] vxlan: don't age NTF_EXT_LEARNED fdb entries
Date: Mon, 27 Mar 2017 15:46:41 -0700
Message-ID: <1490654801-10488-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35280 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752108AbdC0WrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:47:20 -0400
Received: by mail-pg0-f48.google.com with SMTP id 81so39113018pgh.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 15:47:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

vxlan driver already implicitly supports installing
of external fdb entries with NTF_EXT_LEARNED. This
patch just makes sure these entries are not aged
by the vxlan driver. An external entity managing these
entries will age them out. This is consistent with
the use of NTF_EXT_LEARNED in the bridge driver.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 09855be..1e54fb5 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2322,6 +2322,9 @@ static void vxlan_cleanup(unsigned long arg)
 			if (f->state & (NUD_PERMANENT | NUD_NOARP))
 				continue;
 
+			if (f->flags & NTF_EXT_LEARNED)
+				continue;
+
 			timeout = f->used + vxlan->cfg.age_interval * HZ;
 			if (time_before_eq(timeout, jiffies)) {
 				netdev_dbg(vxlan->dev,
-- 
1.9.1
