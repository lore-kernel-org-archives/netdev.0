From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: RFC: bring UP 'lo' by default after creating new netns
Date: Thu, 29 Jun 2017 16:57:39 -0700
Message-ID: <CAF2d9jhTcVgLHs_iqw+RRS=WhMtRF0ra5SygGMymuYQUW6HP0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>, ebiederm@xmission.com,
        adobriyan@gmail.com, David Miller <davem@davemloft.net>,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:32889 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdF2X6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 19:58:01 -0400
Received: by mail-it0-f43.google.com with SMTP id 188so2785682itx.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 16:58:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creation of new network namespace is almost always followed up by
bringing up the loopback device.

        ip netns add foo
        ip -netns foo link set lo up

I'm not sure if there are any consequences of bringing the device UP
at the creation of network-namespace.

thanks,
--mahesh..

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2178db8e47cd..ac0e86c9a17f 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -428,6 +428,11 @@ struct net *copy_net_ns(unsigned long flags,
                net_drop_ns(net);
                return ERR_PTR(rv);
        }
+       /* Set the loopback device UP */
+       rtnl_lock();
+       dev_open(net->loopback_dev);
+       rtnl_unlock();
+
        return net;
 }
