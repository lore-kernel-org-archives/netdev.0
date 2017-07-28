From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v1 1/5] tcp: Added callback for timed sender operations
Date: Fri, 28 Jul 2017 21:59:15 +0200
Message-ID: <20170728195919.10099-2-natale.patriciello@gmail.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:38120 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752599AbdG1UAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:00:47 -0400
Received: by mail-wm0-f65.google.com with SMTP id y206so5542011wmd.5
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 13:00:47 -0700 (PDT)
In-Reply-To: <20170728195919.10099-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Standard TCP is ACK-clocked, or in other words it must wait for ACKs after
sending a full window size bytes. However, in some particular cases, a
congestion control would like to be able to tell the TCP implementation when it
is possible to send segments through a timer. This patch adds the interface
(completely optional) between a congestion control and the TCP implementation.

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
Tested-by: Ahmed Said <ahmed.said@uniroma2.it>
---
 include/net/tcp.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index be6223c586fa..bf661ccc53a2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -939,6 +939,14 @@ struct tcp_congestion_ops {
 	/* get info for inet_diag (optional) */
 	size_t (*get_info)(struct sock *sk, u32 ext, int *attr,
 			   union tcp_cc_info *info);
+	/* get the expiration time for the send timer (optional) */
+	unsigned long (*get_send_timer_exp_time)(struct sock *sk);
+	/* no data to transmit at the timer expiration (optional) */
+	void (*no_data_to_transmit)(struct sock *sk);
+	/* the send timer is expired (optional) */
+	void (*send_timer_expired)(struct sock *sk);
+	/* the TCP has sent some segments (optional) */
+	void (*segment_sent)(struct sock *sk, u32 sent);
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
-- 
2.13.2
