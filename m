From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Mon, 6 Jun 2011 10:52:47 +0200
Message-ID: <20110606085247.GE31505@secunet.com>
References: <20110606064603.GB31505@secunet.com>
 <20110606064802.GC31505@secunet.com>
 <1307345899.3098.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49607 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756929Ab1FFIta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 04:49:30 -0400
Content-Disposition: inline
In-Reply-To: <1307345899.3098.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2011 at 09:38:19AM +0200, Eric Dumazet wrote:
> 
> Woh, I am afraid I wont have time in following days to check your
> assertion.

My test setup was the following:

I use an IPsec tunnel with tunnel endpoints 192.168.1.1 and 192.168.1.2

Then I do at 192.168.1.2

ping -c1 -M do -s 1410 192.168.1.1

PING 192.168.1.1 (192.168.1.1) 1410(1438) bytes of data.
>From 192.168.1.2 icmp_seq=1 Frag needed and DF set (mtu = 1438)

--- 192.168.1.1 ping statistics ---
0 packets transmitted, 0 received, +1 errors

So the packet matches the mtu but it is not send.
I used a kernel with your patch as head commit.

Reverting your patch (going one commit deeper in the history):

ping -c1 -M do -s 1410 192.168.1.1

PING 192.168.1.1 (192.168.1.1) 1410(1438) bytes of data.
1418 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=3.01 ms

--- 192.168.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.014/3.014/3.014/0.000 ms

> 
> What about original problem then, how should we fix it ?
> 

Hm, I don't know. I'll try to reproduce it here.

> We do have some cases where at least one fragment (the last one) is
> oversized.

trailer_len is used only on IPsec so the poroblem exists only when
using IPsec, right?

> 
> I remember I used Nick Bowler scripts at that time, I might find them
> again...

Would be nice if you could provide these scripts and some informations
on how to reproduce the problem.

