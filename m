From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] pppoe: remove unnecessary checks in
 pppoe_flush_dev
Date: Tue, 4 May 2010 17:02:57 +0200
Message-ID: <20100504150256.GD2845@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439Ab0EDPDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 11:03:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pernet memory is guaranteed to exist when notifiers are called.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index c059c8d..99f031a 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -290,12 +290,6 @@ static void pppoe_flush_dev(struct net_device *dev)
 	struct pppoe_net *pn;
 	int i;
 
-	BUG_ON(dev == NULL);
-
-	pn = pppoe_pernet(dev_net(dev));
-	if (!pn) /* already freed */
-		return;
-
 	write_lock_bh(&pn->hash_lock);
 	for (i = 0; i < PPPOE_HASH_SIZE; i++) {
 		struct pppox_sock *po = pn->hash_table[i];
