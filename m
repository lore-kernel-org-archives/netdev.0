From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/8] qeth: remove locks from sysfs _show
Date: Mon, 18 May 2015 14:27:54 +0200
Message-ID: <1431952079-6847-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39789 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939AbbERM2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:24 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:23 +0100
In-Reply-To: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Locking is probably unnecessary in this case, and the rest of the
qeth sysfs code does not use locks in the *_show() functions.
Remove locks from the layer2 *_show() functions in which they where
accidentally introduced.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l2_sys.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index 59e3aa5..6504d48 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -23,8 +23,6 @@ static ssize_t qeth_bridge_port_role_state_show(struct device *dev,
 	if (!card)
 		return -EINVAL;
 
-	mutex_lock(&card->conf_mutex);
-
 	if (qeth_card_hw_is_reachable(card) &&
 					card->options.sbp.supported_funcs)
 		rc = qeth_bridgeport_query_ports(card,
@@ -59,8 +57,6 @@ static ssize_t qeth_bridge_port_role_state_show(struct device *dev,
 			rc = sprintf(buf, "%s\n", word);
 	}
 
-	mutex_unlock(&card->conf_mutex);
-
 	return rc;
 }
 
@@ -123,12 +119,8 @@ static ssize_t qeth_bridgeport_hostnotification_show(struct device *dev,
 	if (!card)
 		return -EINVAL;
 
-	mutex_lock(&card->conf_mutex);
-
 	enabled = card->options.sbp.hostnotification;
 
-	mutex_unlock(&card->conf_mutex);
-
 	return sprintf(buf, "%d\n", enabled);
 }
 
-- 
2.3.7
