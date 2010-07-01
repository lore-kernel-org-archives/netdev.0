From: leitao@linux.vnet.ibm.com
Subject: [PATCH 2/2] qlge: fix a eeh handler to not add a pending timer
Date: Thu,  1 Jul 2010 10:00:18 -0300
Message-ID: <3d4d609f65c74c269e056c5fbe2fe4b174023059.1277936929.git.root@sanx1002.austin.ibm.com>
References: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>,
	Ron Mercer <ron.mercer@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:38118 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524Ab0GANAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 09:00:25 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o61CwpJo015780
	for <netdev@vger.kernel.org>; Thu, 1 Jul 2010 09:58:51 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o61D0LdR3633238
	for <netdev@vger.kernel.org>; Thu, 1 Jul 2010 10:00:21 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o61D07bj000380
	for <netdev@vger.kernel.org>; Thu, 1 Jul 2010 10:00:08 -0300
In-Reply-To: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
In-Reply-To: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
References: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some ocasions the function qlge_io_resume() tries to add a
pending timer, which causes the system to hit the BUG() on
add_timer() function.

This patch removes the timer during the EEH recovery.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 509dadc..d10bcef 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4712,6 +4712,8 @@ static void ql_eeh_close(struct net_device *ndev)
 		netif_stop_queue(ndev);
 	}
 
+	/* Disabling the timer */
+	del_timer_sync(&qdev->timer);
 	if (test_bit(QL_ADAPTER_UP, &qdev->flags))
 		cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
-- 
1.6.5.2

