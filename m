From: smka2012@email.de
Subject: Question regarding kernel panic in net/ipv4/tcp_output.c
Date: Tue, 4 Sep 2012 13:55:12 +0200 (CEST)
Message-ID: <trinity-daf22487-c4bf-4a4e-ae69-ed50d70f6169-1346759712289@3capp-webde-bs16>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:65264 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752939Ab2IDLzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 07:55:13 -0400
Received: from 3capp-webde-bs16.server.lan ([172.19.170.16]) by
 mriweb.server.lan (mriweb002) with ESMTPA (Nemesis) id
 0LlrYM-1ThvUW1NoG-00ZKjP for <netdev@vger.kernel.org>; Tue, 04 Sep 2012
 13:55:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
 
I recently had a severe issue with multiple servers that stopped working at the same time. By using the stacktrace, I could locate the following line in the tcp_retransmit_skb function of the tcp_output.c kernel source that led to a kernel panic on all servers. I am using Debian 6.0 with the kernel version 2.6.32-45.
 
(gdb) list *(tcp_retransmit_skb+0x66)
0x1a93 is in tcp_retransmit_skb (net/ipv4/tcp_output.c:1905).
1900  if (atomic_read(&sk->sk_wmem_alloc) >
1901      min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
1902   return -EAGAIN;
1903
1904  if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {

--->
1905   if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
1906    BUG();
<---
 
1907   if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
1908    return -ENOMEM;
1909  }
 
Now I am interested in getting to know what can lead to a situation that the condition in line 1905 evaluates true and why the kernel goes into the BUG() function in that case and does not only return an error. All servers reached this line of code. They all were connected to a switch that broke the same time. However, I cannot say if the switch broke before the servers and eventually affected the servers or if the switch was also itself affected by some external event. 
 
Thank you very much for your help.
 
Kind Regards,
Sascha
