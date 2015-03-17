From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] inet: tcp listener refactoring, part 11
Date: Mon, 16 Mar 2015 21:06:14 -0700
Message-ID: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:34692 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbCQEGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:06:24 -0400
Received: by iebtr6 with SMTP id tr6so23928ieb.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:06:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before inserting request sockets into general (ehash) table,
we need to prepare netfilter to cope with them, as they are
not full sockets.

I'll later change xt_socket to get full support, including for
request sockets (NEW_SYN_RECV) 

Save 8 bytes in inet_request_sock on 64bit arches. We'll soon add
a pointer to the listener socket.

I included two TCP changes in this patch series.

Eric Dumazet (6):
  netfilter: use sk_fullsock() helper
  netfilter: tproxy: prepare TCP_NEW_SYN_RECV support
  netfilter: xt_socket: prepare for TCP_NEW_SYN_RECV support
  inet: move ir_mark to fill a hole
  tcp: move tcp_openreq_init() to tcp_input.c
  tcp: uninline tcp_oow_rate_limited()

 include/net/inet_sock.h              | 11 ++++---
 include/net/tcp.h                    | 57 ++----------------------------------
 net/ipv4/tcp_input.c                 | 55 ++++++++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_xmit.c      |  2 +-
 net/netfilter/nf_log_common.c        |  2 +-
 net/netfilter/nfnetlink_log.c        |  2 +-
 net/netfilter/nfnetlink_queue_core.c |  2 +-
 net/netfilter/nft_meta.c             |  4 +--
 net/netfilter/xt_TPROXY.c            | 18 ++++++++----
 net/netfilter/xt_socket.c            | 34 +++++++++++++--------
 10 files changed, 102 insertions(+), 85 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
