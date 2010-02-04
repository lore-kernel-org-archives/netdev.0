From: leitao@linux.vnet.ibm.com
Subject: [PATCH 1/2] qlge: removing unreachable block of code
Date: Thu,  4 Feb 2010 14:11:18 -0600
Message-ID: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:55733 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab0BDUM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 15:12:58 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp01.br.ibm.com (8.14.3/8.13.1) with ESMTP id o14KL2CC021172
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:21:02 -0200
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o14KCuUU3768568
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 17:12:56 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o14KCtah030916
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:12:55 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the qlge_change_mtu() is never called if the new_mtu is
equal current MTU, due this condition on dev_set_mtu():

        if (new_mtu == dev->mtu)
                return 0;

So, this block of code is never reached and is being removed.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7e00029..c583fb5 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4123,9 +4123,6 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 		QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
 	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
-	} else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
-		   (ndev->mtu == 9000 && new_mtu == 9000)) {
-		return 0;
 	} else
 		return -EINVAL;
 
-- 
1.6.0.2

