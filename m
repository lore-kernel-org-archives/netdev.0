From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 3/4] ethtool: add RX_ALLOC_ORDER to tunable
Date: Sat, 31 Jan 2015 17:58:09 +0530
Message-ID: <1422707290-939-4-git-send-email-_govind@gmx.com>
References: <1422707290-939-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com, edumazet@google.com,
	ben@decadent.org.uk, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:55611 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbbAaM31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2015 07:29:27 -0500
In-Reply-To: <1422707290-939-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/uapi/linux/ethtool.h | 1 +
 net/core/ethtool.c           | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f66d9c..59362f8 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -213,6 +213,7 @@ enum tunable_id {
 	ETHTOOL_ID_UNSPEC,
 	ETHTOOL_RX_COPYBREAK,
 	ETHTOOL_TX_COPYBREAK,
+	ETHTOOL_RX_ALLOC_ORDER,
 };
 
 enum tunable_type_id {
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91f74f3..5fd7ebf 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1670,6 +1670,11 @@ static int ethtool_tunable_valid(const struct ethtool_tunable *tuna)
 		    tuna->type_id != ETHTOOL_TUNABLE_U32)
 			return -EINVAL;
 		break;
+	case ETHTOOL_RX_ALLOC_ORDER:
+		if (tuna->len != sizeof(u8) ||
+		    tuna->type_id != ETHTOOL_TUNABLE_U8)
+			return -EINVAL;
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
2.2.2
