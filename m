From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 1/2] tun: correctly report an error in tun_flow_init()
Date: Thu, 29 Nov 2012 17:06:29 -0500
Message-ID: <20121129220629.30020.99947.stgit@sifl>
References: <20121129215724.30020.69464.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550Ab2K2WGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 17:06:33 -0500
In-Reply-To: <20121129215724.30020.69464.stgit@sifl>
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
index 607a3a5..877ffe2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1605,7 +1605,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		tun_net_init(dev);
 
-		if (tun_flow_init(tun))
+		err = tun_flow_init(tun);
+		if (err < 0)
 			goto err_free_dev;
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
