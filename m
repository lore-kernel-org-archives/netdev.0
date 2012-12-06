From: Paul Moore <pmoore@redhat.com>
Subject: [net-next PATCH] tun: correctly report an error in tun_flow_init()
Date: Thu, 06 Dec 2012 10:48:38 -0500
Message-ID: <20121206154838.6073.17102.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423972Ab2LFPsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 10:48:40 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qB6Fmd11011359
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2012 10:48:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On error, the error code from tun_flow_init() is lost inside
tun_set_iff(), this patch fixes this by assigning the tun_flow_init()
error code to the "err" variable which is returned by
the tun_flow_init() function on error.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 drivers/net/tun.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1b2389..14a0454 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1591,7 +1591,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		tun_net_init(dev);
 
-		if (tun_flow_init(tun))
+		err = tun_flow_init(tun);
+		if (err < 0)
 			goto err_free_dev;
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
