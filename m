From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Zero terminate ifr_name in dev_ifname().
Date: Wed, 19 Jul 2017 13:34:10 -0700 (PDT)
Message-ID: <20170719.133410.2182418694263884775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754083AbdGSUeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 16:34:10 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 5EC831262855E
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 13:34:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ifr.ifr_name is passed around and assumed to be NULL terminated.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev_ioctl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 7657ad6bc13d..06b147d7d9e2 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -28,6 +28,7 @@ static int dev_ifname(struct net *net, struct ifreq __user *arg)
 
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
+	ifr.ifr_name[IFNAMSIZ-1] = 0;
 
 	error = netdev_get_name(net, ifr.ifr_name, ifr.ifr_ifindex);
 	if (error)
-- 
2.13.3
