From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 0/2 v2 net-next] tcp cwnd undo refactor
Date: Thu,  3 Aug 2017 20:38:50 -0700
Message-ID: <20170804033852.97986-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, unlcsewsun@gmail.com,
        stephen@networkplumber.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35378 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbdHDDjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 23:39:06 -0400
Received: by mail-pg0-f41.google.com with SMTP id v189so2700011pgd.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 20:39:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series consolidate similar cwnd undo functions
implemented by various congestion control by using existing
tcp socket state variable. The first patch fixes a corner
case in of cwnd undo in Reno and HTCP. Since the bug has
existed for many years and is very minor, we consider this
patch set more suitable for net-next as the major change
is the refactor itself.

- v1->v2
  Fix trivial compile errors

Yuchung Cheng (2):
  tcp: fix cwnd undo in Reno and HTCP congestion controls
  tcp: consolidate congestion control undo functions

 include/linux/tcp.h      |  2 +-
 net/ipv4/tcp_bic.c       | 14 +-------------
 net/ipv4/tcp_cdg.c       | 12 +-----------
 net/ipv4/tcp_cong.c      |  2 +-
 net/ipv4/tcp_cubic.c     | 13 +------------
 net/ipv4/tcp_highspeed.c | 11 +----------
 net/ipv4/tcp_htcp.c      |  3 +--
 net/ipv4/tcp_illinois.c  | 11 +----------
 net/ipv4/tcp_input.c     |  1 +
 net/ipv4/tcp_nv.c        | 13 +------------
 net/ipv4/tcp_scalable.c  | 16 +---------------
 net/ipv4/tcp_veno.c      | 11 +----------
 net/ipv4/tcp_yeah.c      | 11 +----------
 13 files changed, 13 insertions(+), 107 deletions(-)

-- 
2.14.0.rc1.383.gd1ce394fe2-goog
