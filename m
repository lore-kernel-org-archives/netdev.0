From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/2] net: dsa: Fix tag_ksz.c
Date: Tue, 22 Aug 2017 15:12:13 -0700
Message-ID: <20170822221215.16305-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, UNGLinuxDriver@microchip.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34439 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdHVWMY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 18:12:24 -0400
Received: by mail-wm0-f67.google.com with SMTP id r187so494319wma.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 15:12:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements David's suggestion of providing low-level functions
to control whether skb_pad() and skb_put_padto() should be freeing
the passed skb.

We make use of it to fix a double free in net/dsa/tag_ksz.c that would
occur if we kept using skb_put_padto() in both places.

Florian Fainelli (2):
  net: core: Specify skb_pad()/skb_put_padto() SKB freeing
  net: dsa: skb_put_padto() already frees nskb

 include/linux/skbuff.h | 41 +++++++++++++++++++++++++++++++++++++----
 net/core/skbuff.c      | 13 ++++++++-----
 net/dsa/tag_ksz.c      | 10 ++++++----
 3 files changed, 51 insertions(+), 13 deletions(-)

-- 
2.9.3
