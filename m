From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/4] dcbnl: Adjust five checks for null pointers
Date: Sat, 28 Jan 2017 10:36:28 +0100
Message-ID: <72caef1b-f525-2942-4c29-ea2976157ad6@users.sourceforge.net>
References: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Jan 2017 09:56:36 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script "checkpatch.pl" pointed information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/dcb/dcbnl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index f29e19d962ec..0903081a1212 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -398,7 +398,7 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 		return ret;
 
 	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
-		if (data[i] == NULL)
+		if (!data[i])
 			continue;
 
 		value = nla_get_u8(data[i]);
@@ -741,7 +741,7 @@ static int dcbnl_setpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		return ret;
 
 	for (i = DCB_PFC_UP_ATTR_0; i <= DCB_PFC_UP_ATTR_7; i++) {
-		if (data[i] == NULL)
+		if (!data[i])
 			continue;
 		value = nla_get_u8(data[i]);
 		netdev->dcbnl_ops->setpfccfg(netdev,
@@ -955,7 +955,7 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		return ret;
 
 	for (i = DCB_BCN_ATTR_RP_0; i <= DCB_BCN_ATTR_RP_7; i++) {
-		if (data[i] == NULL)
+		if (!data[i])
 			continue;
 		value_byte = nla_get_u8(data[i]);
 		netdev->dcbnl_ops->setbcnrp(netdev,
@@ -963,7 +963,7 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	}
 
 	for (i = DCB_BCN_ATTR_BCNA_0; i <= DCB_BCN_ATTR_RI; i++) {
-		if (data[i] == NULL)
+		if (!data[i])
 			continue;
 		value_int = nla_get_u32(data[i]);
 		netdev->dcbnl_ops->setbcncfg(netdev,
@@ -1632,7 +1632,7 @@ static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		goto err;
 
 	for (i = DCB_FEATCFG_ATTR_ALL+1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
-		if (data[i] == NULL)
+		if (!data[i])
 			continue;
 
 		value = nla_get_u8(data[i]);
-- 
2.11.0
