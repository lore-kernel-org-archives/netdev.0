From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/42] atm: he: Fix undefined sequence points.
Date: Sun, 17 Apr 2011 17:32:38 -0700 (PDT)
Message-ID: <20110417.173238.71114652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752429Ab1DRAdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8883F24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


GCC complains in these queue index operations because we
perform operations of the form:

	x = some_operation(++x);

which is undefined.  Replace with:

	x = some_operation(x + 1);

which is well defined and provides the intended operation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/he.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 6cf59bf..9a51df4 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1801,7 +1801,7 @@ return_host_buffers:
 next_rbrq_entry:
 		he_dev->rbrq_head = (struct he_rbrq *)
 				((unsigned long) he_dev->rbrq_base |
-					RBRQ_MASK(++he_dev->rbrq_head));
+					RBRQ_MASK(he_dev->rbrq_head + 1));
 
 	}
 	read_unlock(&vcc_sklist_lock);
@@ -1884,7 +1884,7 @@ next_tbrq_entry:
 			pci_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
 		he_dev->tbrq_head = (struct he_tbrq *)
 				((unsigned long) he_dev->tbrq_base |
-					TBRQ_MASK(++he_dev->tbrq_head));
+					TBRQ_MASK(he_dev->tbrq_head + 1));
 	}
 
 	if (updated) {
-- 
1.7.4.3

