From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/5] sky2: Restore multicast after restart
Date: Thu, 13 May 2010 08:16:38 +0900
Message-ID: <4BEB36D6.8070500@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:48719 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771Ab0ELXZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 19:25:39 -0400
Received: by mail-pw0-f46.google.com with SMTP id 5so326811pwi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 16:25:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multicast settings will be lost on reset, so restore them.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index b839bae..58ae840 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3293,6 +3293,7 @@ static void sky2_restart(struct work_struct *work)
 			continue;
 
 		sky2_hw_up(sky2);
+		sky2_set_multicast(dev);
 		netif_wake_queue(dev);
 	}
 
-- 
1.5.6.5


