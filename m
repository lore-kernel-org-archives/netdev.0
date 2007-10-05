From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 0/4]UDP memory accounting (take 4)
Date: Fri, 05 Oct 2007 23:59:05 +0900
Message-ID: <47065139.5030402@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?windows-1252?Q?=22=3F?= =?windows-1252?Q?=3F=40RedHat=22?=
	<haoki@redhat.com>
To: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:37848 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbXJEO7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 10:59:12 -0400
Received: from mlsv12.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id C2D6A33CC2
	for <netdev@vger.kernel.org>; Fri,  5 Oct 2007 23:59:10 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I post a patch set of UDP memory accounting and
limitation.

This patch set is for kernel 2.6.23-rc9. The 
differences from take 3 are

* fixing double accounting bug of ip_send_page()
* adding UDP memory limitation.

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

On the other hand, udp_mem is specified as 4096 or
smaller, UDP memory limitaion will not work.
The deafult number is 0. 

Comment, review and test are welcome.


By the way, David pointed out that we should have
the better solution such as memory reclaiming by
callback from vmm. I seriously consider it. But
As Herbert pointed out, it is very difficult to
apply it to TCP because some of the buffer is
already acked. I couldn't find the good solution 
that is applicable for TCP, UDP, route cache and so on.

Let me know, if you find the good way to solve
this problem.

Thanks,

Satoshi Oshima
