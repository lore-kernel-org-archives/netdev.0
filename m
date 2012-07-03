From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Tue, 03 Jul 2012 11:54:17 +0200
Message-ID: <1341309257.2583.153.camel@edumazet-glaptop>
References: <1341307524.2583.115.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Mark Gordon <msg@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43974 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab2GCJyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:54:24 -0400
Received: by eeit10 with SMTP id t10so2387285eei.19
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2012 02:54:23 -0700 (PDT)
In-Reply-To: <1341307524.2583.115.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-03 at 11:25 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> commit 7bc0f28c7a0c (netem: rate extension) did wrong maths when packet
> is enqueued while queue is not empty.
> 
> Result is unexpected cumulative delays
> 
> # tc qd add dev eth0 root est 1sec 4sec netem delay 200ms rate 100kbit
> # ping -i 0.1 172.30.42.18
> PING 172.30.42.18 (172.30.42.18) 56(84) bytes of data.
> 64 bytes from 172.30.42.18: icmp_req=1 ttl=64 time=208 ms
> 64 bytes from 172.30.42.18: icmp_req=2 ttl=64 time=424 ms
> 64 bytes from 172.30.42.18: icmp_req=3 ttl=64 time=838 ms
> 64 bytes from 172.30.42.18: icmp_req=4 ttl=64 time=1142 ms
> 64 bytes from 172.30.42.18: icmp_req=5 ttl=64 time=1335 ms
> 64 bytes from 172.30.42.18: icmp_req=6 ttl=64 time=1949 ms
> 64 bytes from 172.30.42.18: icmp_req=7 ttl=64 time=2450 ms
> 64 bytes from 172.30.42.18: icmp_req=8 ttl=64 time=2840 ms
> 64 bytes from 172.30.42.18: icmp_req=9 ttl=64 time=3121 ms
> 64 bytes from 172.30.42.18: icmp_req=10 ttl=64 time=3291 ms
> 64 bytes from 172.30.42.18: icmp_req=11 ttl=64 time=3784 ms
> 
> This patch also fixes a double drop accounting in case packet is dropped
> in tfifo_enqueue()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Andreas Terzis <aterzis@google.com>
> Cc: Mark Gordon <msg@google.com>
> Cc: Hagen Paul Pfeifer <hagen@jauu.net>
> ---

Hmm, I'll send a v2
