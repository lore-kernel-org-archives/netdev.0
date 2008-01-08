From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7]: [NETXEN]: Fix ->poll() done logic.
Date: Mon, 07 Jan 2008 21:39:26 -0800 (PST)
Message-ID: <20080107.213926.78909697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbYAHFj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:39:27 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E3D8FC8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:39:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NETXEN]: Fix ->poll() done logic.

If work_done >= budget we should always elide the NAPI
completion.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index a80f0cd..454226f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1321,7 +1321,7 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 						     budget / MAX_RCV_CTX);
 	}
 
-	if (work_done >= budget && netxen_nic_rx_has_work(adapter) != 0)
+	if (work_done >= budget)
 		done = 0;
 
 	if (netxen_process_cmd_ring((unsigned long)adapter) == 0)
-- 
1.5.4.rc2.38.gd6da3

