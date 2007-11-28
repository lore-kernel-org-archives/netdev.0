From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/4] UDP memory accounting and limitation (take 9)
Date: Wed, 28 Nov 2007 13:48:46 -0500
Message-ID: <474DB80E.5070403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752891AbXK1Swa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 13:52:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is the latest patch set of UDP memory accounting and limitation.

I implemented memory schedule functions for datagram protocols
like stream protocols. Moreover, to call memory schedule functions
from IP layer, I added a wrapper function, sk_wmem_schedule(), as
I proposed last week:

http://www.spinics.net/lists/netdev/msg47950.html

I would like to know whether this is acceptable.

In addition, I restructured patch set. I merged UDP IPv4 memory
accounting code at once and re-divided into introducing sysctls patch
and accounting patch. I think that new structure is easier to review
than previous ones.

The patch set is for net-2.6.

By the way, sk_forward_alloc support is my future work. I'm going
to do it if this patch set is acceptable.


Changelog take 8 -> take 9:
 * introduced mem_schdeule functions for datargram protocols
 * removed protocol check function, from patch set
 * restructured patch set

Changelog take 7 -> take 8:

 * sk_datagram_pages(): avoided using divide instruction
 * udp_recvmsg(): fixed referring released truesize in accounting


Changelog take 6 -> take 7:
 * renamed /proc/sys/net/ipv4/udp_rmem to
   /proc/sys/net/ipv4/udp_rmem_min
 * renamed /proc/sys/net/ipv4/udp_wmem to
   /proc/sys/net/ipv4/udp_wmem_min
 * rebased to net-2.6


Changelog take 5 -> take 6:

 * removed minimal limit of /proc/sys/net/ipv4/udp_mem
 * added udp_init() for default value calculation of parameters
 * added /proc/sys/net/ipv4/udp_rmem and
   /proc/sys/net/ipv4/udp_rmem
 * added limitation code to ip_ufo_append_data()
 * improved accounting for receiving packet
 * fixed typos
 * rebased to 2.6.24-rc1


Changelog take 4 -> take 5:

 * removing unnessesary EXPORT_SYMBOLs
 * adding minimal limit of /proc/sys/net/ipv4/udp_mem
 * bugfix of UDP limit affecting protocol other than UDP
 * introducing __ip_check_max_skb_pages()
 * using CTL_UNNUMBERED
 * adding udp_mem usage to Documentation/networking/ip_sysctl.txt


Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
