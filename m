From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/5] UDP memory accounting and limitation (take 6)
Date: Mon, 29 Oct 2007 17:18:37 -0400
Message-ID: <47264E2D.4080109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845AbXJ2VZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:25:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is the latest patch set of UDP memory accounting and limitation.

The number of pages for socket buffer is limited up to
/proc/sys/net/ipv4/udp_mem. I removed the minimal limit number
to use the feature from the former patch set (take5). And udp_init()
is introduced to calculate default value.

In addition, I added /proc/sys/net/ipv4/udp_rmem and
/proc/sys/net/ipv4/udp_wmem to be able to allocate minimum buffer to
each socket.

As a result, UDP packet is drooped when the number of pages for
socket buffer is beyond the limit and the socket already consumes
minimum buffer.

Detailed change log is below.

Changelog take 5 -> take 6:

  * removed minimal limit of /proc/sys/net/udp_mem
  * added udp_init() for default value calculation of parameters
  * added /proc/sys/net/udp_rmem and /proc/sys/net/udp_rmem
  * added limitation code to ip_ufo_append_data()
  * improved accounting for receiving packet
  * fixed typos
  * rebased to 2.6.24-rc1


Changelog take 4 -> take 5:

  * removing unnessesary EXPORT_SYMBOLs
  * adding minimal limit of /proc/sys/net/udp_mem
  * bugfix of UDP limit affecting protocol other than UDP
  * introducing __ip_check_max_skb_pages()
  * using CTL_UNNUMBERED
  * adding udp_mem usage to Documentation/networking/ip_sysctl.txt


Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
