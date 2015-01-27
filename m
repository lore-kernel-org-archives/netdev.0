From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Does arping update arp table?
Date: Tue, 27 Jan 2015 14:23:33 -0500
Message-ID: <54C7E5B5.8060401@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:46982 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757900AbbA0TXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 14:23:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Experts,

The ARP code (net/ipv4/arp.c) seems to treat arp response resulting from 
a arping as an unsolicited response and doesn't update the arp table. 
This get updated if the per interface accept sys ctrl is enabled. This 
command seems to have been updating the arp table in older kernel. For 
example on a Ubuntu 12.04 based kernel I see

a0868495@ula0868495 ~/Project/linux-keystone $ sudo arping 192.168.1.10 
-c 1 -f
ARPING 192.168.1.10 from 192.168.1.9 eth0
Unicast reply from 192.168.1.10 [00:1B:A9:02:26:10]  5.411ms
Sent 1 probes (1 broadcast(s))
Received 1 response(s)
a0868495@ula0868495 ~/Project/linux-keystone $ arp -n -a
? (192.168.1.10) at 00:1b:a9:02:26:10 [ether] on eth0
? (192.168.1.1) at 00:1f:90:6d:5c:a8 [ether] on eth0

a0868495@ula0868495 ~/Project/linux-keystone $ uname -a
Linux ula0868495 3.2.0-23-generic #36-Ubuntu SMP Tue Apr 10 20:41:14 UTC 
2012 i686 i686 i386 GNU/Linux

However this command doesn't update the arp table on my Keystone EVM 
based on v3.19.x and also newer ubuntu machine based on v3.11. Is this 
expected behavior? I believe the arp response resulting from a arping 
command is controlled through per interface accept sys control like as 
in gratuitous arp. Please repond.

Thanks and regards,
-- 
Murali Karicheri
Linux Kernel, Texas Instruments
