From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [PATCH 0/4]UDP memory accounting and limitation(take 5)
Date: Fri, 12 Oct 2007 21:00:20 +0900
Message-ID: <470F61D4.6040808@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBETFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:51858 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055AbXJLMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:00:25 -0400
Received: from mlsv5.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 6937337C86
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 21:00:24 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I revised a patch set of UDP memory accounting and
limitation.

This patch set is for kernel 2.6.23. The differences
from take 4 are

* removing unnessesary EXPORT_SYMBOLs
* adding minimal limit of /proc/sys/net/udp_mem
* bugfix of UDP limit affecting protocol other
  than UDP
* introducing __ip_check_max_skb_pages()
* using CTL_UNNUMBERED
* adding udp_mem usage to Documentation/networking/ip_sysctl.txt

How to use UDP memory limitation:

This patch set add

/proc/sys/net/ipv4/udp_mem

as a tuning parameter. 

When you give the number that is greater than 4096,
UDP memory limitation will work. The number of pages
for socket buffer is limited up to udp_mem[pages].

Currently this function drops the packet when
it is sent or received and the number of pages for
socket buffer is beyond the limit. It won't collect
the buffer that is already allocated.

On the other hand, udp_mem is specified as 4096,
UDP memory limitaion will not work.
The deafult number of udp_mem is 4096. 

Comment, review and test are welcome.

Thanks,

Satoshi Oshima
