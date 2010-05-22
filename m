From: Dan Carpenter <error27@gmail.com>
Subject: [patch] pppoe: uninitialized variable in pppoe_flush_dev()
Date: Sat, 22 May 2010 22:27:48 +0200
Message-ID: <20100522202534.GO22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56255 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978Ab0EVU2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 16:28:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This assignment got deleted along with the checks by mistake.  This
comes from:  8753d29fd "pppoe: remove unnecessary checks in
pppoe_flush_dev"

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index b1b93ff..805b64d 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -289,6 +289,7 @@ static void pppoe_flush_dev(struct net_device *dev)
 	struct pppoe_net *pn;
 	int i;
 
+	pn = pppoe_pernet(dev_net(dev));
 	write_lock_bh(&pn->hash_lock);
 	for (i = 0; i < PPPOE_HASH_SIZE; i++) {
 		struct pppox_sock *po = pn->hash_table[i];
