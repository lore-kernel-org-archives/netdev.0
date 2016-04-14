From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: final work on SYNFLOOD behavior
Date: Wed, 13 Apr 2016 22:05:38 -0700
Message-ID: <1460610340-22163-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36053 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbcDNFFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 01:05:45 -0400
Received: by mail-pf0-f175.google.com with SMTP id e128so42220748pfe.3
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 22:05:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the first patch, I remove the costly association of SYNACK+COOKIES
to a listener. I believe other parts of the stack should be ready.

The second patch removes a useless write into listener socket
in tcp_rcv_state_process(), incurring false sharing in
tcp_conn_request()

Performance under SYNFLOOD goes from 3.2 Mpps to 6 Mpps.

Test was using a single TCP listener, on a host with 8 RX queues
on the NIC, and 24 cores (48 ht)

Eric Dumazet (2):
  tcp: do not mess with listener sk_wmem_alloc
  tcp: remove false sharing in tcp_rcv_state_process()

 include/net/tcp.h     |  9 +++++++--
 net/ipv4/tcp_input.c  | 11 ++++++-----
 net/ipv4/tcp_ipv4.c   |  4 ++--
 net/ipv4/tcp_output.c | 16 ++++++++++++----
 net/ipv6/tcp_ipv6.c   |  4 ++--
 5 files changed, 29 insertions(+), 15 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
