From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 04/11] net: add NETIF_F_FCOE_CRC to can_checksum_protocol
Date: Fri, 27 Feb 2009 14:06:54 -0800
Message-ID: <20090227220654.4987.56050.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add FC CRC offload check for ETH_P_FCOE.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a17e006..aad4763 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1457,7 +1457,9 @@ static bool can_checksum_protocol(unsigned long features, __be16 protocol)
 		((features & NETIF_F_IP_CSUM) &&
 		 protocol == htons(ETH_P_IP)) ||
 		((features & NETIF_F_IPV6_CSUM) &&
-		 protocol == htons(ETH_P_IPV6)));
+		 protocol == htons(ETH_P_IPV6)) ||
+		((features & NETIF_F_FCOE_CRC) &&
+		 protocol == htons(ETH_P_FCOE)));
 }
 
 static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)

