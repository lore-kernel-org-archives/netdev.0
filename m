From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: e1000e 2.6.30.1 massive packet loss
Date: Thu, 16 Jul 2009 04:20:54 -0400
Message-ID: <81bfc67a0907160120i2528d9abq6c1bd6ffbae8a433@mail.gmail.com>
References: <81bfc67a0907160049q3d43093cy52276f0fe1157d89@mail.gmail.com>
	 <4A5EDEF7.7090303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:36911 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbZGPIUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 04:20:55 -0400
In-Reply-To: <4A5EDEF7.7090303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What do you call 20-50% packet loss ?

sorry that's just the approximate average loss mtr was reporting. I
realize it's not the most accurate test, but I have no problems before
changing to .1 or after downgrading from it.

> (Losses to icmp flood itself, or tcp losses ?
> Is the machine answering to icmp flood, or is it the origin ?

mtr uses all icmp, but considering web browsing and I'm sure even dns
was affected I'd say all of it. I haven't done further investigation.
it was the origin and the losses occured between my desktop
machine(2.6.31.x) and my linksys wrt54gl(on openwrt) router. Since I
know the cable is good, and the losses haven't happened before or
since, and I even tried rebooting the router, I'm fairly confident
that it's a result of changes between the 2 kernel versions.

> Are you saying packet loss was not occurring with 2.6.30 ?

yes.

> Could you describe your methodology ?
>
> You could give us results of "cat /proc/interrupts" from both
> versions, because it sounds as an interrupt affinity problem.

these are from 2.6.30 I'll send .1 in a bit.
> # cat /proc/interrupts


           CPU0       CPU1       CPU2       CPU3
  0:       1605          0          0          0    XT-PIC-XT        timer
  1:          2          0          0          0    XT-PIC-XT        i8042
  2:          0          0          0          0    XT-PIC-XT        cascade
  4:          3          0          0          0    XT-PIC-XT        ohci1394
  5:   40347741          0          0          0    XT-PIC-XT
uhci_hcd:usb3, EMU10K1
  6:          2          0          0          0    XT-PIC-XT        floppy
  8:       4738          0          0          0    XT-PIC-XT        rtc0
  9:          0          0          0          0    XT-PIC-XT
acpi, ehci_hcd:usb2, uhci_hcd:usb6
 10:          0          0          0          0    XT-PIC-XT
uhci_hcd:usb4
 11:     923781          0          0          0    XT-PIC-XT
ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb7, uhci_hcd:usb8
 12:          4          0          0          0    XT-PIC-XT        i8042
 25:     428267     425244     423627     427244   PCI-MSI-edge      i915
 26:    1194972    1211065    1191149    1200914   PCI-MSI-edge      ahci
 27:    7287597    7270695    7291505    7280533   PCI-MSI-edge      eth0
NMI:          0          0          0          0   Non-maskable interrupts
LOC:   66007880   72160316   45190647   33707930   Local timer interrupts
SPU:          0          0          0          0   Spurious interrupts
RES:      67599      68493      54742      53268   Rescheduling interrupts
CAL:        288        295        363        323   Function call interrupts
TLB:     133835      49505      43942      48309   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
THR:          0          0          0          0   Threshold APIC interrupts
ERR:          0
MIS:          0

> # tc -s -d qdisc

qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1
1 1 1 1 1 1
 Sent 33951429966 bytes 12436885 pkt (dropped 0, overlimits 0 requeues 1375)
 rate 0bit 0pps backlog 0b 0p requeues 1375

> # ifconfig -a

eth0      Link encap:Ethernet  HWaddr 00:21:9B:06:4C:C9
          inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::221:9bff:fe06:4cc9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:16135626 errors:0 dropped:0 overruns:0 frame:0
          TX packets:28308711 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:2181880167 (2080.8 Mb)  TX bytes:34811667228 (33198.9 Mb)
          Memory:fdfc0000-fdfe0000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:92471 errors:0 dropped:0 overruns:0 frame:0
          TX packets:92471 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:11927979 (11.3 Mb)  TX bytes:11927979 (11.3 Mb)




-- 
Caleb Cushing

http://xenoterracide.blogspot.com
