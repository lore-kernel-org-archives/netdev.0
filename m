From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v5] net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 18:49:55 +0800
Message-ID: <51790A53.8040107@asianux.com>
References: <5175DFBC.7040000@asianux.com> <5175F7F7.7000703@asianux.com> <51766F74.2090007@asianux.com> <20130425.041044.768895561908042668.davem@davemloft.net> <5178ECA2.6020402@asianux.com> <5178F120.5030500@acn-group.ch> <5178FA0D.8060009@asianux.com> <5178FE6A.3050108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Christophe Aeschlimann <c.aeschlimann@acn-group.ch>,
	sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:6961 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630Ab3DYKum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 06:50:42 -0400
In-Reply-To: <5178FE6A.3050108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change MAC802154_CHAN_NONE from ~(u8)0 to 0xff, or the comparison in
mac802154_wpan_xmit() for ``chan == MAC802154_CHAN_NONE'' will not
succeed.

This bug can be boiled down to ``u8 foo = 0xff; if (foo == ~(u8)0)
[...] else [...]'' where the condition will always take the else
branch. 

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/mac802154/mac802154.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index a4dcaf1..703c121 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -90,7 +90,7 @@ struct mac802154_sub_if_data {
 
 #define MAC802154_MAX_XMIT_ATTEMPTS	3
 
-#define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
+#define MAC802154_CHAN_NONE		0xff /* No channel is assigned */
 
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 extern struct ieee802154_mlme_ops mac802154_mlme_wpan;
-- 
1.7.11.7
