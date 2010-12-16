From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: e1000: more than two seconds to get the flag RUNNING
Date: Thu, 16 Dec 2010 17:17:13 +0100
Message-ID: <4D0A3B89.3010600@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Ski
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50628 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab0LPQRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 11:17:18 -0500
Received: by wwa36 with SMTP id 36so2605176wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 08:17:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

maybe this problem has already been discussed, but I didn't find the thread.
When I put an interface managed by the e1000 driver up, down and up again, I 
must wait more than 2 seconds to get the flag running again.

Here is the sequence:

shelby:~# uname -a
Linux shelby 2.6.37-rc5+ #9 SMP Wed Dec 15 13:16:10 EST 2010 i686 GNU/Linux
shelby:~# lsmod | grep e1000
e1000                  76543  0
shelby:~# lspci | grep Gigabit
01:09.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet 
Controller (rev 02)
shelby:~# cat check_link_state.sh
#!/bin/bash

sleep_time=$1
ip link set eth0 up
ip link set eth0 down
ip link set eth0 up
while [ $sleep_time -gt 0 ] ; do
     date
     #ip link show eth0
     ifconfig eth0 | grep MULTICAST
     sleep 1
     echo ""
     sleep_time=`expr $sleep_time - 1`
done
shelby:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:30:1b:b4:dc:88
           inet addr:10.16.0.72  Bcast:10.16.0.255  Mask:255.255.255.0
           inet6 addr: fe80::230:1bff:feb4:dc88/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:22051 errors:0 dropped:0 overruns:0 frame:0
           TX packets:63 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:2480685 (2.3 MiB)  TX bytes:5242 (5.1 KiB)

shelby:~# ./check_link_state.sh 3
[83270.080175] ADDRCONF(NETDEV_UP): eth0: link is not ready
Thu Dec 16 12:45:56 EST 2010
           UP BROADCAST MULTICAST  MTU:1500  Metric:1

Thu Dec 16 12:45:57 EST 2010
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
[83271.828371] e1000: eth0 NIC Link is Up 100 Mbps Half Duplex, Flow Control: None
[83271.835878] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

Thu Dec 16 12:45:58 EST 2010
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

shelby:~#

I get the same result with a 2.6.15, so it seems that the problem is here since 
a long time.
Has anyone an input for this problem?


Regards,
Nicolas
