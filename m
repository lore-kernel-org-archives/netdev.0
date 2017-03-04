From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 0/2] net: fix possible sock_hold() misuses
Date: Fri,  3 Mar 2017 21:01:01 -0800
Message-ID: <20170304050103.12226-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35536 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdCDFB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 00:01:28 -0500
Received: by mail-pg0-f54.google.com with SMTP id b129so50242135pgc.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 21:01:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_complete_wifi_ack() and skb_complete_tx_timestamp() currently
call sock_hold() on sockets that might have transitioned their sk_refcnt
to zero already.

Eric Dumazet (2):
  net: fix socket refcounting in skb_complete_wifi_ack()
  net: fix socket refcounting in skb_complete_tx_timestamp()

 net/core/skbuff.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

-- 
2.12.0.rc1.440.g5b76565f74-goog
