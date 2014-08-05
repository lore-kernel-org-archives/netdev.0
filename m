From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next] team: Simplify return path of team_newlink
Date: Tue,  5 Aug 2014 15:58:50 +0900
Message-ID: <1407221930-15590-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:41056 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbaHEG7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 02:59:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable "err" is not necessary.
Return register_netdevice() directly.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/team/team.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index b4958c7..ef10302 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2045,16 +2045,10 @@ static void team_setup(struct net_device *dev)
 static int team_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	int err;
-
 	if (tb[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(dev);
 
-	err = register_netdevice(dev);
-	if (err)
-		return err;
-
-	return 0;
+	return register_netdevice(dev);
 }
 
 static int team_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.8.1.2
