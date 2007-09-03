From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 8975] New: Broadcasting fails when default gateway can't
 be reached.
Date: Mon, 3 Sep 2007 17:59:28 +0100
Message-ID: <20070903175928.2a001d51@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58782 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660AbXICQ65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 12:58:57 -0400
Received: from oldman ([217.206.93.210])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l83Gwoxi004044
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Sep 2007 09:58:53 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This looks like another manifestation of the Linux arp differences
from end user expectation.

Begin forwarded message:

Date: Mon,  3 Sep 2007 08:19:26 -0700 (PDT)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 8975] New: Broadcasting fails when default gateway can't be reached.


http://bugzilla.kernel.org/show_bug.cgi?id=8975

           Summary: Broadcasting fails when default gateway can't be
                    reached.
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.22
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@osdl.org
        ReportedBy: enrique.arizonbenito@gmail.com


Most recent kernel where this bug did not occur: N/A (I tried with 2.6.18-4 and
2.6.22
Distribution: - Debian 4.0 2.6.18-4 kernel & custom-kernel 2.6.22 from Mainline
-

Hardware Environment:

serv#lspci
00:00.0 Host bridge: VIA Technologies, Inc. VT82C693A/694x [Apollo PRO133x]
(rev 44)
00:01.0 PCI bridge: VIA Technologies, Inc. VT82C598/694x [Apollo MVP3/Pro133x
AGP]
00:07.0 ISA bridge: VIA Technologies, Inc. VT82C596 ISA [Mobile South] (rev 23)
00:07.1 IDE interface: VIA Technologies, Inc.
VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 10)
00:07.3 Host bridge: VIA Technologies, Inc. VT82C596 Power Management (rev 30)
00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 RL/VR AGP


serv:~# lsmod 
Module                  Size  Used by
ipv6                  213856  14 
ipt_MASQUERADE          3584  1 
iptable_nat             7044  1 
ip_nat                 16428  2 ipt_MASQUERADE,iptable_nat
ip_conntrack           47156  3 ipt_MASQUERADE,iptable_nat,ip_nat
nfnetlink               6680  2 ip_nat,ip_conntrack
ip_tables              12104  1 iptable_nat
x_tables               12932  3 ipt_MASQUERADE,iptable_nat,ip_tables
dm_snapshot            15644  0 
dm_mirror              18000  0 
dm_mod                 48952  2 dm_snapshot,dm_mirror
loop                   14216  0 
serio_raw               6532  0 
floppy                 52004  0 
i2c_viapro              8340  0 
i2c_core               19472  1 i2c_viapro
psmouse                34568  0 
rtc                    11572  0 
via_agp                 9728  1 
agpgart                29360  1 via_agp
shpchp                 32796  0 
pci_hotplug            28088  1 shpchp
pcspkr                  2816  0 
evdev                   9088  0 
ext3                  116488  2 
jbd                    47272  1 ext3
ide_disk               14848  4 
via82cxxx               8452  0 [permanent]
generic                 5508  0 [permanent]
ide_core              107760  3 ide_disk,via82cxxx,generic
8139cp                 20736  0 
8139too                24192  0 
mii                     5376  2 8139cp,8139too
processor              23724  0 


serv:~# cat /proc/interrupts 
           CPU0       
  0:     798632          XT-PIC  timer
  1:         38          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  6:          2          XT-PIC  floppy
  8:          1          XT-PIC  rtc
 10:     228692          XT-PIC  eth0
 14:      11482          XT-PIC  ide0
NMI:          0 
LOC:          0 
ERR:          0
MIS:          0



Software Environment:
serv:~# ifconfig 
eth0      Link encap:Ethernet  HWaddr 00:C0:26:A0:C6:99  
          inet addr:192.168.0.10  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::2c0:26ff:fea0:c699/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:62020 errors:0 dropped:0 overruns:0 frame:0
          TX packets:174169 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:10881985 (10.3 MiB)  TX bytes:204869648 (195.3 MiB)
          Interrupt:10 Base address:0xe800 

eth0:1    Link encap:Ethernet  HWaddr 00:C0:26:A0:C6:99  
          inet addr:192.168.10.1  Bcast:192.168.10.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:10 Base address:0xe800 

serv:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
192.168.10.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0
0.0.0.0         192.168.0.1     0.0.0.0         UG    0      0        0 eth0

Problem Description:
 Broadcasting fail in next "unusual" cases:
 - default route points to any gateway (192.168.0.1).
 - The physical ethernet connection to the gateway is broke so ARP doesn't
work.

Steps to reproduce:

  Case 1: Router is connected:

  Client -------  switch -------- router
                     |
                     |
                   Server

  Case 2: Router is diconnected:

  Client -------  switch          router
                     |
                     |
                   Server

 - I setup a DHCP server and a client machine tries to get an IP setup from it.
 - The client and the server always have a correct physical connection.
 - With the physical connection working fine (wire connected) everything works
fine.
 - When the router get disconnected next happen:

   The Client never receives the broadcast data with the IP setup.

   Still, using tcpdump I can see the server trying to broadcast the data
through physical interface eth0 -but such data never goes out the wire since
the client hangs for ever).

   tcpdump also shows the server is trying to solve the ARP entry for the
router IP.

   When I delete the default gateway (route del -net 0.0.0.0) everything works
fine again.


   (Without the eth0:1 alias the behaviour is similar)

 Regards,

 Enrique


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
