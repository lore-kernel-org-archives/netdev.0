From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] tcp: add tcpi_bytes_received to tcp_info
Date: Tue, 28 Apr 2015 15:21:26 -0700
Message-ID: <1430259686.28069.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430242338-23156-1-git-send-email-edumazet@google.com>
	 <1430242338-23156-3-git-send-email-edumazet@google.com>
	 <CAK6E8=eD84Qb1ZJO3fm2KVMMoth44QmsFG8ZmCZ5a1HaX82jpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35151 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031052AbbD1WVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 18:21:50 -0400
Received: by igbyr2 with SMTP id yr2so104296970igb.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 15:21:48 -0700 (PDT)
In-Reply-To: <CAK6E8=eD84Qb1ZJO3fm2KVMMoth44QmsFG8ZmCZ5a1HaX82jpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-28 at 14:07 -0700, Yuchung Cheng wrote:

> Account for received syn-data when rcv_nxt is updated in tcp_fastopen.c?

Right, I'll send a v2 with the following FO part :

Note that I do not call the helper to keep it static and inline
candidate.

Thanks !

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index e3d87aca6be8..b1b110d07816 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -206,6 +206,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
                        skb_set_owner_r(skb2, child);
                        __skb_queue_tail(&child->sk_receive_queue, skb2);
                        tp->syn_data_acked = 1;
+                       tp->bytes_received = end_seq - (TCP_SKB_CB(skb)->seq + 1);
                } else {
                        end_seq = TCP_SKB_CB(skb)->seq + 1;
                }
