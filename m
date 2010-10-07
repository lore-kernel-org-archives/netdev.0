From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] ehea: simplify conditional
Date: Fri, 8 Oct 2010 01:14:50 +0200
Message-ID: <20101008011450.0126ffc0@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:57767 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751100Ab0JGXYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 19:24:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify: ((a && b) || (!a && !b)) => (a == b)

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 drivers/net/ehea/ehea_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 190fb69..ef305f3 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1914,7 +1914,7 @@ static void ehea_promiscuous(struct net_device *dev, int enable)
 	struct hcp_ehea_port_cb7 *cb7;
 	u64 hret;
 
-	if ((enable && port->promisc) || (!enable && !port->promisc))
+	if (enable == port->promisc)
 		return;
 
 	cb7 = (void *)get_zeroed_page(GFP_ATOMIC);
-- 
1.7.2.2
