From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] NFC: fix device-allocation error return
Date: Sun,  9 Jul 2017 13:08:58 +0200
Message-ID: <20170709110858.20331-1-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:33224 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdGILJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 07:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent change fixing NFC device allocation itself introduced an
error-handling bug by returning an error pointer in case device-id
allocation failed. This is clearly broken as the callers still expected
NULL to be returned on errors as detected by Dan's static checker.

Fix this up by returning NULL in the event that we've run out of memory
when allocating a new device id.

Note that the offending commit is marked for stable (3.8) so this fix
needs to be backported along with it.

Fixes: 20777bc57c34 ("NFC: fix broken device allocation")
Cc: stable <stable@vger.kernel.org>	# 3.8
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 net/nfc/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index 5cf33df888c3..c699d64a0753 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -1106,7 +1106,7 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 err_free_dev:
 	kfree(dev);
 
-	return ERR_PTR(rc);
+	return NULL;
 }
 EXPORT_SYMBOL(nfc_allocate_device);
 
-- 
2.13.2
