From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5] net: Check for presence of IFLA_AF_SPEC
Date: Wed, 26 Nov 2014 13:42:18 +0100
Message-ID: <495eced061d109e02b035ad56e56a3de2505ee22.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56885 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaKZMmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:42:31 -0500
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_bridge_setlink() is currently only called on the slave if
IFLA_AF_SPEC is set but this is a very fragile assumption and may
change in the future.

Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/ethernet/emulex/benet/be_main.c   | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 337e4cd..597c463 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4309,6 +4309,8 @@ static int be_ndo_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 		return -EOPNOTSUPP;
 
 	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+	if (!br_spec)
+		return -EINVAL;
 
 	nla_for_each_nested(attr, br_spec, rem) {
 		if (nla_type(attr) != IFLA_BRIDGE_MODE)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index dff9905..cc51554 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7669,6 +7669,8 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 		return -EOPNOTSUPP;
 
 	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+	if (!br_spec)
+		return -EINVAL;
 
 	nla_for_each_nested(attr, br_spec, rem) {
 		__u16 mode;
-- 
1.9.3
