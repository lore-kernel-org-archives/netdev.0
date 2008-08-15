From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: show offload settings
Date: Fri, 15 Aug 2008 16:50:51 -0700
Message-ID: <20080815165051.25463705@extreme>
References: <20080815100259.12c8175a@extreme>
	<20080815.145118.198768799.davem@davemloft.net>
	<10558.1218841183@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59876 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922AbYHOXux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 19:50:53 -0400
In-Reply-To: <10558.1218841183@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the correct patch to add more offload settings for bridge.
Earlier was the bonding one (sorry).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_device.c	2008-08-14 12:14:57.000000000 -0700
+++ b/net/bridge/br_device.c	2008-08-14 12:18:10.000000000 -0700
@@ -148,11 +148,16 @@ static int br_set_tx_csum(struct net_dev
 }
 
 static struct ethtool_ops br_ethtool_ops = {
-	.get_drvinfo = br_getinfo,
-	.get_link = ethtool_op_get_link,
-	.set_sg = br_set_sg,
-	.set_tx_csum = br_set_tx_csum,
-	.set_tso = br_set_tso,
+	.get_drvinfo    = br_getinfo,
+	.get_link	= ethtool_op_get_link,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum 	= br_set_tx_csum,
+	.get_sg		= ethtool_op_get_sg,
+	.set_sg		= br_set_sg,
+	.get_tso	= ethtool_op_get_tso,
+	.set_tso	= br_set_tso,
+	.get_ufo	= ethtool_op_get_ufo,
+	.get_flags	= ethtool_op_get_flags,
 };
 
 void br_dev_setup(struct net_device *dev)
