From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Whence a description of how to enable TCP FASTOPEN in a
 net-next kernel?
Date: Mon, 17 Dec 2012 13:56:51 -0800
Message-ID: <1355781411.9380.12.camel@edumazet-glaptop>
References: <50CF8E2A.5020201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:37382 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab2LQV4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 16:56:53 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so39337pad.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 13:56:53 -0800 (PST)
In-Reply-To: <50CF8E2A.5020201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-17 at 13:27 -0800, Rick Jones wrote:
> Is there a writeup describing the steps needed to enable TCP_FASTOPEN in 
> a net-next kernel? (pulled earlier today)
> 
> I am looking to debug netperf's support for enabling the feature and I 
> want to make sure I've enabled things correctly in the kernel.  Thusfar 
> I've set the tcp_fastopen sysctl to one, and I see the "client" side of 
> netperf making the appropriate sendto() call, and I see what appears to 
> be the correct setsockopt being set on the server side, but my tcpdump 
> traces of the traffic flowing over loopback in my test setup, while 
> showing the client including the experimental option, do not show the 
> server side responding:
> 
> 13:10:23.870202 IP localhost.5923 > localhost.54363: Flags [S], seq 
> 935361110, win 43690, options [mss 65495,sackOK,TS val 889762 ecr 
> 0,nop,wscale 7,Unknown Option 254f989], length 0
> 13:10:23.870214 IP localhost.54363 > localhost.5923: Flags [S.], seq 
> 4210640362, ack 935361111, win 43690, options [mss 65495,sackOK,TS val 
> 889762 ecr 889762,nop,wscale 7], length 0
> 
> The netserver side strace snippet:
> 
> 3861  socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 8
> 3861  getsockopt(8, SOL_SOCKET, SO_SNDBUF, [16384], [4]) = 0
> 3861  getsockopt(8, SOL_SOCKET, SO_RCVBUF, [87380], [4]) = 0
> 3861  setsockopt(8, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 3861  bind(8, {sa_family=AF_INET, sin_port=htons(0), 
> sin_addr=inet_addr("0.0.0.0")}, 16) = 0
> 3861  setsockopt(8, SOL_TCP, 0x17 /* TCP_??? */, [5], 4) = 0
> 3861  listen(8, 5)                      = 0
> ...
> 3861  accept(8, {sa_family=AF_INET, sin_port=htons(5923), 
> sin_addr=inet_addr("127.0.0.1")}, [16]) = 9
> 3861  recvfrom(9, "n", 1, 0, NULL, NULL) = 1
> 3861  sendto(9, "n", 1, 0, NULL, 0)     = 1
> 3861  getsockopt(9, SOL_SOCKET, SO_RCVBUF, [262030], [4]) = 0
> 3861  getsockopt(9, SOL_SOCKET, SO_SNDBUF, [663750], [4]) = 0
> 3861  close(9)                          = 0

> lather, rinse, repeat the accept sequence off that listen endpoint.
> 
> happy benchmarking,

I guess you need to enable fastopen both for client and server :

echo 3 >/proc/sys//net/ipv4/tcp_fastopen
