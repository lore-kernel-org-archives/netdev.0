From: Dan Carpenter <error27@gmail.com>
Subject: [patch] missing dev_put() on error path in vif_add()
Date: Wed, 11 Nov 2009 14:03:54 +0200 (SAST)
Message-ID: <alpine.DEB.2.00.0911111339100.9485@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:47549 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbZKKMEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 07:04:06 -0500
Received: by fxm21 with SMTP id 21so916820fxm.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 04:04:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The other error paths in front of this one have a dev_put() but this one 
got missed.

Found by smatch static checker.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/net/ipv4/ipmr.c	2009-11-11 13:34:20.000000000 +0200
+++ devel/net/ipv4/ipmr.c	2009-11-11 13:34:59.000000000 +0200
@@ -483,8 +483,10 @@
 		return -EINVAL;
 	}
 
-	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
+	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL) {
+		dev_put(dev);
 		return -EADDRNOTAVAIL;
+	}
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
 	ip_rt_multicast_event(in_dev);
 
