From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v2 net 0/3] tcp: fix xmit timer rearming to avoid stalls
Date: Thu,  3 Aug 2017 09:19:51 -0400
Message-ID: <20170803131954.15441-1-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33215 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdHCNT5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 09:19:57 -0400
Received: by mail-qk0-f173.google.com with SMTP id a77so7332968qkb.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 06:19:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a bug fix for a TCP loss recovery performance bug
reported independently in recent netdev threads:
    
 (i)  July 26, 2017: netdev thread "TCP fast retransmit issues"
 (ii) July 26, 2017: netdev thread:
       "[PATCH V2 net-next] TLP: Don't reschedule PTO when there's one
       outstanding TLP retransmission"

Many thanks to Klavs Klavsen and Mao Wenan for the detailed reports,
traces, and packetdrill test cases, which enabled us to root-cause
this issue and verify the fix.

- v1 -> v2:
 - In patch 2/3, changed an unclear comment in the pre-existing code
   in tcp_schedule_loss_probe() to be more clear (thanks to Eric Dumazet
   for suggesting we improve this).

Neal Cardwell (3):
  tcp: introduce tcp_rto_delta_us() helper for xmit timer fix
  tcp: enable xmit timer fix by having TLP use time when RTO should fire
  tcp: fix xmit timer to only be reset if data ACKed/SACKed

 include/net/tcp.h     | 10 ++++++++++
 net/ipv4/tcp_input.c  | 30 +++++++++++++++++-------------
 net/ipv4/tcp_output.c | 23 +++++------------------
 3 files changed, 32 insertions(+), 31 deletions(-)

-- 
2.14.0.rc1.383.gd1ce394fe2-goog
