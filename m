From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: address two poll() flakes
Date: Tue, 18 Apr 2017 09:45:50 -0700
Message-ID: <20170418164552.29261-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36586 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754406AbdDRQp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:45:57 -0400
Received: by mail-pg0-f54.google.com with SMTP id g2so90473762pge.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:45:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some packetdrill tests are failing when host kernel is using ASAN
or other debugging infrastructure.

I was able to fix the flakes by making sure we were not
sending wakeup events too soon.

Eric Dumazet (2):
  tcp: remove poll() flakes when receiving RST
  tcp: remove poll() flakes with FastOpen

 net/ipv4/tcp_input.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

-- 
2.12.2.762.g0e3151a226-goog
