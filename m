From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 0/3] tcp: fix xmit timer rearming to avoid stalls
Date: Mon, 31 Jul 2017 22:58:11 -0400
Message-ID: <20170801025814.31206-1-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:34731 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751725AbdHAC6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 22:58:25 -0400
Received: by mail-qt0-f172.google.com with SMTP id s6so2200509qtc.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 19:58:24 -0700 (PDT)
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

Neal Cardwell (3):
  tcp: introduce tcp_rto_delta_us() helper for xmit timer fix
  tcp: enable xmit timer fix by having TLP use time when RTO should fire
  tcp: fix xmit timer to only be reset if data ACKed/SACKed

 include/net/tcp.h     | 10 ++++++++++
 net/ipv4/tcp_input.c  | 30 +++++++++++++++++-------------
 net/ipv4/tcp_output.c | 21 ++++-----------------
 3 files changed, 31 insertions(+), 30 deletions(-)

-- 
2.14.0.rc0.400.g1c36432dff-goog
