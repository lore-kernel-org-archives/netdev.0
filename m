From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH] ethtool: __ethtool_set_sg: check for function pointer
 before using it
Date: Thu, 17 Mar 2011 17:37:21 +0100
Message-ID: <20110317163720.GA26284@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail12.bluewin.ch ([195.186.19.61]:58602 "EHLO
	mail12.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572Ab1CQQhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 12:37:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ethtool_set_sg does not check if dev->ethtool_ops->set_sg is defined
which can result in a NULL pointer dereference when ethtool is used to
change SG settings for drivers without SG support.

Signed-off-by: Roger Luethi <rl@hellgate.ch>
---

Bug verified. Patch only compile-tested.

 net/core/ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..a1086fb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1457,6 +1457,9 @@ static int __ethtool_set_sg(struct net_device *dev, u32 data)
 {
 	int err;
 
+	if (!dev->ethtool_ops->set_sg)
+		return -EOPNOTSUPP;
+
 	if (data && !(dev->features & NETIF_F_ALL_CSUM))
 		return -EINVAL;
 
-- 
1.7.3.4

