From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use raw_cpu ops in snmp stats bh
Date: Thu, 06 Mar 2014 07:04:32 -0800
Message-ID: <1394118272.27473.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394110536-4532-1-git-send-email-sergey.senozhatsky@gmail.com>
	 <1394117074.27473.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394117074.27473.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-06 at 06:44 -0800, Eric Dumazet wrote:

> I think you missed a lot of mails sent by Chrisoph Lameter recently...

s/Chrisoph/Christoph/

Appropriate fix would be the following one, please submit this formally.


Fixes: f19c29e3e391 ("tcp: snmp stats for Fast Open, SYN rtx, and data pkts")

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5286228679bd..df063a32a177 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -87,7 +87,7 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 		tcp_rearm_rto(sk);
 	}
 
-	NET_ADD_STATS_BH(sock_net(sk), LINUX_MIB_TCPORIGDATASENT,
+	NET_ADD_STATS(sock_net(sk), LINUX_MIB_TCPORIGDATASENT,
 			 tcp_skb_pcount(skb));
 }
 
