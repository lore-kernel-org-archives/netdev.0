From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net] qed: fix old-style function definition
Date: Fri, 16 Dec 2016 09:47:41 +0100
Message-ID: <20161216084808.1815139-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Arun Easi <arun.easi@cavium.com>,
        Hannes Reinecke <hare@suse.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Thumshirn <jthumshirn@suse.de>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:50020 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752959AbcLPIs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 03:48:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newly added file causes a harmless warning, with "make W=1":

drivers/net/ethernet/qlogic/qed/qed_iscsi.c: In function 'qed_get_iscsi_ops':
drivers/net/ethernet/qlogic/qed/qed_iscsi.c:1268:29: warning: old-style function definition [-Wold-style-definition]

This makes it a proper prototype.

Fixes: fc831825f99e ("qed: Add support for hardware offloaded iSCSI.")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I only saw this after it was already merged for v4.10

 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 00efb1c4c57e..17a70122df05 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -1265,7 +1265,7 @@ static const struct qed_iscsi_ops qed_iscsi_ops_pass = {
 	.get_stats = &qed_iscsi_stats,
 };
 
-const struct qed_iscsi_ops *qed_get_iscsi_ops()
+const struct qed_iscsi_ops *qed_get_iscsi_ops(void)
 {
 	return &qed_iscsi_ops_pass;
 }
-- 
2.9.0
