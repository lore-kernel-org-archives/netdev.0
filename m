From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] be2net: call napi_disable() for all event queues
Date: Tue, 26 Nov 2013 17:54:41 +0100
Message-ID: <1385484881-25715-1-git-send-email-ivecera@redhat.com>
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757348Ab3KZQyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Nov 2013 11:54:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent be2net commit 6384a4d (adds a support for busy polling)
introduces a regression that results in kernel crash. It incorrectly
modified be_close() so napi_disable() is called only for the first queue.
This breaks a correct pairing of napi_enable/_disable for the rest
of event queues and causes a crash in subsequent be_open() call.

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 78a0e85..0aec4d2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2663,8 +2663,8 @@ static int be_close(struct net_device *netdev)
 			napi_disable(&eqo->napi);
 			be_disable_busy_poll(eqo);
 		}
-		adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
 	}
+	adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
 
 	be_async_mcc_disable(adapter);
 
-- 
1.8.3.2
