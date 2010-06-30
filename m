From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/3] vmxnet3: Remove incorrect implementation
 of ethtool_ops::get_flags()
Date: Wed, 30 Jun 2010 13:47:40 +0100
Message-ID: <1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:58742 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab0F3Mrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 08:47:43 -0400
In-Reply-To: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only some netdev feature flags correspond directly to ethtool feature
flags.  ethtool_op_get_flags() does the right thing.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 8a71a21..de1ba14 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -275,12 +275,6 @@ vmxnet3_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
 	}
 }
 
-static u32
-vmxnet3_get_flags(struct net_device *netdev)
-{
-	return netdev->features;
-}
-
 static int
 vmxnet3_set_flags(struct net_device *netdev, u32 data)
 {
@@ -559,7 +553,7 @@ static struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_tso           = ethtool_op_get_tso,
 	.set_tso           = ethtool_op_set_tso,
 	.get_strings       = vmxnet3_get_strings,
-	.get_flags	   = vmxnet3_get_flags,
+	.get_flags	   = ethtool_op_get_flags,
 	.set_flags	   = vmxnet3_set_flags,
 	.get_sset_count	   = vmxnet3_get_sset_count,
 	.get_ethtool_stats = vmxnet3_get_ethtool_stats,
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

