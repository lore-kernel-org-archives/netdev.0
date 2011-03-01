From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Tue, 1 Mar 2011 07:22:50 +0100
Message-ID: <20110301062250.GB2855@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32076 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755208Ab1CAGWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 01:22:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to do share check here since call to netif_rx was removed and
skb is passed back.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f3e5d7f..e8c0f95 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1503,10 +1503,6 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 	if (unlikely(!slave))
 		return skb;
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(!skb))
-		return NULL;
-
 	bond_dev = ACCESS_ONCE(skb->dev->master);
 	if (unlikely(!bond_dev))
 		return skb;
-- 
1.7.3.4

