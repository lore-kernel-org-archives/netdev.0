From: Hua Zhong <hzhong@gmail.com>
Subject: [PATCH] fix unlikely usage in tcp_transmit_skb()
Date: Wed, 26 Apr 2006 09:50:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0604260947040.2907@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.202]:15545 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932075AbWDZQvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 12:51:53 -0400
Received: by nz-out-0102.google.com with SMTP id 40so1579816nzk
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 09:51:52 -0700 (PDT)
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[I hope this time it's OK - I'm sending from pine/Linux]

The following unlikely should be replaced by likely because the condition happens every time unless there is a hard error to transmit a packet.

Signed-off-by: Hua Zhong <hzhong@gmail.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a28ae59..743016b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -465,7 +465,7 @@ #define SYSCTL_FLAG_SACK	0x4
  	TCP_INC_STATS(TCP_MIB_OUTSEGS);

  	err = icsk->icsk_af_ops->queue_xmit(skb, 0);
-	if (unlikely(err <= 0))
+	if (likely(err <= 0))
  		return err;

  	tcp_enter_cwr(sk);
