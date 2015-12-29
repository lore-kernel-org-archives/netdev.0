From: Stas Sergeev <stsp@list.ru>
Subject: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 13:54:18 +0300
Message-ID: <5682665A.7090102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback6.mail.ru ([94.100.181.147]:59048 "EHLO
	fallback6.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbbL2Ky0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 05:54:26 -0500
Received: from smtp53.i.mail.ru (smtp53.i.mail.ru [94.100.177.113])
	by fallback6.mail.ru (mPOP.Fallback_MX) with ESMTP id B56EB1BC1C11
	for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 13:54:22 +0300 (MSK)
Received: from [31.28.31.88] (port=34216 helo=[192.168.0.237])
	by smtp53.i.mail.ru with esmtpa (envelope-from <stsp@list.ru>)
	id 1aDrv1-0002HP-SM
	for netdev@vger.kernel.org; Tue, 29 Dec 2015 13:54:20 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I was hitting a strange problem when some internet hosts
suddenly stops responding until I reboot. ping to these
host gives "Destination Host Unreachable". After the
initial confusion, I've finally got to
ip route get
and got something quite strange.


Example for GOOD address (the one that I can ping):

ip route get 91.189.89.237
91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
    cache


Example for BAD address (the one that stopped responding):

ip route get 91.189.89.238
91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
    cache <redirected>


Two things differ: the <redirected> mark appears, and the
gateway changed from 192.168.8.1 to 192.168.0.1.
Now, 192.168.0.1 is also a valid gateway, but it is outside
of the network mask for the eth0 interface:

ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:50:43:00:0b:e0
          inet addr:192.168.10.202  Bcast:192.168.11.255  Mask:255.255.252.0


As a result, this route simply doesn't work.
I checked with tcpdump - the icmp packets do not even go
to eth0 - they instead can be captured on lo interface for
some reason.

So my question is: why does linux allow an invalid redirect
entries? Is it a problem with my setup, or some kernel bug,
or some router setup problem? Where should I look into, to
nail this down?
