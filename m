From: Patrick McHardy <kaber@trash.net>
Subject: [ETHERNET 01/02]: Validate new address in eth_mac_addr
Date: Tue, 19 Jun 2007 15:08:43 +0200 (MEST)
Message-ID: <20070619130826.26769.24481.sendpatchset@localhost.localdomain>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755925AbXFSNIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 09:08:44 -0400
In-Reply-To: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ETHERNET]: Validate new address in eth_mac_addr

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c92ac42cd3badaf120e97223ac4798abf5226424
tree 824d080a4748fcd6f025bbe7b9466feee46e3303
parent 45da27ba265dba3c740c45d47f584c30d7066f82
author Patrick McHardy <kaber@trash.net> Mon, 18 Jun 2007 16:15:32 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 18 Jun 2007 16:15:32 +0200

 net/ethernet/eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 0ac2524..9298a2c 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -266,8 +266,11 @@ void eth_header_cache_update(struct hh_cache *hh, struct net_device *dev,
 static int eth_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
+
 	if (netif_running(dev))
 		return -EBUSY;
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	return 0;
 }
