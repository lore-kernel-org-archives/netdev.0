From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] macvlan: code refine to check data before using
Date: Wed, 20 Sep 2017 08:12:23 +0800
Message-ID: <1505866343-14135-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, fgao@ikuai8.com, vyasevic@redhat.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:25813 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751811AbdITHpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 03:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch checks data first at one place, return if it's null.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/macvlan.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d2aea96..1ffe77e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1231,11 +1231,14 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
 			return -EADDRNOTAVAIL;
 	}
 
-	if (data && data[IFLA_MACVLAN_FLAGS] &&
+	if (!data)
+		return 0;
+
+	if (data[IFLA_MACVLAN_FLAGS] &&
 	    nla_get_u16(data[IFLA_MACVLAN_FLAGS]) & ~MACVLAN_FLAG_NOPROMISC)
 		return -EINVAL;
 
-	if (data && data[IFLA_MACVLAN_MODE]) {
+	if (data[IFLA_MACVLAN_MODE]) {
 		switch (nla_get_u32(data[IFLA_MACVLAN_MODE])) {
 		case MACVLAN_MODE_PRIVATE:
 		case MACVLAN_MODE_VEPA:
@@ -1248,7 +1251,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
 		}
 	}
 
-	if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
+	if (data[IFLA_MACVLAN_MACADDR_MODE]) {
 		switch (nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE])) {
 		case MACVLAN_MACADDR_ADD:
 		case MACVLAN_MACADDR_DEL:
@@ -1260,7 +1263,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
 		}
 	}
 
-	if (data && data[IFLA_MACVLAN_MACADDR]) {
+	if (data[IFLA_MACVLAN_MACADDR]) {
 		if (nla_len(data[IFLA_MACVLAN_MACADDR]) != ETH_ALEN)
 			return -EINVAL;
 
@@ -1268,7 +1271,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
 			return -EADDRNOTAVAIL;
 	}
 
-	if (data && data[IFLA_MACVLAN_MACADDR_COUNT])
+	if (data[IFLA_MACVLAN_MACADDR_COUNT])
 		return -EINVAL;
 
 	return 0;
-- 
1.8.3.1
