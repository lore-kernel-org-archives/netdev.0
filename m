From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 14:17:19 -0200
Message-ID: <1199981839.8931.35.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:38120 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755499AbYAJQRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 11:17:25 -0500
Received: from mailhub1.br.ibm.com (mailhub1 [9.18.232.109])
	by igw2.br.ibm.com (Postfix) with ESMTP id 5ABE817F433
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 14:11:42 -0200 (BRDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AGHLbG3756118
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 14:17:22 -0200
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AGHLuX028318
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 14:17:21 -0200
Received: from [9.18.250.201] (cafe.br.ibm.com [9.18.250.201])
	by d24av02.br.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m0AGHJE4028248
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 14:17:20 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, 

I've perceived that there is a performance issue when running netperf
against 4 e1000 links connected end-to-end to another machine with 4
e1000 interfaces. 

I have 2 4-port interfaces on my machine, but the test is just
considering 2 port for each interfaces card.

When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
of transfer rate. If I run 4 netperf against 4 different interfaces, I
get around 720 * 10^6 bits/sec.  

If I run the same test against 2 interfaces I get a 940 * 10^6 bits/sec
transfer rate also, and if I run it against 3 interfaces I get around
850 * 10^6 bits/sec performance. 

I got this results using the upstream netdev-2.6 branch kernel plus
David Miller's 7 NAPI patches set[1]. In the kernel 2.6.23.12 the result
is a bit worse, and the the transfer rate was around 600 * 10^6
bits/sec.

[1] http://marc.info/?l=linux-netdev&m=119977075917488&w=2

PS: I am not using a switch in the middle of interfaces (they are
end-to-end) and the connections are independents.

-- 
Breno Leitao <leitao@linux.vnet.ibm.com>

