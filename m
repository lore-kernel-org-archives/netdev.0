From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] [PATCH] qeth: allow change of blkt default values
Date: Mon, 23 Apr 2012 09:21:41 +0200
Message-ID: <20120423072158.536697678@de.ibm.com>
References: <20120423072140.297458261@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:37378 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab2DWHW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 03:22:26 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 23 Apr 2012 08:22:24 +0100
Content-Disposition: inline; filename=600-qeth-blkt-default.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

There exist qeth sysfs blkt attributes to change the default blkt
values. But blkt changes are reset during online setting due to a 2nd
invocation of qeth_determine_capabilites(). This patch makes sure
blkt default values are configured during 1st run of 
qeth_determine_capabilities() only. Thus blkt changes are kept
during online setting.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reported-by: Horst Hartmann <horst.hartmann@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4540,7 +4540,8 @@ static void qeth_determine_capabilities(
 		goto out_offline;
 	}
 	qeth_configure_unitaddr(card, prcd);
-	qeth_configure_blkt_default(card, prcd);
+	if (ddev_offline)
+		qeth_configure_blkt_default(card, prcd);
 	kfree(prcd);
 
 	rc = qdio_get_ssqd_desc(ddev, &card->ssqd);
