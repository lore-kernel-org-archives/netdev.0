From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: deduplicate TCP_SKB_CB(skb)->when
Date: Fri,  5 Sep 2014 15:33:31 -0700
Message-ID: <1409956413-29472-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:64616 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaIEWjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:39:09 -0400
Received: by mail-oa0-f74.google.com with SMTP id eb12so2151646oac.5
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 15:39:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP_SKB_CB(skb)->when has different meaning in output and input paths.

In output path, it contains a timestamp.
In input path, it contains an ISN, chosen by tcp_timewait_state_process()

Its usage in output path is obsolete after usec timestamping.
Lets simplify and clean this.

Eric Dumazet (2):
  tcp: introduce TCP_SKB_CB(skb)->tcp_tw_isn
  tcp: remove TCP_SKB_CB(skb)->when

 include/net/tcp.h        |  8 +++++++-
 net/ipv4/tcp_input.c     |  5 +++--
 net/ipv4/tcp_ipv4.c      |  7 ++++---
 net/ipv4/tcp_minisocks.c |  2 +-
 net/ipv4/tcp_output.c    | 34 +++++++++++++---------------------
 net/ipv4/tcp_timer.c     |  7 +++----
 net/ipv6/tcp_ipv6.c      |  4 ++--
 7 files changed, 33 insertions(+), 34 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
