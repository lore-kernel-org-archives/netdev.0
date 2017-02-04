From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/9] net: get rid of most __napi_complete() usages
Date: Sat,  4 Feb 2017 10:20:29 -0800
Message-ID: <20170204182038.3752-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:32857 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdBDSUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 13:20:47 -0500
Received: by mail-pg0-f51.google.com with SMTP id 204so15931038pge.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 10:20:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes nine __napi_complete() calls, in an effort
to harmonize NAPI API and generalize GRO and napi_complete_done()

Two are left, I was not feeling lucky enough to patch them :/
 ( aeroflex/greth.c & ibm/emac/mal.c )

Eric Dumazet (9):
  8139too: use napi_complete_done()
  8139cp: use napi_complete_done()
  epic100: use napi_complete_done()
  amd8111e: add GRO support
  pcnet32: use napi_complete_done()
  ep93xx_eth: add GRO support
  skge: use napi_complete_done()
  ks8695net: add GRO support
  qla3xxx: add GRO support

 drivers/net/ethernet/amd/amd8111e.c      | 165 ++++++++++++++-----------------
 drivers/net/ethernet/amd/pcnet32.c       |  11 +--
 drivers/net/ethernet/cirrus/ep93xx_eth.c |  24 +----
 drivers/net/ethernet/marvell/skge.c      |   8 +-
 drivers/net/ethernet/micrel/ks8695net.c  |  11 +--
 drivers/net/ethernet/qlogic/qla3xxx.c    |  31 +++---
 drivers/net/ethernet/realtek/8139cp.c    |  19 ++--
 drivers/net/ethernet/realtek/8139too.c   |  16 ++-
 drivers/net/ethernet/smsc/epic100.c      |  33 ++-----
 9 files changed, 124 insertions(+), 194 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
