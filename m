From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/5] UDP memory accounting and limitation (take 8)
Date: Thu, 15 Nov 2007 16:44:13 -0500
Message-ID: <473CBDAD.1010708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>,
	Hideo AOKI <haoki@redhat.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755970AbXKOVvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 16:51:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is the latest patch set of UDP memory accounting and limitation.

I modified sk_datagram_pages() to avoid using divide instruction.

In addition, I also fixed memory accounting code in udp_recvmsg(),
since, in previous takes, the accounting code referred released
sk_buff's truesize. The fix can be found in 3rd patch of the patch set.

The patch set is for net-2.6. Please apply.


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
