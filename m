From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 3/4] ethtool: can't set combined and tx/rx channel counts at the same time
Date: Mon,  8 Feb 2016 12:06:04 -0800
Message-ID: <1454961965-15116-4-git-send-email-jacob.e.keller@intel.com>
References: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
Cc: mooray3@wp.pl, davem@davemloft.net,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26272 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbcBHUIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 15:08:40 -0500
In-Reply-To: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on reading current implementations of {GS}CHANNELS, most drivers
either support only combined counts or only separate counts. At least
one driver supported setting combined or separate channels. No driver
supported combined and separate channels setting at the same time, and
this patch adds a sanity check to prevent such requests. I am not 100%
sure if this is correct as I was not able to find documentation and
I think it currently depended on driver implementation.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 net/core/ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 71aff99157c3..7d4cef7b7176 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1297,6 +1297,11 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 	    (channels.other_count > max.max_other))
 		return -EINVAL;
 
+	/* can't set combined and separate channels at the same time */
+	if ((channels.combined_count &&
+	     (channels.rx_count || channels.tx_count))
+	    return -EINVAL;
+
 	/* ensure the new Rx count fits within the configured Rx flow
 	 * indirection table settings */
 	if (netif_is_rxfh_configured(dev) &&
-- 
2.7.0.236.gda096a0.dirty
