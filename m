From: David Miller <davem@davemloft.net>
Subject: Re: all is not right with the world...
Date: Sun, 09 Dec 2007 22:20:18 -0800 (PST)
Message-ID: <20071209.222018.238869829.davem@davemloft.net>
References: <OFED01B00C.3B84EA11-ON882573AD.0001073B-882573AD.0001C3EC@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751614AbXLJGUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 01:20:20 -0500
In-Reply-To: <OFED01B00C.3B84EA11-ON882573AD.0001073B-882573AD.0001C3EC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Sun, 9 Dec 2007 16:19:12 -0800

>         I don't know if you've fixed it already, but I was writing some
> UDPv6 tests in 2.6.23.9 and was getting EDESTADDRREQ unexpectedly. When
> I looked at the kernel code, I found:
> 
> gerrit/wscott     1.115       | int udpv6_sendmsg(struct kiocb *iocb, 
> struct sock *sk,
> shemminger        1.57        |                                    struct 
> msghdr *msg, size_t len)
> torvalds          1.1         | {
> ...
> 
> yoshfuji          1.53        |                  } else if (!up->pending) 
> {
> yoshfuji          1.53        |                                  if 
> (sk->sk_state != TCP_ESTABLISHED)
> yoshfuji          1.53        |  return -EDESTADDRREQ;
> yoshfuji          1.53        |                                  daddr = 
> &np->daddr;
> 
>         I wouldn't expect a UDP socket to be setting
> sk_state to TCP_ESTABLISHED...

It does when you connect() it.

UDP reuses the TCP state values out of convenience.
