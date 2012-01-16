From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bridge: BH already disabled in br_fdb_cleanup()
Date: Mon, 16 Jan 2012 15:35:50 +0100
Message-ID: <1326724550.2255.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
	 <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAGsizzJpdF5xzsEiZd5R0GD8r7pDJyz4ro=4vLBnonxfAVYg-Q@mail.gmail.com>
	 <1326723932.2255.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57762 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417Ab2APOfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 09:35:54 -0500
Received: by bkas6 with SMTP id s6so661308bka.19
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2012 06:35:53 -0800 (PST)
In-Reply-To: <1326723932.2255.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_cleanup() is run from timer interrupt, BH already masked.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: =C5=A0tefan Gula <steweg@gmail.com>
---
 net/bridge/br_fdb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index f963f6b..5ba0c84 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -146,7 +146,7 @@ void br_fdb_cleanup(unsigned long _data)
 	unsigned long next_timer =3D jiffies + br->ageing_time;
 	int i;
=20
-	spin_lock_bh(&br->hash_lock);
+	spin_lock(&br->hash_lock);
 	for (i =3D 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
 		struct hlist_node *h, *n;
@@ -162,7 +162,7 @@ void br_fdb_cleanup(unsigned long _data)
 				next_timer =3D this_timer;
 		}
 	}
-	spin_unlock_bh(&br->hash_lock);
+	spin_unlock(&br->hash_lock);
=20
 	mod_timer(&br->gc_timer, round_jiffies_up(next_timer));
 }
