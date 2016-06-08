From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed,  8 Jun 2016 16:55:25 -0700
Message-ID: <1465430127-22993-2-git-send-email-edumazet@google.com>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33639 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121AbcFHXzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 19:55:35 -0400
Received: by mail-pf0-f170.google.com with SMTP id y124so7242530pfy.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 16:55:34 -0700 (PDT)
In-Reply-To: <1465430127-22993-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a qdisc is used on a vrf device, we need to use different
lockdep classes to avoid false positives.

Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/vrf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 1b214ea4619a..ee6bc1c5c1ce 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -657,7 +657,7 @@ static int vrf_dev_init(struct net_device *dev)
 
 	/* similarly, oper state is irrelevant; set to up to avoid confusion */
 	dev->operstate = IF_OPER_UP;
-
+	netdev_lockdep_set_classes(dev);
 	return 0;
 
 out_rth:
-- 
2.8.0.rc3.226.g39d4020
