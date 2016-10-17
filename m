From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] net: report right mtu value in error message
Date: Mon, 17 Oct 2016 18:02:22 +0100
Message-ID: <1476723742-7557-1-git-send-email-jakub.kicinski@netronome.com>
Cc: jarod@redhat.com, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35413 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938152AbcJQRCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:02:50 -0400
Received: by mail-lf0-f50.google.com with SMTP id l131so250403922lfl.2
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 10:02:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check is for max_mtu but message reports min_mtu.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6498cc2ba8f6..352e98129601 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6372,7 +6372,7 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 
 	if (dev->max_mtu > 0 && new_mtu > dev->max_mtu) {
 		net_err_ratelimited("%s: Invalid MTU %d requested, hw max %d\n",
-				    dev->name, new_mtu, dev->min_mtu);
+				    dev->name, new_mtu, dev->max_mtu);
 		return -EINVAL;
 	}
 
-- 
1.9.1
