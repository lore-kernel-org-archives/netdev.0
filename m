From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] be2net: get rid of be_get_stats()
Date: Tue, 24 Aug 2010 17:18:22 +0200
Message-ID: <1282663102.2477.253.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Somnath K <somnathk@serverengines.com>,
	Ajit Khaparde <ajitk@serverengines.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45024 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185Ab0HXPS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 11:18:28 -0400
Received: by wwe15 with SMTP id 15so2027799wwe.1
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 08:18:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers can avoid implementing ndo_get_stats method if using netdevice
stats structure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/benet/be_main.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 74e146f..b89bae0 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -365,11 +365,6 @@ static void be_rx_eqd_update(struct be_adapter *adapter)
 	rx_eq->cur_eqd = eqd;
 }
 
-static struct net_device_stats *be_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
 static u32 be_calc_rate(u64 bytes, unsigned long ticks)
 {
 	u64 rate = bytes;
@@ -2399,7 +2394,6 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
 	.ndo_start_xmit		= be_xmit,
-	.ndo_get_stats		= be_get_stats,
 	.ndo_set_rx_mode	= be_set_multicast_list,
 	.ndo_set_mac_address	= be_mac_addr_set,
 	.ndo_change_mtu		= be_change_mtu,


