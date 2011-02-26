From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-2.6 PATCH] ethtool: prevent null pointer dereference with NTUPLE
	set but no set_rx_ntuple
Date: Fri, 25 Feb 2011 16:42:20 -0800
Message-ID: <20110226004220.8793.65076.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9145 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756506Ab1BZAmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 19:42:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to prevent a possible null pointer dereference if
NETIF_F_NTUPLE is defined but the set_rx_ntuple function pointer is not.

This issue appears to affect all kernels since 2.6.34.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..4843674 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -893,6 +893,9 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
 	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
 	int ret;
 
+	if (!ops->set_rx_ntuple)
+		return -EOPNOTSUPP;
+
 	if (!(dev->features & NETIF_F_NTUPLE))
 		return -EINVAL;
 

