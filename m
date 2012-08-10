From: Dmitry Melekhov <dm@belkam.com>
Subject: no network to ip phones
Date: Fri, 10 Aug 2012 07:54:19 +0400
Message-ID: <502485EB.4040801@belkam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.belkam.com ([88.80.32.211]:42704 "HELO relay2.belkam.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750704Ab2HJED0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 00:03:26 -0400
Received: from inetgw1.p98.belkam.com (localhost [127.0.0.1])
	(using TLSv1.1 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by relay2.belkam.com (Postfix) with ESMTPS id C0793200CA
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 07:54:20 +0400 (MSK)
Received: from localhost (localhost [127.0.0.1])
	by inetgw1.p98.belkam.com (Postfix) with ESMTP id BA18E6261B
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 07:54:20 +0400 (MSK)
Received: from inetgw1.p98.belkam.com ([127.0.0.1])
	by localhost (inetgw1.p98.belkam.com [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id mrtNlAUZCucJ for <netdev@vger.kernel.org>;
	Fri, 10 Aug 2012 07:54:20 +0400 (MSK)
Received: from [192.168.22.229] (dm.p98.belkam.com [192.168.22.229])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by inetgw1.p98.belkam.com (Postfix) with ESMTPS id A8A37625EF
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 07:54:20 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!


I run asterisk on x86 server , with kernel 2.6.39 all is OK, but with 3.0.38
and 3.0.39 after some time server lost connections to sip phones:

[Aug 2 15:02:51] WARNING[5790]: chan_sip.c:3392 __sip_xmit: sip_xmit of
0x9bd88f8 (len 548) to 192.168.26.116:5060 returned -2: Network is down

ping says the same, but other hosts work OK (from any other networks), only sip
phones are affected.

interfaces:

[root@asterisk ~]# ifconfig
eth0 Link encap:Ethernet HWaddr 00:30:48:85:5B:0A
           inet addr:192.168.22.19 Bcast:192.168.22.255 Mask:255.255.255.0
           inet6 addr: fe80::230:48ff:fe85:5b0a/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
           RX packets:61867 errors:0 dropped:666 overruns:0 frame:0
           TX packets:25992 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:7013187 (6.6 MiB) TX bytes:3754003 (3.5 MiB)

eth0.9 Link encap:Ethernet HWaddr 00:30:48:85:5B:0A
           inet addr:192.168.42.132 Bcast:192.168.42.255 Mask:255.255.255.128
           inet6 addr: fe80::230:48ff:fe85:5b0a/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
           RX packets:11634 errors:0 dropped:0 overruns:0 frame:0
           TX packets:10753 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2407018 (2.2 MiB) TX bytes:2439435 (2.3 MiB)


default gateway is on eth0, i.e. not tagged.

hardware:
[root@asterisk ~]# /sbin/lspci -nn | grep -i net
01:01.0 Ethernet controller [0200]: Intel Corporation 82547GI Gigabit Ethernet
Controller [8086:1075]
02:01.0 Ethernet controller [0200]: Digium, Inc. Wildcard TE122 single-span
T1/E1/J1 card [d161:8001] (rev 11)
03:0a.0 Ethernet controller [0200]: Intel Corporation 82541GI Gigabit Ethernet
Controller [8086:1076]

I use elrepo kernel build, here is there bug report:

http://elrepo.org/bugs/view.php?id=294

I have no idea what can cause this problem :-(

Thank you!

btw, here is bug report:


https://bugzilla.kernel.org/show_bug.cgi?id=45681
