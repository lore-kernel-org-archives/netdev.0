From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 0/3] tcp: fixes some congestion control corner cases
Date: Thu,  9 Jul 2015 13:16:28 -0700
Message-ID: <1436472991-16056-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Van Jacobson <vanj@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33229 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbbGIUR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 16:17:26 -0400
Received: by ietj16 with SMTP id j16so10914909iet.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 13:17:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes corner cases of TCP congestion control.
First issue is to avoid continuing slow start when cwnd reaches ssthresh.
Second issue is incorrectly processing order of congestion state and
cwnd update when entering fast recovery or undoing cwnd.

Yuchung Cheng (3):
  tcp: add tcp_in_slow_start helper
  tcp: do not slow start when cwnd equals ssthresh
  tcp: update congestion state first before raising cwnd

 include/net/tcp.h        | 7 ++++++-
 net/ipv4/tcp_bic.c       | 2 +-
 net/ipv4/tcp_cdg.c       | 2 +-
 net/ipv4/tcp_cong.c      | 6 ++----
 net/ipv4/tcp_cubic.c     | 4 ++--
 net/ipv4/tcp_highspeed.c | 2 +-
 net/ipv4/tcp_htcp.c      | 2 +-
 net/ipv4/tcp_hybla.c     | 2 +-
 net/ipv4/tcp_illinois.c  | 2 +-
 net/ipv4/tcp_input.c     | 8 ++++----
 net/ipv4/tcp_metrics.c   | 2 +-
 net/ipv4/tcp_scalable.c  | 2 +-
 net/ipv4/tcp_vegas.c     | 6 +++---
 net/ipv4/tcp_veno.c      | 2 +-
 14 files changed, 26 insertions(+), 23 deletions(-)

-- 
2.4.3.573.g4eafbef
