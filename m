From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 2/3] net: remove check for headroom in
	vlan_dev_create
Date: Sat, 30 Oct 2010 17:22:37 -0700
Message-ID: <20101031002237.8691.6266.stgit@jf-dev1-dcblab>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9812 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921Ab0JaAYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 20:24:52 -0400
In-Reply-To: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for the headroom to be smaller then the
hard_header_len for a short period of time after toggling
the vlan offload setting.

This is not a hard error and skb_cow_head is called in
__vlan_put_tag() to resolve this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan_dev.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 14e3d1f..afb03c5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -274,9 +274,6 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	u16 vlan_tci = 0;
 	int rc;
 
-	if (WARN_ON(skb_headroom(skb) < dev->hard_header_len))
-		return -ENOSPC;
-
 	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
 

