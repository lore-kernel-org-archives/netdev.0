From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/5] drivers/net: remove duplicate structure field initialization
Date: Sat, 19 Sep 2009 21:48:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909192148180.27171@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752381AbZISTsm@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The definitions of vnet_ops and ehea_netdev_ops have initializations of a
local function and eth_change_mtu for their respective ndo_change_mtu
fields.  This change uses only the local function.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier I, s, fld;
position p0,p;
expression E;
@@

struct I s =@p0 { ... .fld@p = E, ...};

@s@
identifier I, s, r.fld;
position r.p0,p;
expression E;
@@

struct I s =@p0 { ... .fld@p = E, ...};

@script:python@
p0 << r.p0;
fld << r.fld;
ps << s.p;
pr << r.p;
@@

if int(ps[0].line)!=int(pr[0].line) or int(ps[0].column)!=int(pr[0].column):
  cocci.print_main(fld,p0)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/ehea/ehea_main.c |    1 -
 drivers/net/sunvnet.c        |    1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index f1e5e45..bc74db0 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1016,7 +1016,6 @@ static const struct net_device_ops vnet_ops = {
 	.ndo_open		= vnet_open,
 	.ndo_stop		= vnet_close,
 	.ndo_set_multicast_list	= vnet_set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= vnet_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= vnet_tx_timeout,
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 977c3d3..41bd7ae 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3083,7 +3083,6 @@ static const struct net_device_ops ehea_netdev_ops = {
 	.ndo_poll_controller	= ehea_netpoll,
 #endif
 	.ndo_get_stats		= ehea_get_stats,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= ehea_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= ehea_set_multicast_list,
