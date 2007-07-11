From: Patrick McHardy <kaber@trash.net>
Subject: [ETH 01/04]: Validate address in eth_mac_addr
Date: Wed, 11 Jul 2007 19:38:14 +0200 (MEST)
Message-ID: <20070711173814.18369.53719.sendpatchset@localhost.localdomain>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58341 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757692AbXGKRiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:38:16 -0400
In-Reply-To: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ETH]: Validate address in eth_mac_addr

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 690fb4dbafa9f60f8cb520d5def544580107b3a4
tree ded62c0fcd8497b5cf9459213e1579cc700abb39
parent 99d24edeb6abc6ca3a0d0fbdb83c664c04403c8c
author Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:23:22 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:23:22 +0200

 net/ethernet/eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 1387e54..12c7657 100644
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
+		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	return 0;
 }
