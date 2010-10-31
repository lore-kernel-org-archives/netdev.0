From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 1/3] 8021q: set hard_header_len when VLAN offload
	features are toggled
Date: Sat, 30 Oct 2010 17:22:32 -0700
Message-ID: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53425 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab0JaAYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 20:24:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
This results in pskb_expand_head() being used unnecessarily.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 05b867e..cb78b99 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -334,6 +334,12 @@ static void vlan_transfer_features(struct net_device *dev,
 	vlandev->features &= ~dev->vlan_features;
 	vlandev->features |= dev->features & dev->vlan_features;
 	vlandev->gso_max_size = dev->gso_max_size;
+
+	if (dev->features & NETIF_F_HW_VLAN_TX)
+		vlandev->hard_header_len = dev->hard_header_len;
+	else
+		vlandev->hard_header_len = dev->hard_header_len + VLAN_HLEN;
+
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif

