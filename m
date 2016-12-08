From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Thu,  8 Dec 2016 09:38:55 -0800
Message-ID: <1481218739-27089-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36836 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbcLHRjD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:39:03 -0500
Received: by mail-pg0-f51.google.com with SMTP id f188so175531686pgc.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:39:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series provides about 100 % performance increase under flood. 

David, please scratch it if you prefer to wait for linux-4.11,
thanks !

Eric Dumazet (4):
  udp: under rx pressure, try to condense skbs
  udp: add busylocks in RX path
  udp: copy skb->truesize in the first cache line
  udp: add batching to udp_rmem_release()

 include/linux/skbuff.h | 11 +++++++-
 include/linux/udp.h    |  3 ++
 net/core/skbuff.c      | 28 ++++++++++++++++++
 net/ipv4/udp.c         | 77 +++++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 114 insertions(+), 5 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
