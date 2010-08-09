From: Ben Greear <greearb@candelatech.com>
Subject: Missing device binding relating to tcp_v4_send_reset?
Date: Mon, 09 Aug 2010 10:46:26 -0700
Message-ID: <4C603EF2.9010902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54590 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0HIRqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 13:46:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This snippet is from some patches Patrick did for me some time
back.  I think the rest of his work has been merged upstream, but
this patch was not.  I'm honestly not sure if it's needed or not,
but we've been running with it for at least a year or so and it's
been working fine for us.


diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0207662..1af47db 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -641,6 +641,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
  				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
  	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
  	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
+	arg.bound_dev_if = skb_rtable(skb)->fl.iif;

  	net = dev_net(skb_dst(skb)->dev);
  	ip_send_reply(net->ipv4.tcp_sock, skb,


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

