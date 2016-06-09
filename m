From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 3/5] net: vrf: call netdev_lockdep_set_classes()
Date: Thu,  9 Jun 2016 07:45:13 -0700
Message-ID: <1465483515-10821-4-git-send-email-edumazet@google.com>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33138 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932251AbcFIOp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:45:29 -0400
Received: by mail-pf0-f171.google.com with SMTP id y124so14134971pfy.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 07:45:29 -0700 (PDT)
In-Reply-To: <1465483515-10821-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a qdisc is used on a vrf device, we need to use different
lockdep classes to avoid false positives.

Use the new netdev_lockdep_set_classes() generic helper.

Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/vrf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e3e693bf0dec..b82e3527924e 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -661,7 +661,7 @@ static int vrf_dev_init(struct net_device *dev)
 
 	/* similarly, oper state is irrelevant; set to up to avoid confusion */
 	dev->operstate = IF_OPER_UP;
-
+	netdev_lockdep_set_classes(dev);
 	return 0;
 
 out_rth:
-- 
2.8.0.rc3.226.g39d4020
