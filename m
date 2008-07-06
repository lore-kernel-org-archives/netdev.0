From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH net-next]: net: fix dev_set_promiscuity() breakage
Date: Mon, 07 Jul 2008 00:18:36 +0200
Message-ID: <487144BC.6030609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090104000608020603040406"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Wang Chen <wangchen@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41529 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbYGFWYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:24:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090104000608020603040406
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit



--------------090104000608020603040406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 7aaf76390d820383eb4069065ec2e1b5ee479ef9
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jul 7 00:21:09 2008 +0200

    net: fix dev_set_promiscuity() breakage
    
    Commit dad9b335 (netdevice: Fix promiscuity and allmulti overflow) broke
    dev_set_promiscuity() by returning on success without reprogramming the
    device.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index bfa9a6a..7593393 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2859,7 +2859,7 @@ int dev_set_promiscuity(struct net_device *dev, int inc)
 	int err;
 
 	err = __dev_set_promiscuity(dev, inc);
-	if (!err)
+	if (err < 0)
 		return err;
 	if (dev->flags != old_flags)
 		dev_set_rx_mode(dev);

--------------090104000608020603040406--
