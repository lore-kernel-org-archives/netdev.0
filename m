From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 0/4] udp: receive path optimizations
Date: Thu,  8 Dec 2016 11:41:53 -0800
Message-ID: <1481226117-31288-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34666 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcLHTmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:42:03 -0500
Received: by mail-pg0-f51.google.com with SMTP id x23so177093637pgx.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:42:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series provides about 100 % performance increase under flood. 

v2: added Paolo feedback on udp_rmem_release() for tiny sk_rcvbuf
    added the last patch touching sk_rmem_alloc later

Eric Dumazet (4):
  udp: add busylocks in RX path
  udp: copy skb->truesize in the first cache line
  udp: add batching to udp_rmem_release()
  udp: udp_rmem_release() should touch sk_rmem_alloc later

 include/linux/skbuff.h |  9 ++++++-
 include/linux/udp.h    |  3 +++
 net/ipv4/udp.c         | 71 ++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 77 insertions(+), 6 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
