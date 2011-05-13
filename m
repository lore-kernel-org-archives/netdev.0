From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 2/2] be2net: fix mbox polling for signal reception
Date: Fri, 13 May 2011 11:02:16 +0530
Message-ID: <b37c4038-fd25-4470-b0a6-234ff87e4b2a@exht1.ad.emulex.com>
References: <1305264736-18358-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:53988 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755841Ab1EMF2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 01:28:46 -0400
In-Reply-To: <1305264736-18358-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending mbox cmds require multiple steps of writing to the DB register and polling
for an ack. Gettting interrupted in the middle by a signal breaks the mbox protocol.
Use msleep() to not get interrupted.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index d558b90..f2c9099 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -298,8 +298,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 			return -1;
 		}
 
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(1));
+		msleep(1);
 		msecs++;
 	} while (true);
 
-- 
1.7.4

