From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/1] atm: br2864: sent packets truncated in VC routed mode
Date: Mon, 01 Aug 2011 11:03:29 -0400
Message-ID: <201108011503.p71F3Tan031501@cmf.nrl.navy.mil>
Cc: pascal@plouf.fr.eu.org, davem@davemloft.net,
	linux-atm-general@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:41761 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab1HAPFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 11:05:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hopefully this could be included for the next kernel release.

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

commit 8b5e1c9db2bcd2d13c2db08e6c6dbe66882fa186
Author: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date:   Mon Aug 1 07:55:07 2011 -0400

    atm: br2864: sent packets truncated in VC routed mode
    
    Reported-by: Pascal Hambourg <pascal@plouf.fr.eu.org>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 2252c20..52cfd0c 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -242,8 +242,6 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 		if (brdev->payload == p_bridged) {
 			skb_push(skb, 2);
 			memset(skb->data, 0, 2);
-		} else { /* p_routed */
-			skb_pull(skb, ETH_HLEN);
 		}
 	}
 	skb_debug(skb);
