From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Question on arping not updating the arp table in v3.10.61
Date: Wed, 21 Jan 2015 18:30:44 -0500
Message-ID: <54C036A4.7000204@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:56537 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830AbbAUXan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 18:30:43 -0500
Received: from dflxv15.itg.ti.com ([128.247.5.124])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id t0LNUghR013543
	for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 17:30:43 -0600
Received: from DLEE70.ent.ti.com (dlemailx.itg.ti.com [157.170.170.113])
	by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id t0LNUg4o019886
	for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 17:30:42 -0600
Received: from [158.218.104.233] (ileax41-snat.itg.ti.com [10.172.224.153])	by
 dflp32.itg.ti.com (8.14.3/8.13.8) with ESMTP id t0LNUg4V016295	for
 <netdev@vger.kernel.org>; Wed, 21 Jan 2015 17:30:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am facing an issue on my board that is using v3.10.61 Linux kernel. 
The arping -c 3 -f <IP address> doesn't update the arp table even though 
I get a proper response

root@keystone-evm:~# arping -b -c 3 -I eth0 -f 158.218.104.3
ARPING to 158.218.104.3 from 158.218.104.192 via eth0
Unicast reply from 158.218.104.3 [0:12:1:f7:d6:ff] 0.751ms
Sent 1 probe(s) (1 broadcast(s))
Received 1 replies (0 request(s), 0 broadcast(s))

root@keystone-evm:~# arp -n -a
? (158.218.104.1) at 00:00:0c:07:ac:68 [ether]  on eth0
? (158.218.104.233) at d4:be:d9:3d:b6:c1 [ether]  on eth0

But by enabling following sysfs entry, it works.

  echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_accept

Is this the expected behavior? On my ubuntu Linux pc with v3.2 running I 
don't have to do this and it always update the arp table.

Thanks for your help.

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
