From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] net: Validate IFLA_BRIDGE_MODE attribute length
Date: Wed, 26 Nov 2014 13:42:17 +0100
Message-ID: <4a88a0350064b5c2ec4e2adcef5afdfcab3e45dd.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56857 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaKZMma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:42:30 -0500
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Payload is currently accessed blindly and may exceed valid message
boundaries.

Fixes: a77dcb8c8 ("be2net: set and query VEB/VEPA mode of the PF interface")
Fixes: 815cccbf1 ("ixgbe: add setlink, getlink support to ixgbe and ixgbevf")
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/ethernet/emulex/benet/be_main.c   | 3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3e8475c..337e4cd 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4314,6 +4314,9 @@ static int be_ndo_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 		if (nla_type(attr) != IFLA_BRIDGE_MODE)
 			continue;
 
+		if (nla_len(attr) < sizeof(mode))
+			return -EINVAL;
+
 		mode = nla_get_u16(attr);
 		if (mode != BRIDGE_MODE_VEPA && mode != BRIDGE_MODE_VEB)
 			return -EINVAL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 82ffe8b..dff9905 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7677,6 +7677,9 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 		if (nla_type(attr) != IFLA_BRIDGE_MODE)
 			continue;
 
+		if (nla_len(attr) < sizeof(mode))
+			return -EINVAL;
+
 		mode = nla_get_u16(attr);
 		if (mode == BRIDGE_MODE_VEPA) {
 			reg = 0;
-- 
1.9.3
