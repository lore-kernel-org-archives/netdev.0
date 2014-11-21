From: roopa@cumulusnetworks.com
Subject: [RFC PATCH 2/4] netdev: new feature flag NETIF_F_HW_OFFLOAD to indicate netdev object offload to hardware
Date: Fri, 21 Nov 2014 14:49:28 -0800
Message-ID: <1416610170-21224-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shrijeet@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36855 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbaKUWti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:49:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds a new NETIF_F_HW_OFFLOAD feature flag to offload logical
interfaces to hw.

Useful in cases of bridges, bonds etc where you want to offload the
logical interface attributes to hw.
---
 include/linux/netdev_features.h |    1 +
 net/core/rtnetlink.c            |    7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 8e30685..09da213 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -66,6 +66,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
+	NETIF_F_HW_OFFLOAD,			/* generic hw offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f839354..97b8f48 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2106,6 +2106,13 @@ replay:
 			goto out;
 		}
 
+		/*
+		 * If the newlink request came in with a HW_OFFLOAD
+		 * flag, then set hw offload feature flag
+		 */
+		if (nlh->nlmsg_flags & NLM_F_HW_OFFLOAD)
+			dev->features |= NETIF_F_HW_OFFLOAD;
+
 		dev->ifindex = ifm->ifi_index;
 
 		if (ops->newlink) {
-- 
1.7.10.4
