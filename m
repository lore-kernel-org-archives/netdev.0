From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when enabling
 ip_forward
Date: Mon, 18 May 2009 15:57:14 -0700
Message-ID: <20090518155714.0f1a3b20@nehalam>
References: <20090519010147.772f0bff@vingilot.sergknet>
	<20090518.153531.126023429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: sergk@sergk.org.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51554 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083AbZERW5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 18:57:19 -0400
In-Reply-To: <20090518.153531.126023429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does this fix it?

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 4bdfc2e..a425d85 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -2028,6 +2028,10 @@ static struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
+#ifdef CONFIG_IGB_LRO
+	.get_flags		= ethtool_op_get_flags,
+	.set_flags		= ethtool_op_set_flags,
+#endif
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
