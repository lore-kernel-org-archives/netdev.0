From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 4/8] net: add tc offload feature flag
Date: Mon, 15 Feb 2016 22:01:50 -0800
Message-ID: <20160216060150.32452.39235.stgit@john-Precision-Tower-5810>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: amir@vadai.me, john.fastabend@gmail.com, jhs@mojatatu.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33631 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbcBPGCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 01:02:10 -0500
Received: by mail-pf0-f175.google.com with SMTP id q63so99086149pfb.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 22:02:09 -0800 (PST)
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
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
index 453c803..ab8376a7 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -98,6 +98,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
+	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
 };
 
 static const char
