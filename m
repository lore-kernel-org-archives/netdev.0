From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/6] net: fix vlan_get_size to include vlan_flags size
Date: Thu, 17 Sep 2009 17:57:50 -0700
Message-ID: <20090918005750.25594.17071.stgit@localhost.localdomain>
References: <20090918005708.25594.52575.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:35605
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754232AbZIRA6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 20:58:07 -0400
In-Reply-To: <20090918005708.25594.52575.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Fix vlan_get_size to include vlan->flags.  Currently, the
size of the vlan flags is not included in the nlmsg size.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan_netlink.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 343146e..a915048 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -169,6 +169,7 @@ static size_t vlan_get_size(const struct net_device *dev)
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 
 	return nla_total_size(2) +	/* IFLA_VLAN_ID */
+	       sizeof(struct ifla_vlan_flags) + /* IFLA_VLAN_FLAGS */
 	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
 	       vlan_qos_map_size(vlan->nr_egress_mappings);
 }

