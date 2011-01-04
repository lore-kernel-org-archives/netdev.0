From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH] ethtool: update get_rx_ntuple to correctly
	interpret string count
Date: Tue, 04 Jan 2011 15:29:48 -0800
Message-ID: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36425 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014Ab1ADX3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 18:29:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently any strings returned via the get_rx_ntuple call will just be
dropped because the num_strings will be zero.  In order to correct this I
am updating things so that the return value of get_rx_ntuple is the number
of strings that were written, or a negative value if there was an error.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1774178..7ade13b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -587,6 +587,9 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 	if (ops->get_rx_ntuple) {
 		/* driver-specific filter grab */
 		ret = ops->get_rx_ntuple(dev, gstrings.string_set, data);
+		if (ret < 0)
+			goto out;
+		num_strings = ret;
 		goto copy;
 	}
 

