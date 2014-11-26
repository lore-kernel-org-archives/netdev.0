From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next] ipvlan: fix sparse warnings
Date: Tue, 25 Nov 2014 21:24:43 -0800
Message-ID: <1416979483-30610-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:44460 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaKZFYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 00:24:48 -0500
Received: by mail-yh0-f74.google.com with SMTP id 29so125847yhl.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 21:24:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix sparse warnings reported by kbuild robot

drivers/net/ipvlan/ipvlan_main.c:172:13: warning: symbol 'ipvlan_start_xmit' was not declared. Should it be static?
drivers/net/ipvlan/ipvlan_main.c:256:33: warning: incorrect type in initializer (different address spaces)
drivers/net/ipvlan/ipvlan_main.c:256:33:    expected void const [noderef] <asn:3>*__vpp_verify
drivers/net/ipvlan/ipvlan_main.c:256:33:    got struct ipvl_pcpu_stats *<noident>
drivers/net/ipvlan/ipvlan_main.c:544:5: warning: symbol 'ipvlan_link_register' was not declared. Should it be static

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c3df84bd2857..96b71b0d78f6 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -169,7 +169,8 @@ static int ipvlan_stop(struct net_device *dev)
 	return 0;
 }
 
-netdev_tx_t ipvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipvlan_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
 	int skblen = skb->len;
@@ -541,7 +542,7 @@ static struct rtnl_link_ops ipvlan_link_ops = {
 	.dellink	= ipvlan_link_delete,
 };
 
-int ipvlan_link_register(struct rtnl_link_ops *ops)
+static int ipvlan_link_register(struct rtnl_link_ops *ops)
 {
 	return rtnl_link_register(ops);
 }
-- 
2.2.0.rc0.207.ga3a616c
