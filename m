From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netpoll: netpoll_poll_dev() should access dev->flags
Date: Tue, 14 Feb 2012 21:11:59 +0100
Message-ID: <1329250319.2555.4.camel@edumazet-laptop>
References: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120214.144251.1481952602061158777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60478 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab2BNUMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 15:12:05 -0500
Received: by wgbdt10 with SMTP id dt10so262780wgb.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 12:12:03 -0800 (PST)
In-Reply-To: <20120214.144251.1481952602061158777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5a698af53f (bond: service netpoll arp queue on master device)
tested IFF_SLAVE flag against dev->priv_flags instead of dev->flags 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: WANG Cong <amwang@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/netpoll.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 556b082..ddefc51 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -194,7 +194,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
-	if (dev->priv_flags & IFF_SLAVE) {
+	if (dev->flags & IFF_SLAVE) {
 		if (dev->npinfo) {
 			struct net_device *bond_dev = dev->master;
 			struct sk_buff *skb;
