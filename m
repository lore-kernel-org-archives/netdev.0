From: Cong Wang <cwang@twopensource.com>
Subject: Setting mac address of loopback device
Date: Thu, 23 Jan 2014 11:53:49 -0800
Message-ID: <CAHA+R7Poj99BjOq55st3hU-2-p+gqoeHMCDCSJjT5eEocbKwMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:48149 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbaAWTxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 14:53:52 -0500
Received: by mail-la0-f45.google.com with SMTP id b8so1851009lan.18
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 11:53:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


I am wondering how much sense it makes to allow setting the mac
address of the loopback device?

We are trying to mirror the local traffic from lo to eth0, but
apparently the mac addresses in L2 header are all zero. Of course, one
solution is using pedit action to modify the mac addresses. But still,
if we could set the mac addr of lo, we don't need to modify the mac
header twice.

The patch itself is simple, probably just:

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c5011e0..a0ee030 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -160,6 +160,7 @@ static const struct net_device_ops loopback_ops = {
        .ndo_init      = loopback_dev_init,
        .ndo_start_xmit= loopback_xmit,
        .ndo_get_stats64 = loopback_get_stats64,
+       .ndo_set_mac_address = eth_mac_addr,
 };

 /*

BTW, how to change route to redirect _local_ traffic (that is packets
sending to itself) to a non-loopback device? I tried to modify local
route table, but have no luck to make it working.

Thanks!
