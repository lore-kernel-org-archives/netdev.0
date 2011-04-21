From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] be2net: increment work_counter in be_worker
Date: Thu, 21 Apr 2011 12:20:04 +0200
Message-ID: <1303381204-31258-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab1DUKUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 06:20:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 609ff3b adds support to display temperature of ASIC but there
is missing increment of work_counter in be_worker. Because of this 1) the
function be_cmd_get_die_temperature is called every 1 second instead of
every 32 seconds 2) be_cmd_get_die_temperature is called, although it is
not supported.
This patch fixes this bug.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/benet/be_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7cb5a11..02a0443 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1873,6 +1873,7 @@ static void be_worker(struct work_struct *work)
 		be_detect_dump_ue(adapter);
 
 reschedule:
+	adapter->work_counter++;
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
 }
 
-- 
1.7.3.4

