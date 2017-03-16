From: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Subject: [PATCH] tun: fix inability to set offloads after disabling them via
 ethtool
Date: Thu, 16 Mar 2017 21:08:37 +0300
Message-ID: <58cae999.1b582e0a.a78bb.68f6@mx.google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34802 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdCPTrf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:47:35 -0400
Received: by mail-lf0-f67.google.com with SMTP id y193so4102090lfd.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 12:46:31 -0700 (PDT)
Received: from gmail.com (ppp109-252-59-36.pppoe.spdop.ru. [109.252.59.36])
        by smtp.gmail.com with ESMTPSA id m27sm1070616ljb.24.2017.03.16.12.38.00
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 12:38:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added missing logic in tun driver, which prevents apps to set
offloads using tun ioctl, if offloads were previously disabled via ethtool

Signed-of-by: Yaroslav Isakov (yaroslav.isakov@gmail.com)
---
 drivers/net/tun.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 34cc3c5..cc88cd7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1931,6 +1931,8 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
 		return -EINVAL;
 
 	tun->set_features = features;
+	tun->dev->wanted_features &= ~TUN_USER_FEATURES;
+	tun->dev->wanted_features |= features;
 	netdev_update_features(tun->dev);
 
 	return 0;
-- 
2.10.2
