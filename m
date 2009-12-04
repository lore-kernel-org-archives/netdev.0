From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/2] atm: [he] adjust tests to account for sk_wmem_alloc changes
Date: Fri, 04 Dec 2009 10:22:17 -0500
Message-ID: <200912041522.nB4FMHgq028277@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:57005 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbZLDPe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 10:34:26 -0500
Received: from cmf.nrl.navy.mil (thirdoffive.cmf.nrl.navy.mil [134.207.12.180])
	by hedwig.cmf.nrl.navy.mil (8.14.2/8.14.2) with ESMTP id nB4FMHTd031388
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 10:22:18 -0500
Received: from thirdoffive.cmf.nrl.navy.mil (chas@localhost)
	by cmf.nrl.navy.mil (8.14.3/8.14.3/Submit) with ESMTP id nB4FMHgq028277
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 10:22:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

atm: [he] adjust tests to account for sk_wmem_alloc changes

due to reference counting sk_wmem_alloc now has a value of 1 when all
the outstanding data has been sent.

Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 7066703..d744d62 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2505,7 +2505,7 @@ he_close(struct atm_vcc *vcc)
 		 * TBRQ, the host issues the close command to the adapter.
 		 */
 
-		while (((tx_inuse = atomic_read(&sk_atm(vcc)->sk_wmem_alloc)) > 0) &&
+		while (((tx_inuse = atomic_read(&sk_atm(vcc)->sk_wmem_alloc)) > 1) &&
 		       (retry < MAX_RETRY)) {
 			msleep(sleep);
 			if (sleep < 250)
@@ -2514,7 +2514,7 @@ he_close(struct atm_vcc *vcc)
 			++retry;
 		}
 
-		if (tx_inuse)
+		if (tx_inuse > 1)
 			hprintk("close tx cid 0x%x tx_inuse = %d\n", cid, tx_inuse);
 
 		/* 2.3.1.1 generic close operations with flush */
