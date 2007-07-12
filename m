From: Ursula.Braun.braunu@de.ibm.com
Subject: [patch 2/2] s390: add barriers to qeth driver
Date: Thu, 12 Jul 2007 09:51:01 +0200
Message-ID: <20070712075327.445441000@linux.vnet.ibm.com>
References: <20070712075059.579991000@linux.vnet.ibm.com>
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	Frank Pavlic <fpavlic@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:25345 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758157AbXGLHxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 03:53:30 -0400
Content-Disposition: inline; filename=703-qeth-barriers.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Add barrier to loop where atomic variable is evaluated.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |    1 +
 1 files changed, 1 insertion(+)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -1935,6 +1935,7 @@ qeth_send_control_data(struct qeth_card 
 			atomic_inc(&reply->received);
 			wake_up(&reply->wait_q);
 		}
+		cpu_relax();
 	};
 	rc = reply->rc;
 	qeth_put_reply(reply);

-- 
