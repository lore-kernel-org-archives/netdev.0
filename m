From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/4] [UDP]: memory accounting and limitation (take 11)
Date: Mon, 17 Dec 2007 21:33:57 -0500
Message-ID: <47673195.80004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbXLRCgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 21:36:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I updated patch set of  UDP memory accounting and limitation.

The spin lock that I used in previous take was removed from datagram
memory accounting functions. As David commented, I used socket lock
and backlog processing to keep consistency of memory accounting like
TCP. I added socket lock to places where skbuff is freed, since the
locking is needed to change sk_forward_alloc only.

Moreover, I revised memory accounting functions. As Herbert commented,
I stopped using large inline function and tried to reduce amount of
inline functions.

The patch set was tested on net-2.6 tree.


Changelog take 10 -> take 11:
 * stopped using spin lock in memory accounting function
 * socket lock and backlog processing were used to avoid conflict
   between receive system call processing and BH
 * revised memory accounting functions
 * stooped changing sock_queue_rcv_skb() and skb_set_owner_r()
 * added __udp_queue_rcv_skb to set proper destructor
 * removed udp_set_owner_r()
 * removed reclaim in inet_sock_destruct()

Changelog take 9 -> take 10:
 * supported using sk_forward_alloc
 * introduced several memory accounting functions with spin lock
 * changed detagram receive functions to be able to customize
   destructor
 * fixed accounting bugs in previous takes

Changelog take 8 -> take 9:
 * introduced mem_schdeule functions for datargram protocols
 * removed protocol check function, from patch set
 * restructured patch set

Changelog take 7 -> take 8:

 * sk_datagram_pages(): avoided using divide instruction
 * udp_recvmsg(): fixed referring released truesize in accounting

Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.

