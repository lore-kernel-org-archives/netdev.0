From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/3] UDP memory accounting and limitation (take 12)
Date: Sun, 30 Dec 2007 03:57:48 -0500
Message-ID: <47775D8C.5010104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbXL3JAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 04:00:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is the latest patch set of UDP memory accounting and limitation.

I split my patch set into accounting interface consolidation and UDP
memory accounting support. This patch set implements UDP memory
accounting support.

To use consolidated accounting functions, I matched format of udp_mem
sysctl with tcp_mem. UDP IPv6 is finally supported.

However, currently, only receive buffer accounting is implemented.

The patch set was tested on net-2.6.25 tree.


Changelog take 11 -> take 12:
 * split into accounting interface consolidation and UDP memory
   accounting support.
 * used new accounting interface
 * supported IPv6
 * dropped send buffer accounting

Changelog take 10 -> take 11:
 * stoped using spin lock in memory accounting function
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

Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
