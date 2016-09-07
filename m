From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] macsec: set network devtype
Date: Wed, 7 Sep 2016 14:07:32 -0700
Message-ID: <20160907140732.396bc2cf@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34981 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751824AbcIGVHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 17:07:23 -0400
Received: by mail-pa0-f50.google.com with SMTP id b2so9803894pat.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 14:07:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netdevice type structure for macsec was being defined but never used.
To set the network device type the macro SET_NETDEV_DEVTYPE must be called.
Compile tested only, I don't use macsec.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/macsec.c	2016-08-25 17:20:20.671031972 -0700
+++ b/drivers/net/macsec.c	2016-09-07 14:03:01.676238097 -0700
@@ -2973,6 +2973,7 @@ static void macsec_setup(struct net_devi
 	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->netdev_ops = &macsec_netdev_ops;
 	dev->destructor = macsec_free_netdev;
+	SET_NETDEV_DEVTYPE(dev, &macsec_type);
 
 	eth_zero_addr(dev->broadcast);
 }
