From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 2/5] qeth: no write permission for readonly sysattr
Date: Fri, 18 Sep 2015 16:06:49 +0200
Message-ID: <1442585212-58347-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Lakhvich Dmitriy <ldmitriy@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:33785 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754AbbIROHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:07:04 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 18 Sep 2015 15:07:02 +0100
In-Reply-To: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lakhvich Dmitriy <ldmitriy@ru.ibm.com>

User is not allowed to write into bridge_state sysfs file.
Fixed attribute not mislead the user

Signed-off-by: Lakhvich Dmitriy <ldmitriy@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reported-by: Peter Oberparleiter <oberpar@linux.vnet.ibm.com>
Reviewed-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Reviewed-by: Thomas Richter <tmricht@de.ibm.com>
---
 drivers/s390/net/qeth_l2_sys.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index 52673cd..692db49 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -109,7 +109,7 @@ static ssize_t qeth_bridge_port_state_show(struct device *dev,
 	return qeth_bridge_port_role_state_show(dev, attr, buf, 1);
 }
 
-static DEVICE_ATTR(bridge_state, 0644, qeth_bridge_port_state_show,
+static DEVICE_ATTR(bridge_state, 0444, qeth_bridge_port_state_show,
 		   NULL);
 
 static ssize_t qeth_bridgeport_hostnotification_show(struct device *dev,
-- 
2.3.8
