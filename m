From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] netpoll: netpoll_poll_dev() should access dev->flags
Date: Tue, 14 Feb 2012 12:10:21 +0100
Message-ID: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39305 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760010Ab2BNLKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 06:10:25 -0500
Received: by wics10 with SMTP id s10so4069245wic.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 03:10:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5a698af53f (bond: service netpoll arp queue on master device)
use a dubious test : if (dev->priv_flags & IFF_SLAVE)

It seems to me IFF_SLAVE is present on dev->flags only ?

What am I missing ?

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4ce473e..3d84fb9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -205,7 +205,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
-	if (dev->priv_flags & IFF_SLAVE) {
+	if (dev->flags & IFF_SLAVE) {
 		if (dev->npinfo) {
 			struct net_device *bond_dev = dev->master;
 			struct sk_buff *skb;
