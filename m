From: David Stevens <dlstevens@us.ibm.com>
Subject: all is not right with the world...
Date: Sun, 9 Dec 2007 16:19:12 -0800
Message-ID: <OFED01B00C.3B84EA11-ON882573AD.0001073B-882573AD.0001C3EC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:57857 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbXLJATg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 19:19:36 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBA0JQG5007932
	for <netdev@vger.kernel.org>; Sun, 9 Dec 2007 19:19:26 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBA0JLuZ124532
	for <netdev@vger.kernel.org>; Sun, 9 Dec 2007 17:19:26 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBA0JK4T026736
	for <netdev@vger.kernel.org>; Sun, 9 Dec 2007 17:19:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        I don't know if you've fixed it already, but I was writing some
UDPv6 tests in 2.6.23.9 and was getting EDESTADDRREQ unexpectedly. When
I looked at the kernel code, I found:

gerrit/wscott     1.115       | int udpv6_sendmsg(struct kiocb *iocb, 
struct sock *sk,
shemminger        1.57        |                                    struct 
msghdr *msg, size_t len)
torvalds          1.1         | {
...

yoshfuji          1.53        |                  } else if (!up->pending) 
{
yoshfuji          1.53        |                                  if 
(sk->sk_state != TCP_ESTABLISHED)
yoshfuji          1.53        |  return -EDESTADDRREQ;
yoshfuji          1.53        |                                  daddr = 
&np->daddr;

        I wouldn't expect a UDP socket to be setting
sk_state to TCP_ESTABLISHED...

                                                        +-DLS

