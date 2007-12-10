From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: all is not right with the world...
Date: Sun, 9 Dec 2007 17:52:44 -0800
Message-ID: <OFF55A202E.AA9318A6-ON882573AD.000A24C5-882573AD.000A5417@us.ibm.com>
References: <OFED01B00C.3B84EA11-ON882573AD.0001073B-882573AD.0001C3EC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47516 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbXLJBxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 20:53:04 -0500
In-Reply-To: <OFED01B00C.3B84EA11-ON882573AD.0001073B-882573AD.0001C3EC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Never mind...

Though I hate the "TCP" in the name (maybe overload UDP_CONNECTED?), I see 
datagram
sockets are in fact setting it, and my EDESTADDRREQ was a bug in my test 
program. :-)

                                                +-DLS

netdev-owner@vger.kernel.org wrote on 12/09/2007 04:19:12 PM:

>         I don't know if you've fixed it already, but I was writing some
> UDPv6 tests in 2.6.23.9 and was getting EDESTADDRREQ unexpectedly. When
> I looked at the kernel code, I found:
> 
> gerrit/wscott     1.115       | int udpv6_sendmsg(struct kiocb *iocb, 
> struct sock *sk,
> shemminger        1.57        | struct 
> msghdr *msg, size_t len)
> torvalds          1.1         | {
> ...
> 
> yoshfuji          1.53        |                  } else if 
(!up->pending) 
> {
> yoshfuji          1.53        |                                  if 
> (sk->sk_state != TCP_ESTABLISHED)
> yoshfuji          1.53        |  return -EDESTADDRREQ;
> yoshfuji          1.53        |                                  daddr = 

> &np->daddr;
> 
>         I wouldn't expect a UDP socket to be setting
> sk_state to TCP_ESTABLISHED...
> 
>                                                         +-DLS
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

