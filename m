From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 1/3] net: init_vlan should not copy slave or master flags
Date: Thu, 13 May 2010 00:31:06 -0700
Message-ID: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: andy@greyhouse.net, fubar@us.ibm.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50345 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755316Ab0EMHae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 03:30:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan device should not copy the slave or master flags from
the real device. It is not in the bond until added nor is it
a master.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan_dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b5249c5..c13d8a3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -708,7 +708,8 @@ static int vlan_dev_init(struct net_device *dev)
 	netif_carrier_off(dev);
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI);
+	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
+					  IFF_MASTER | IFF_SLAVE);
 	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |

