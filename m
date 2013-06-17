From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1@lab.ntt.co.jp>
Subject: [PATCH] vlan: restore ethtool ABI to control VLAN hardware
 acceleration
Date: Mon, 17 Jun 2013 11:28:03 +0900
Message-ID: <1371436083.7579.1.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:59008 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284Ab3FQDOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 23:14:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of the push to add 802.1ad server provider tagging support to the
kernel the VLAN features flags were renamed. Unfortunately the kernel name
for the VLAN hardware acceleration features that the kernel shows user space
was included in the rename, which broke ethtool (txvlan and rxvlan options
do not work). This patch restores the original names, i.e. the original ABI.
If we wanted to make clear to users that we are refering to CTAGs we can
always change ethtool's short_name and long_name for these features (for
example something along the lines of txvlan -> txvlan-ctag, tx-vlan-offload ->
tx-vlan-ctag-offload).

Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-3.10-rc5-orig/net/core/ethtool.c linux-3.10-rc5/net/core/ethtool.c
--- linux-3.10-rc5-orig/net/core/ethtool.c	2013-06-09 09:41:04.000000000 +0900
+++ linux-3.10-rc5/net/core/ethtool.c	2013-06-14 23:08:22.330454778 +0900
@@ -60,10 +60,10 @@ static const char netdev_features_string
 	[NETIF_F_IPV6_CSUM_BIT] =        "tx-checksum-ipv6",
 	[NETIF_F_HIGHDMA_BIT] =          "highdma",
 	[NETIF_F_FRAGLIST_BIT] =         "tx-scatter-gather-fraglist",
-	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =  "tx-vlan-ctag-hw-insert",
+	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =  "tx-vlan-hw-insert",
 
-	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-ctag-hw-parse",
-	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-ctag-filter",
+	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-hw-parse",
+	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-filter",
 	[NETIF_F_HW_VLAN_STAG_TX_BIT] =  "tx-vlan-stag-hw-insert",
 	[NETIF_F_HW_VLAN_STAG_RX_BIT] =  "rx-vlan-stag-hw-parse",
 	[NETIF_F_HW_VLAN_STAG_FILTER_BIT] = "rx-vlan-stag-filter",
