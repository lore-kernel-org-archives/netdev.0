From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] tcp/dccp: make our listener code more robust
Date: Wed, 14 Oct 2015 10:58:36 -0700
Message-ID: <1444845519-20064-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33991 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbJNR6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:58:46 -0400
Received: by payp3 with SMTP id p3so12671039pay.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:58:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses request sockets leaks and listener dismantle
phase. This survives a stress test with listeners being added/removed
quite randomly.

Eric Dumazet (3):
  Revert "inet: fix double request socket freeing"
  tcp/dccp: add inet_csk_reqsk_queue_drop_and_put() helper
  tcp/dccp: fix race at listener dismantle phase

 include/net/inet_connection_sock.h | 10 ++---
 include/net/request_sock.h         | 19 ---------
 net/dccp/ipv4.c                    |  4 +-
 net/dccp/ipv6.c                    |  2 +-
 net/ipv4/inet_connection_sock.c    | 83 ++++++++++++++++++++++++++------------
 net/ipv4/tcp_ipv4.c                |  6 +--
 net/ipv6/tcp_ipv6.c                |  2 +-
 7 files changed, 68 insertions(+), 58 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
