From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/5] tcp: defer shinfo->gso_size|type settings
Date: Thu, 11 Jun 2015 09:15:14 -0700
Message-ID: <1434039319-31309-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33352 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbbFKQPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:15:25 -0400
Received: by iebgx4 with SMTP id gx4so8569805ieb.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:15:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We put shinfo->gso_segs in TCP_SKB_CB(skb) a while back for performance
reasons.

This was in commit cd7d8498c9a5 ("tcp: change tcp_skb_pcount() location")

This patch series complete the job for gso_size and gso_type, so that
we do not bring 2 extra cache lines in tcp write xmit fast path,
and making tcp_init_tso_segs() simpler and faster.

Eric Dumazet (5):
  tcp: reserve tcp_skb_mss() to tcp stack
  tcp: fill shinfo->gso_type at last moment
  tcp: tcp_set_skb_tso_segs() no longer need struct sock parameter
  tcp: fill shinfo->gso_size at last moment
  tcp: remove obsolete check in tcp_set_skb_tso_segs()

 include/net/tcp.h      | 13 ++++++++-----
 net/ipv4/tcp_input.c   | 14 +++++---------
 net/ipv4/tcp_offload.c |  4 ++--
 net/ipv4/tcp_output.c  | 49 +++++++++++++++++++------------------------------
 4 files changed, 34 insertions(+), 46 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
