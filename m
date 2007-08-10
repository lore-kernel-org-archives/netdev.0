From: akpm@linux-foundation.org
Subject: [patch 16/18] net/tulip/xircom_cb.c: remove superfulous priv assignment
Date: Fri, 10 Aug 2007 14:05:25 -0700
Message-ID: <200708102105.l7AL5Qmp008992@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	m.kozlowski@tuxland.pl, arjan@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36579 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760511AbXHJVQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

It does

dev = alloc_etherdev(...
private = netdev_priv(dev);
...
dev->priv = private;

which doesn't make much sense (does it?) because this is done in
alloc_netdev() already.

struct net_device *alloc_netdev(...
{
...
	if (sizeof_priv)
		dev->priv = netdev_priv(dev);

This patch removes superfluous code.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Acked-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/xircom_cb.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/net/tulip/xircom_cb.c~net-tulip-xircom_cbc-remove-superfulous-priv-assignment drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c~net-tulip-xircom_cbc-remove-superfulous-priv-assignment
+++ a/drivers/net/tulip/xircom_cb.c
@@ -271,7 +271,6 @@ static int __devinit xircom_probe(struct
 	dev->hard_start_xmit = &xircom_start_xmit;
 	dev->stop = &xircom_close;
 	dev->get_stats = &xircom_get_stats;
-	dev->priv = private;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = &xircom_poll_controller;
 #endif
_
