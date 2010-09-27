From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 0/4] tunnels: SMP safe accounting
Date: Mon, 27 Sep 2010 12:32:48 +0200
Message-ID: <1285583568.23938.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49332 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab0I0Kcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:32:52 -0400
Received: by fxm3 with SMTP id 3so1675285fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:32:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before making ip_gre, ipip, and sit transmit path lockless, it is
necessary to make accounting SMP safe, not only for correctness but to
avoid cache line ping pongs.

This also takes care of receive path, already lockless and using unsafe
stats accounting.

I chose to use small percpu structures, holding {rx|tx}_{packets|bytes}
only, and keep all other counters in netdev->stats, since they should be
seldom used.

Patch 1/4 makes the needed changes in include files
Patch 2/4 takes care of ip_gre
Patch 3/4 takes care of ipip
Patch 4/4 takes care of sit

Thanks

 include/linux/netdevice.h |    1 
 include/net/dst.h         |   24 ++++--
 include/net/ipip.h        |   12 +--
 net/ipv4/ip_gre.c         |  138 +++++++++++++++++++++++++-----------
 net/ipv4/ipip.c           |  127 ++++++++++++++++++++++++---------
 net/ipv6/sit.c            |   80 ++++++++++++++++----
 6 files changed, 282 insertions(+), 100 deletions(-)


