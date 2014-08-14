From: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next] lec: Use rtnl lock/unlock when updating MTU
Date: Thu, 14 Aug 2014 09:19:47 -0400
Message-ID: <201408141319.s7EDJl9l031767@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:35771 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbaHNNUG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 09:20:06 -0400
Content-ID: <31765.1408022387.1@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LECS response contains the MTU that should be used.  Correctly
synchronize with other layers when updating.

Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
 net/atm/lec.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 4c5b8ba..6e13369 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -410,9 +410,11 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 		priv->lane2_ops = NULL;
 		if (priv->lane_version > 1)
 			priv->lane2_ops = &lane2_ops;
+		rtnl_lock();
 		if (dev_set_mtu(dev, mesg->content.config.mtu))
 			pr_info("%s: change_mtu to %d failed\n",
 				dev->name, mesg->content.config.mtu);
+		rtnl_unlock();
 		priv->is_proxy = mesg->content.config.is_proxy;
 		break;
 	case l_flush_tran_id:
-- 
1.9.3
