From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] ICMP: ICMP_MIB_OUTMSGS increment duplicated
Date: Wed, 16 Jan 2008 17:59:23 +0800
Message-ID: <478DD57B.6020503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50683 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbYAPKAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 05:00:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tree net-2.6.25, commit "96793b482540f3a26e2188eaf75cb56b7829d3e3"
made a mistake.

In that patch, David L added a icmp_out_count() in ip_push_pending_frames(),
remove icmp_out_count() from icmp_reply(). But he forgot to remove 
icmp_out_count() from icmp_send() too.
Since icmp_send and icmp_reply will call icmp_push_reply, which will call
ip_push_pending_frames, a duplicated increment happened in icmp_send.

This patch remove the icmp_out_count from icmp_send too.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff -Nurp linux-2.6.24.rc8.org/net/ipv4/icmp.c linux-2.6.24.rc8/net/ipv4/icmp.c
--- linux-2.6.24.rc8.org/net/ipv4/icmp.c	2008-01-16 17:45:02.000000000 +0800
+++ linux-2.6.24.rc8/net/ipv4/icmp.c	2008-01-16 17:52:13.000000000 +0800
@@ -540,7 +540,6 @@ void icmp_send(struct sk_buff *skb_in, i
 	icmp_param.data.icmph.checksum	 = 0;
 	icmp_param.skb	  = skb_in;
 	icmp_param.offset = skb_network_offset(skb_in);
-	icmp_out_count(icmp_param.data.icmph.type);
 	inet_sk(icmp_socket->sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;

--
WCN


