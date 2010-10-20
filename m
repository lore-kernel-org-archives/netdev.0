From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 07/14] ethtool: Add support for vlan accleration.
Date: Wed, 20 Oct 2010 16:56:07 -0700
Message-ID: <1287618974-4714-8-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:52033 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab0JTX4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:34 -0400
Received: by qyk9 with SMTP id 9so1826119qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:33 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that vlan acceleration is handled consistently regardless of usage,
it is possible to enable and disable it at will.  This adds support for
Ethtool operations that change the offloading status for debugging
purposes, similar to other forms of hardware acceleration.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/ethtool.h |    2 ++
 net/core/ethtool.c      |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 8a3338c..6628a50 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -309,6 +309,8 @@ struct ethtool_perm_addr {
  * flag differs from the read-only value.
  */
 enum ethtool_flags {
+	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
+	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 	ETH_FLAG_RXHASH		= (1 << 28),
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 685c700..956a9f4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -132,7 +132,8 @@ EXPORT_SYMBOL(ethtool_op_set_ufo);
  * NETIF_F_xxx values in include/linux/netdevice.h
  */
 static const u32 flags_dup_features =
-	(ETH_FLAG_LRO | ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH);
+	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
+	 ETH_FLAG_RXHASH);
 
 u32 ethtool_op_get_flags(struct net_device *dev)
 {
-- 
1.7.1

