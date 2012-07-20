From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] bond_sysfs: use ream_num_tx_queues rather than params.tx_queue
Date: Fri, 20 Jul 2012 14:28:50 +0200
Message-ID: <1342787331-1866-6-git-send-email-jiri@resnulli.us>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44789 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab2GTM3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:29:11 -0400
Received: by wibhr14 with SMTP id hr14so513665wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:29:10 -0700 (PDT)
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since now number of tx queues can be specified during bond instance
creation and therefore it may differ from params.tx_queues, use rather
real_num_tx_queues for boundary check.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_sysfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 485bedb..dc15d24 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1495,7 +1495,7 @@ static ssize_t bonding_store_queue_id(struct device *d,
 	/* Check buffer length, valid ifname and queue id */
 	if (strlen(buffer) > IFNAMSIZ ||
 	    !dev_valid_name(buffer) ||
-	    qid > bond->params.tx_queues)
+	    qid > bond->dev->real_num_tx_queues)
 		goto err_no_cmd;
 
 	/* Get the pointer to that interface if it exists */
-- 
1.7.10.4
