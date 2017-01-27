From: =?UTF-8?Q?Milan_Ko=c4=8dvara?= <milankocvara@gmail.com>
Subject: bonding l2tpeth interfaces
Date: Fri, 27 Jan 2017 15:02:25 +0100
Message-ID: <b6ba20c1-8f5c-a0b6-f618-bb72160850ef@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34969 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932770AbdA0OC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 09:02:28 -0500
Received: by mail-wm0-f68.google.com with SMTP id d140so58716010wmd.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 06:02:28 -0800 (PST)
Received: from ?IPv6:2a02:570:f:100:9764:b2a0:ab21:15a2? ([2a02:570:f:100:9764:b2a0:ab21:15a2])
        by smtp.googlemail.com with ESMTPSA id r24sm8093133wrr.25.2017.01.27.06.02.25
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 06:02:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.
I would like ask you about bonding l2tpeth interfaces. I found an older 
patch to allow it (interfaces were created over l2tpv3tun package) but 
after switching this functionality into ip route package starting kernel 
4.4 this patch does not work.

ifenslave says
ifenslave: bond0: can't set hw address
ifenslave: can't enslave l2tpeth1 to bond0: Resource busy
and doing over echo l2tpeth1 > /sys/class/net/bond0/bonding/
it says [  100.892608] bond0: interface 2tpeth1 does not exist!

patch was

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 76125c5..1e73b35 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -120,12 +120,13 @@ static struct rtnl_link_stats64 
*l2tp_eth_get_stats64(struct net_device *dev,
         return stats;
  }

-
  static struct net_device_ops l2tp_eth_netdev_ops = {
         .ndo_init               = l2tp_eth_dev_init,
         .ndo_uninit             = l2tp_eth_dev_uninit,
         .ndo_start_xmit         = l2tp_eth_dev_xmit,
         .ndo_get_stats64        = l2tp_eth_get_stats64,
+       .ndo_validate_addr      = eth_validate_addr,
+       .ndo_set_mac_address    = eth_mac_addr,
  };

  static void l2tp_eth_dev_setup(struct net_device *dev)
-- 
1.7.9.5

this row > .ndo_set_mac_address    = eth_mac_addr, is part of current 
source.

What should be wrong yet, please?

My router is
Linux lede 4.4.42 #0 Wed Jan 25 15:25:48 2017 mips GNU/Linux
