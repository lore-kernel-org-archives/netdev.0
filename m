From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 15:01:16 -0700
Message-ID: <505B922C.7030608@hp.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net> <1347901326.26523.149.camel@edumazet-glaptop> <1347901493.26523.151.camel@edumazet-glaptop> <20120917.130732.1894375657044880827.davem@davemloft.net> <1348067659.26523.949.camel@edumazet-glaptop> <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com> <1348119475.31352.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:21005 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604Ab2ITWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 18:01:17 -0400
In-Reply-To: <1348119475.31352.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 10:37 PM, Eric Dumazet wrote:
> iperf uses 8KB writes, while netperf uses a 16KB default.

For the sake of the archives and posterity, netperf does not have a 
"fixed" default send size.  The "default" will vary with platform and 
platform tuning

What netperf does (for TCP at least) is default the send size to the 
value returned after a getsockopt(SO_SNDBUF) issued against the socket 
just after it is allocated for the data connection.  If the user has 
asked for a specific socket buffer size, there will have been a 
preceding setsockopt(SO_SNDBUF) call.

So, "by default" under Linux, with no options to set the socket buffer 
size, netperf will use 16 KB so long as that is the default (initial) 
value for SO_SNDBUF.

The sequence will go something like:

1) create the data socket
2) if user asked to set socket buffer size call setsockopt()
3) call getsockopt()
4) if the user did not specify a send size, use the value returned from 
the getsockopt() call

So, if one runs netperf on a platform other than Linux, the "default" 
send size may be different.  Similarly, if running under linux, but 
net.ipv4.tcp_wmwm is tweaked, the "default" send size may be different.

happy benchmarking,

rick jones
