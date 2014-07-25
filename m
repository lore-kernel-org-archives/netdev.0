From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH 1/1] neighbour : fix ndm_type type error issue
Date: Sat, 26 Jul 2014 00:38:59 +0800
Message-ID: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Cc: linux-kernel@vger.kernel.org, Jun Zhao <mypopydev@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Francesco Fusco <ffusco@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Pirko <jiri@resnulli.us>,
	David Stevens <dlstevens@us.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:62765 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004AbaGYQkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 12:40:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndm_type means L3 address type, in neighbour proxy and vxlan, it's RTN_UNICAST.
NDA_DST is for netlink TLV type, hence it's not right value in this context.

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 drivers/net/vxlan.c  |    2 +-
 net/core/neighbour.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d3f3e5d..1fb7b37 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -340,7 +340,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	ndm->ndm_state = fdb->state;
 	ndm->ndm_ifindex = vxlan->dev->ifindex;
 	ndm->ndm_flags = fdb->flags;
-	ndm->ndm_type = NDA_DST;
+	ndm->ndm_type = RTN_UNICAST;
 
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 559890b..ef31fef 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2249,7 +2249,7 @@ static int pneigh_fill_info(struct sk_buff *skb, struct pneigh_entry *pn,
 	ndm->ndm_pad1    = 0;
 	ndm->ndm_pad2    = 0;
 	ndm->ndm_flags	 = pn->flags | NTF_PROXY;
-	ndm->ndm_type	 = NDA_DST;
+	ndm->ndm_type	 = RTN_UNICAST;
 	ndm->ndm_ifindex = pn->dev->ifindex;
 	ndm->ndm_state	 = NUD_NONE;
 
-- 
1.7.10.4
