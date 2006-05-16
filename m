From: "David Arnold" <david@mantara.com>
Subject: Re: skge driver oops
Date: Wed, 17 May 2006 07:42:48 +1000
Message-ID: <26928.1147815768@d.0x1.org>
References: <20060512085339.72faaa44@localhost.localdomain>
Reply-To: "David Arnold" <david@mantara.com>
Cc: "David Arnold" <david@mantara.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ash25e.internode.on.net ([203.16.214.182]:64274 "EHLO
	ash25e.internode.on.net") by vger.kernel.org with ESMTP
	id S932196AbWEPVnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 17:43:04 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-reply-to: Your message of "Fri, 12 May 2006 08:53:39 MST."
             <20060512085339.72faaa44@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-->"Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:

  Stephen> I tried reproducing this and can't seem to cause it.

thanks anyway :-)

  Stephen> Are you running anything special that could influence this?
  Stephen> bridging, VLAN's, bonding, netfilter, queueing disciplines,
  Stephen> tc filters, ...

basic Debian/unstable on a Tyan dual-CPU K7.  IPv4/v6.  no netfilter,
VLAN, bonding.  no QoS/Fair Queuing.  BIC, CUBIC and Westwood built in.

eth1      Link encap:Ethernet  HWaddr 00:11:95:FF:2B:BD  
          inet addr:10.0.0.128  Bcast:10.0.0.255  Mask:255.255.255.0
          inet6 addr: 2001:388:c003:0:211:95ff:feff:2bbd/64 Scope:Global
          inet6 addr: fe80::211:95ff:feff:2bbd/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:987231 errors:0 dropped:0 overruns:0 frame:0
          TX packets:800360 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:830102720 (791.6 MiB)  TX bytes:395871735 (377.5 MiB)
          Interrupt:17 

  Stephen> What is the output of /proc/interrupts, perhaps the devices
  Stephen> don't like sharing IRQ?

d@d > cat /proc/interrupts 
           CPU0       CPU1       
  0:   22132560        948    IO-APIC-edge  timer
  1:     119890          8    IO-APIC-edge  i8042
  2:          0          0          XT-PIC  cascade
  3:       3010          0    IO-APIC-edge  serial
  8:          4          0    IO-APIC-edge  rtc
 12:    1360875        104    IO-APIC-edge  i8042
 14:     165181          4    IO-APIC-edge  ide0
 15:    1582736          8    IO-APIC-edge  ide1
 17:    1436277          0   IO-APIC-level  skge
 18:          0          0   IO-APIC-level  Ensoniq AudioPCI
 19:   17673555         44   IO-APIC-level  ohci_hcd:usb1
NMI:          0          0 
LOC:   22132173   22132577 
ERR:          0
MIS:          0




d
