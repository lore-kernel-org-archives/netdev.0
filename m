From: Brandon Philips <bphilips@suse.de>
Subject: [PATCH] vlan: enable GRO if real_dev supports it
Date: Wed, 15 Sep 2010 09:37:49 -0700
Message-ID: <20100915163749.GA4191@mmm.home.ifup.org>
References: <20100915015052.GA6602@mmm.home.ifup.org>
 <20100914.213544.112598547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33611 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961Ab0IOQli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 12:41:38 -0400
Content-Disposition: inline
In-Reply-To: <20100914.213544.112598547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently vlan devices don't have GRO by default as none of the Ethernet
drivers add NETIF_F_GRO to their vlan_features.

As GRO is a software feature just propogate GRO from the real_dev in the
vlan core. There is no need to have the drivers each add NETIF_F_GRO to
their vlan_features.

Signed-off-by: Brandon Philips <bphilips@suse.de>
---
 net/8021q/vlan_dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3bccdd1..6fbc445 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -735,6 +735,7 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
+	dev->features |= real_dev->features & NETIF_F_GRO;
 	dev->features |= real_dev->features & real_dev->vlan_features;
 	dev->gso_max_size = real_dev->gso_max_size;
 
-- 
1.7.1

