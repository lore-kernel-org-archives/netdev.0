From: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
Subject: [PATCH] tipc: remove unnecessary call to dev_net()
Date: Wed,  6 Sep 2017 11:08:06 +0200
Message-ID: <20170906090806.20931-1-kleber.souza@canonical.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36188 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbdIFJIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 05:08:10 -0400
Received: from mail-wm0-f72.google.com ([74.125.82.72])
        by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
        (Exim 4.76)
        (envelope-from <kleber.souza@canonical.com>)
        id 1dpWJd-0004vE-Ru
        for netdev@vger.kernel.org; Wed, 06 Sep 2017 09:08:09 +0000
Received: by mail-wm0-f72.google.com with SMTP id i198so2397649wmf.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 02:08:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net device is already stored in the 'net' variable, so no need to call
dev_net() again.

Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 89cd061c4468..6d6395e0904e 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -661,7 +661,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 		break;
 	case NETDEV_UNREGISTER:
 	case NETDEV_CHANGENAME:
-		bearer_disable(dev_net(dev), b);
+		bearer_disable(net, b);
 		break;
 	}
 	return NOTIFY_OK;
-- 
2.14.1
