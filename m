From: Robert Martin <robertm83@gmail.com>
Subject: NETDEV-BCM43XX BUG - Failure to associate AP with latest devscape
 git pull..
Date: Sun, 03 Dec 2006 16:21:03 -0500
Message-ID: <45733FBF.5020800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:12777 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1759191AbWLDDVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 22:21:13 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3658513wxd
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 19:21:12 -0800 (PST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel = 2.6.19 SMP
bcmwl5 firmware = 4.10.40.0
Devscape bcm43xx_d80211 driver = Latest git pull
Wireless card =  Broadcom Corporation Dell Wireless 1390 WLAN Mini-PCI 
Card (rev 01) (PCI-E)

I seem to be having a problem associating with my AP--everything appears 
fine and I can bring my wireless adapter up (the LED lights up 
correctly), and I don't see complaints about firmware/IRQs in the dmesg 
output.  I am able to see operating APs with an "iwlist wlan0 scan", but 
I am unable to connect to the AP, with or without WEP encryption enabled 
(tried none, hex and ascii; nothing worked).  This is with the latest 
wireless-dev pull and a vanilla 2.6.19 kernel with "irqpoll" option 
enabled, otherwise it misbehaves.  I would be happy to give more 
information if requested, or try different kernel/firmware options.

Here I have provided my dhclient connect attempt output with the 
relevant tcpdump.  Thank you greatly for your time.

========DHCLIENT ATTEMPT OUTPUT 
BEGIN======================================================
Internet Systems Consortium DHCP Client V3.0.4-RedHat
Copyright 2004-2006 Internet Systems Consortium.
All rights reserved.
For info, please visit

wmaster0: unknown hardware address type 801
/sbin/dhclient-script: configuration for wlan0 not found. Continuing 
with defaults.
/etc/sysconfig/network-scripts/network-functions: line 78: wlan0: No 
such file or directory
wmaster0: unknown hardware address type 801
Listening on LPF/wlan0/00:14:a5:da:ba:87
Sending on   LPF/wlan0/00:14:a5:da:ba:87
Sending on   Socket/fallback
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 4
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 9
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 11
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 8
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 9
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 14
DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 6
No DHCPOFFERS received.
No working leases in persistent database - sleeping.
/sbin/dhclient-script: configuration for wlan0 not found. Continuing 
with defaults.
/etc/sysconfig/network-scripts/network-functions: line 78: wlan0: No 
such file or directory

========DHCLIENT CONNECT OUTPUT 
END=======================================================

========TCPDUMP (tcpdump -vvv -i wlan0 -XX) OUTPUT 
BEGIN========================================================

19:04:08.726651 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 6187 0101 0600 789b  ...D.C.4a.....x.
       0x0030:  990d 0000 0000 0000 0000 0000 0000 0000  ................
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
19:04:12.001529 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, secs:4, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 6183 0101 0600 789b  ...D.C.4a.....x.
       0x0030:  990d 0004 0000 0000 0000 0000 0000 0000  ................
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
19:04:21.000548 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, secs:13, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 617a 0101 0600 789b  ...D.C.4az....x.
       0x0030:  990d 000d 0000 0000 0000 0000 0000 0000  ................
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
19:04:32.001816 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, secs:24, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 616f 0101 0600 789b  ...D.C.4ao....x.
       0x0030:  990d 0018 0000 0000 0000 0000 0000 0000  ................
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
19:04:40.001672 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, secs:32, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 6167 0101 0600 789b  ...D.C.4ag....x.
       0x0030:  990d 0020 0000 0000 0000 0000 0000 0000  ................
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
19:04:49.000321 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, secs:41, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 615e 0101 0600 789b  ...D.C.4a^....x.
       0x0030:  990d 0029 0000 0000 0000 0000 0000 0000  ...)............
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
19:05:03.000152 IP (tos 0x10, ttl  16, id 0, offset 0, flags [none], 
proto: UDP (17), length: 328) 0.0.0.0.bootpc > 255.255.255.255.bootps: 
BOOTP/DHCP, Request from 00:14:a5:da:ba:87 (oui Unknown), length: 300, 
xid:0x789b990d, secs:55, flags: [none] (0x0000)
         Client Ethernet Address: 00:14:a5:da:ba:87 (oui Unknown) [|bootp]
       0x0000:  ffff ffff ffff 0014 a5da ba87 0800 4510  ..............E.
       0x0010:  0148 0000 0000 1011 a996 0000 0000 ffff  .H..............
       0x0020:  ffff 0044 0043 0134 6150 0101 0600 789b  ...D.C.4aP....x.
       0x0030:  990d 0037 0000 0000 0000 0000 0000 0000  ...7............
       0x0040:  0000 0000 0000 0014 a5da ba87 0000 0000  ................
       0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................

===========TCPDUMP OUTPUT 
END==============================================================
