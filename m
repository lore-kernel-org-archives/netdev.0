From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 0/3] use netdev_is_rx_handler_busy() in few known cases
Date: Wed, 18 Jan 2017 15:02:45 -0800
Message-ID: <20170118230245.20674-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33414 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdARXOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 18:14:04 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so2444641pgd.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 15:12:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

netdev_rx_handler_register() was recently split into two parts - (a) check
if the handler is used, (b) register the new handler, parts. This is 
helpful in scenarios like bonding where at the time of registration there
is too much state to unwind and it should check if the device is free
before building that state. IPvlan and macvlan drivers don't have this
issue however it can make use of the same check instead of using a device
specific check.

Mahesh Bandewar (3):
  net: remove duplicate code.
  ipvlan: use netdev_is_rx_handler_busy instead of checking specific
    type
  macvlan: use netdev_is_rx_handler_busy instead of checking specific
    type

 drivers/net/ipvlan/ipvlan_main.c | 4 ++--
 drivers/net/macvlan.c            | 2 +-
 net/core/dev.c                   | 4 +---
 3 files changed, 4 insertions(+), 6 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
