From: Kacper Bielecki <kazjote@stud.ics.p.lodz.pl>
Subject: Re: PROBLEM: network interface regularly stops working
Date: Thu, 7 Jun 2007 12:12:54 +0200
Message-ID: <200706071212.54780.kazjote@stud.ics.p.lodz.pl>
References: <200706051208.40929.kazjote@stud.ics.p.lodz.pl> <200706052147.02376.kazjote@stud.ics.p.lodz.pl> <20070605203709.GA26645@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_mo9ZGMIwojE1nKt"
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stud.ics.p.lodz.pl ([212.51.220.231]:19057 "EHLO
	stud.ics.p.lodz.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbXFGKM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 06:12:57 -0400
In-Reply-To: <20070605203709.GA26645@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

First of all I managed to reproduce this bug with Gentoo LiveCD 2007.0 amd64 
so now Im sure it is not Ubuntu specific. 2007.0 comes with kernel 
2.6.19-gentoo-...

On Tuesday 05 of June 2007 22:37:09 you wrote:
> Can you reproduce the problem if this module is not loaded at all ?
>
> Please understand "loaded" as "it's loaded but it is not used" as well
> as "it was loaded but I unloaded it before testing".

Fglrx was not loaded just because it fails to build with 2.6.22-r4 patched 
kernel. What I noticed is that when the interface fails during the system 
startup, xorg wont start complaining about fglrx. If networking is working 
xorg will simply load xorg (ati) module. 

>
> > Restarting interface doesn't solve the problem.
>
> Neither do an 'ifconfig down/rmmod/modprobe/ifconfig up' cycle ?
>
When I do this cycle before the network fail I get normally eth0 interface 
working with the dmesg output shown in dmesg_cycle_good attached file.

After the fail eth0 will not start anymore, instead eth1 will start with the 
huge number of dropped packets. Dmesg output from this operation is in 
attachmet named modprobe_dmesg. Ifconfig status after operation is in 
ifconfig_after_dmesg.

To generate this files I used dmesg | tail command so it is not full output.
>
> > I don't know what else can help so I attach some information about
> > system.
>
> A 'cat /proc/interrupts', a few seconds of 'vmstat 1' a
> 'for i in $(seq 1 5); do ethtool -S eth0; sleep 1; done' after the watchdog
> event and a good bunch of patience.

I attach interrupts and vmstat. ethtool -S eth0 won't generate any output 
after network fail. It freezes and can be exited with CTRL+C. I attach also 
normal output from your script  before the fail in ethtool_good file.

--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="dmesg_cycle_good"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="dmesg_cycle_good"

[  326.605896] ACPI: PCI interrupt for device 0000:01:00.0 disabled
[  334.383427] r8169 Gigabit Ethernet driver 2.2LK loaded
[  334.383549] ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 17 (level, low) -> IRQ 17
[  334.383646] PCI: Setting latency timer of device 0000:01:00.0 to 64
[  334.383889] PM: Adding info for No Bus:eth0
[  334.384761] eth0: RTL8168b/8111b at 0xffffc200001e0000, 00:19:66:02:75:9f, IRQ 17
[  334.400904] r8169: eth0: link down
[  334.400915] r8169: eth0: link down
[  334.402389] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  336.067849] r8169: eth0: link up
[  336.069313] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready 

--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="modprobe_dmesg"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="modprobe_dmesg"

[  254.015732] eth0: no IPv6 routers present
[ 1277.154147] PM: Removing info for No Bus:eth0
[ 1277.168553] ACPI: PCI interrupt for device 0000:01:00.0 disabled
[ 1345.343644] r8169 Gigabit Ethernet driver 2.2LK loaded
[ 1345.343751] PCI: Enabling device 0000:01:00.0 (0000 -> 0003)
[ 1345.343759] ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 17 (level, low) -> IRQ 17
[ 1345.343916] PCI: Setting latency timer of device 0000:01:00.0 to 64
[ 1346.141898] PM: Adding info for No Bus:eth0
[ 1346.141991] eth0: RTL8100e at 0xffffc200001e2000, ff:ff:ff:ff:ff:ff, IRQ 17
[ 1346.961209] r8169: eth1: link up

--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="ifconfig_after_dmesg"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ifconfig_after_dmesg"

eth1      Link encap:Ethernet  HWaddr FF:FF:FF:FF:FF:FF  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:60129542130 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:17 Base address:0x2000 

eth1:avah Link encap:Ethernet  HWaddr FF:FF:FF:FF:FF:FF  
          inet addr:169.254.14.242  Bcast:169.254.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:17 Base address:0x2000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:13 errors:0 dropped:0 overruns:0 frame:0
          TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1192 (1.1 KiB)  TX bytes:1192 (1.1 KiB)


--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="interrupts"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="interrupts"

           CPU0       CPU1       
  0:     139995          0   IO-APIC-edge      timer
  1:       1842          0   IO-APIC-edge      i8042
  7:          0          0   IO-APIC-edge      parport0
  8:          0          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:        113          0   IO-APIC-edge      i8042
 14:      70624          0   IO-APIC-edge      libata
 15:          0          0   IO-APIC-edge      libata
 16:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 17:         47          0   IO-APIC-fasteoi   eth0
 18:          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
 19:         72          0   IO-APIC-fasteoi   uhci_hcd:usb2, libata
 23:       1063          0   IO-APIC-fasteoi   uhci_hcd:usb1, ehci_hcd:usb5, snd_ca0106
NMI:          0          0 
LOC:     139966     139944 
ERR:          0

--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="vmstat"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="vmstat"

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  1      0 188188  15352 723600    0    0  1004    17  188  316  1  2 83 15
 0  0      0 188180  15356 723644    0    0     0     8  260   71  0  0 100  0
 0  0      0 188180  15356 723648    0    0     0     0  257   68  0  0 100  0
 0  0      0 188180  15356 723648    0    0     0     0  256   57  0  0 100  0
 0  0      0 188180  15356 723648    0    0     0     0  257   66  0  0 100  0
 0  0      0 188180  15356 723648    0    0     0     4  257   64  0  0 100  0
 0  0      0 188180  15380 723632    0    0     0    60  264   83  0  0 100  0
 0  0      0 188180  15380 723648    0    0     0     0  256   59  0  0 100  0
 0  0      0 188180  15380 723648    0    0     0     0  257   66  0  0 100  0
 1  0      0 188180  15380 723648    0    0     0     0  256   59  0  0 100  0
 0  0      0 188180  15380 723648    0    0     0     0  257   67  0  0 100  0
 0  0      0 188180  15392 723648    0    0     0    20  260   74  0  0 100  0
 0  0      0 188180  15392 723648    0    0     0     0  257   66  0  0 100  0
 0  0      0 188180  15392 723648    0    0     0     0  256   58  0  0 100  0
 0  0      0 188180  15392 723648    0    0     0     0  257   66  0  0 100  0
 0  0      0 188180  15392 723648    0    0     0     0  256   59  0  0 100  0
 0  0      0 188180  15400 723648    0    0     0    16  260   73  0  0 100  0

--Boundary-00=_mo9ZGMIwojE1nKt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="ethtool_good"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ethtool_good"

NIC statistics:
     tx_packets: 1440
     rx_packets: 2536
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1250
     broadcast: 133
     multicast: 1286
     tx_aborted: 0
     tx_underrun: 0
NIC statistics:
     tx_packets: 1440
     rx_packets: 2536
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1250
     broadcast: 133
     multicast: 1286
     tx_aborted: 0
     tx_underrun: 0
NIC statistics:
     tx_packets: 1440
     rx_packets: 2536
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1250
     broadcast: 133
     multicast: 1286
     tx_aborted: 0
     tx_underrun: 0
NIC statistics:
     tx_packets: 1440
     rx_packets: 2536
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1250
     broadcast: 133
     multicast: 1286
     tx_aborted: 0
     tx_underrun: 0
NIC statistics:
     tx_packets: 1440
     rx_packets: 2536
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1250
     broadcast: 133
     multicast: 1286
     tx_aborted: 0
     tx_underrun: 0

--Boundary-00=_mo9ZGMIwojE1nKt--
