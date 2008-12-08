From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: hold GPRS device while cleaning up
Date: Mon,  8 Dec 2008 12:09:25 +0200
Message-ID: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52985 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbYLHKJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 05:09:40 -0500
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mB8A9b8P025534
	for <netdev@vger.kernel.org>; Mon, 8 Dec 2008 12:09:38 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mB8A9Pc3001417
	for <netdev@vger.kernel.org>; Mon, 8 Dec 2008 12:09:26 +0200
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 9978afb..9602bfc 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -340,8 +340,10 @@ void gprs_detach(struct sock *sk)
 	release_sock(sk);
=20
 	printk(KERN_DEBUG"%s: detached\n", net->name);
+	dev_hold(net); /* TX work still needs it */
 	unregister_netdev(net);
 	flush_scheduled_work();
+	dev_put(net);
 	sock_put(sk);
 	skb_queue_purge(&dev->tx_queue);
 }
--=20
1.5.4.3

