From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 13/14] ethtool: Ethtool parameter to dynamically change tx_copybreak
Date: Mon,  6 Oct 2014 09:16:02 +0300
Message-ID: <1412576163-7224-14-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:57232 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751680AbaJFGRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:17:04 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use new ethtool [sg]et_tunable() to set tx_copybread (inline threshold)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/uapi/linux/ethtool.h | 1 +
 net/core/ethtool.c           | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 7a364f2..99b4305 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -212,6 +212,7 @@ struct ethtool_value {
 enum tunable_id {
 	ETHTOOL_ID_UNSPEC,
 	ETHTOOL_RX_COPYBREAK,
+	ETHTOOL_TX_COPYBREAK,
 };
 
 enum tunable_type_id {
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 27e61b8..1600aa2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1625,6 +1625,7 @@ static int ethtool_tunable_valid(const struct ethtool_tunable *tuna)
 {
 	switch (tuna->id) {
 	case ETHTOOL_RX_COPYBREAK:
+	case ETHTOOL_TX_COPYBREAK:
 		if (tuna->len != sizeof(u32) ||
 		    tuna->type_id != ETHTOOL_TUNABLE_U32)
 			return -EINVAL;
-- 
1.8.3.1
