From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 2/2] be2net: fix mbox polling for signal reception
Date: Thu, 12 May 2011 11:41:03 +0530
Message-ID: <f816628b-a4b6-4a53-867e-12e75bc7b4de@exht1.ad.emulex.com>
References: <1305180663-12140-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37717 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755514Ab1ELGIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 02:08:11 -0400
In-Reply-To: <1305180663-12140-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending mbox cmds require multiple steps of writing to the DB register and polling
for an ack. Gettting interrupted in the middle by a signal breaks the mbox protocol.
So, set the task to UNINTERRUPTIBLE for mbox polling.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index bff41ed..55c8301 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -297,7 +297,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 			return -1;
 		}
 
-		set_current_state(TASK_INTERRUPTIBLE);
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(msecs_to_jiffies(1));
 		msecs++;
 	} while (true);
-- 
1.7.4

