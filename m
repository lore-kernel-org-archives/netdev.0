From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 1/2] ethtool: prevent null pointer dereference
	with NTUPLE set but no set_rx_ntuple
Date: Fri, 08 Apr 2011 15:07:22 -0700
Message-ID: <20110408220722.25468.98089.stgit@gitlad.jf.intel.com>
References: <20110408220410.25468.49130.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10008 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757130Ab1DHWHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:07:24 -0400
In-Reply-To: <20110408220410.25468.49130.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to prevent a possible null pointer dereference if
NETIF_F_NTUPLE is defined but the set_rx_ntuple function pointer is not.

The main motivation behind this patch is to eventually replace the ntuple
interfaces entirely with the network flow classifier interfaces.  This
allows the device drivers to maintain the ntuple check internally while
using the network flow classifier interface for setting up and displaying
rules.
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1b7fa98..704e176 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -910,6 +910,9 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
 	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
 	int ret;
 
+	if (!ops->set_rx_ntuple)
+		return -EOPNOTSUPP;
+
 	if (!(dev->features & NETIF_F_NTUPLE))
 		return -EINVAL;
 

