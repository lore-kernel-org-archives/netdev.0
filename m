From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH v2 net-next 0/3] Use correct sk->sk_prot for IPV6
Date: Tue, 15 Aug 2017 14:08:37 +0300
Message-ID: <1502795320-22538-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, aviadye@mellanox.com,
        Ilya Lesokhin <ilyal@mellanox.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35020 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751068AbdHOLJY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 07:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tls ulp overrides sk->prot with a new tls specific proto structs.
The tls specific structs were previously based on the ipv4 specific
tcp_prot sturct.
As a result, attaching the tls ulp to an ipv6 tcp socket replaced
some ipv6 callback with the ipv4 equivalents.

This patch adds ipv6 tls proto structs and uses them when
attached to ipv6 sockets.

Changes since v1:
- TLS now dependes on IPV6
This fixes complication issues when TLS is built-in and IPV6 is a module.
The downside should be small as it is unlikely that there are kernel TLS 
users who can't afford to include IPV6 in thier kernel.
- tls_init now checks sk->sk_prot directly
This is somewhat safer then checking indirectly through sk->sk_family

Ilya Lesokhin (3):
  ipv6: Prevent unexpected sk->sk_prot changes
  net: Export tcpv6_prot
  tls: Use correct sk->sk_prot for IPV6

 net/ipv6/ipv6_sockglue.c | 12 ++++++++++++
 net/ipv6/tcp_ipv6.c      |  1 +
 net/tls/Kconfig          |  1 +
 net/tls/tls_main.c       | 50 ++++++++++++++++++++++++++++++++++++------------
 4 files changed, 52 insertions(+), 12 deletions(-)

-- 
1.8.3.1
