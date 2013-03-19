From: frank.blaschka@de.ibm.com
Subject: [patch 1/3] qeth: delay feature trace
Date: Tue, 19 Mar 2013 07:04:42 +0100
Message-ID: <20130319060454.760259160@de.ibm.com>
References: <20130319060441.956271217@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:47718 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933917Ab3CSGFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 02:05:01 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 19 Mar 2013 06:02:53 -0000
Content-Disposition: inline; filename=600-qeth-delay-trace.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Delay tracing of the card features until the optional commands have been
enabled.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3348,7 +3348,6 @@ static int __qeth_l3_set_online(struct c
 		rc = -ENODEV;
 		goto out_remove;
 	}
-	qeth_trace_features(card);
 
 	if (!card->dev && qeth_l3_setup_netdev(card)) {
 		rc = -ENODEV;
@@ -3425,6 +3424,7 @@ contin:
 		qeth_l3_set_multicast_list(card->dev);
 		rtnl_unlock();
 	}
+	qeth_trace_features(card);
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
 	mutex_unlock(&card->conf_mutex);
