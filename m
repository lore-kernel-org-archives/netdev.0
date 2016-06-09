From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed,  8 Jun 2016 20:29:22 -0700
Message-ID: <1465442964-5786-2-git-send-email-edumazet@google.com>
References: <1465442964-5786-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33222 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbcFID3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 23:29:33 -0400
Received: by mail-pf0-f177.google.com with SMTP id y124so8862567pfy.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 20:29:33 -0700 (PDT)
In-Reply-To: <1465442964-5786-1-git-send-email-edumazet@google.com>
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
