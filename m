From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 01/10] ethtool: prevent null pointer dereference
	with NTUPLE set but no set_rx_ntuple
Date: Fri, 25 Feb 2011 15:32:44 -0800
Message-ID: <20110225233244.7920.26742.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63658 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932815Ab1BYXcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:32:45 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
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
 

