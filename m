From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: tcp_get_info() locking changes
Date: Fri,  4 Nov 2016 11:54:30 -0700
Message-ID: <1478285672-3195-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36325 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934998AbcKDSyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 14:54:41 -0400
Received: by mail-pf0-f173.google.com with SMTP id 189so56191006pfz.3
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 11:54:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This short series prepares tcp_get_info() for more detailed infos.

In order to not slow down fast path, our goal is to use the normal
socket spinlock instead of custom synchronization.

All we need to ensure is that tcp_get_info() is not called with
ehash lock, which might dead lock, since packet processing would acquire
the spinlocks in reverse way.

Eric Dumazet (2):
  tcp: shortcut listeners in get_tcp_info()
  tcp: no longer hold ehash lock while calling tcp_get_info()

 include/linux/tcp.h  |  2 --
 net/ipv4/inet_diag.c | 48 +++++++++++++++++++++++++++++--------------
 net/ipv4/tcp.c       | 57 ++++++++++++++++++++++++++++------------------------
 net/ipv4/tcp_input.c |  4 ----
 4 files changed, 64 insertions(+), 47 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
