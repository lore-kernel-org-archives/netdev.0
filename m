From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4]: sunlance: Convert to net_device_ops.
Date: Mon, 23 Mar 2009 14:29:35 -0700 (PDT)
Message-ID: <20090323.142935.50392320.davem@davemloft.net>
References: <20090323.134719.234362924.davem@davemloft.net>
	<20090323140303.0eeb3844@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32790
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757269AbZCWV3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 17:29:48 -0400
In-Reply-To: <20090323140303.0eeb3844@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 23 Mar 2009 14:03:03 -0700

> You need to add the three entries that ether_setup() was doing
> in the old code:
> 	.ndo_change_mtu		= eth_change_mtu,
> 	.ndo_set_mac_address	= eth_mac_addr,
> 	.ndo_validate_addr	= eth_validate_addr,

Thanks for catching that, I've fixed them all up.

myri_sbus/sunbmac/sunlance/sunqe: Add missing net_device_ops entries.

Noticed by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/myri_sbus.c |    2 ++
 drivers/net/sunbmac.c   |    3 +++
 drivers/net/sunlance.c  |    3 +++
 drivers/net/sunqe.c     |    3 +++
 4 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 4ced27f..08534c0 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -903,6 +903,8 @@ static const struct net_device_ops myri_ops = {
 	.ndo_set_multicast_list	= myri_set_multicast,
 	.ndo_tx_timeout		= myri_tx_timeout,
 	.ndo_change_mtu		= myri_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
 };
 
 static int __devinit myri_sbus_probe(struct of_device *op, const struct of_device_id *match)
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 70d96b7..5017d7f 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1081,6 +1081,9 @@ static const struct net_device_ops bigmac_ops = {
 	.ndo_get_stats		= bigmac_get_stats,
 	.ndo_set_multicast_list	= bigmac_set_multicast,
 	.ndo_tx_timeout		= bigmac_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
 };
 
 static int __devinit bigmac_ether_init(struct of_device *op,
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 3a2bb96..afc7b35 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1317,6 +1317,9 @@ static const struct net_device_ops sparc_lance_ops = {
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_set_multicast_list	= lance_set_multicast,
 	.ndo_tx_timeout		= lance_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
 };
 
 static int __devinit sparc_lance_probe_one(struct of_device *op,
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index dd4757d..c6ec61e 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -835,6 +835,9 @@ static const struct net_device_ops qec_ops = {
 	.ndo_start_xmit		= qe_start_xmit,
 	.ndo_set_multicast_list	= qe_set_multicast,
 	.ndo_tx_timeout		= qe_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
 };
 
 static int __devinit qec_ether_init(struct of_device *op)
-- 
1.6.2.1.222.g570cc

