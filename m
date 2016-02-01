From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 4/7] net: add tc offload feature flag
Date: Sun, 31 Jan 2016 17:51:00 -0800
Message-ID: <20160201015100.13871.43218.stgit@john-Precision-Tower-5810>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, donald.c.skidmore@intel.com, horms@verge.net.au,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33405 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933350AbcBABvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 20:51:41 -0500
Received: by mail-pa0-f68.google.com with SMTP id pv5so6500930pac.0
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 17:51:41 -0800 (PST)
In-Reply-To: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its useful to turn off the qdisc offload feature at a per device
level. This gives us a big hammer to enable/disable offloading.
More fine grained control (i.e. per rule) may be supported later.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdev_features.h |    3 +++
 net/core/ethtool.c              |    1 +
 2 files changed, 4 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d9654f0e..a734bf4 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -67,6 +67,8 @@ enum {
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
 
+	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
+
 	/*
 	 * Add your fresh new feature above and remember to update
 	 * netdev_features_strings[] in net/core/ethtool.c and maybe
@@ -124,6 +126,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
+#define NETIF_F_HW_TC		__NETIF_F(HW_TC)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 09948a7..bd8e157a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -98,6 +98,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
+	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
 };
 
 static const char
