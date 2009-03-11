From: Christian <cjs@dhp.com>
Subject: Re: skb_over_panic kernel panic
Date: Tue, 10 Mar 2009 23:07:29 -0400
Message-ID: <20090311030729.GB7041@dhp.com>
References: <20090311011013.GC7022@dhp.com>
Reply-To: Christian <cjs@dhp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao103.cox.net ([68.230.240.9]:60172 "EHLO
	eastrmmtao103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbZCKDHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 23:07:32 -0400
Received: from eastrmimpo03.cox.net ([68.1.16.126])
          by eastrmmtao103.cox.net
          (InterMail vM.7.08.02.01 201-2186-121-102-20070209) with ESMTP
          id <20090311030730.CKSQ11476.eastrmmtao103.cox.net@eastrmimpo03.cox.net>
          for <netdev@vger.kernel.org>; Tue, 10 Mar 2009 23:07:30 -0400
Content-Disposition: inline
In-Reply-To: <20090311011013.GC7022@dhp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've traced down this problem some more.  It only happens when I send
more than a small amount of data from my OSX86 system to my linux
server.  I can download files from the linux server without any
problems, but if I begin to upload anything it will kernel panic the
system in 2 seconds or less.  I haven't had any problem with regular SSH
sessions, but if I send files using scp or SMB the linux kernel panics
almost immediately.

My OSX86 system is using an Asus Striker Extreme with onboard Marvell
88E1116 Gigabit Ethernet 10/100/1000Mbps and the driver is
nForcEthernetDriver.kext which uses forcedeth. 

-rwxr-xr-x  1 root  wheel  131148 Feb 22  2008
nForcEthernetDriver.kext/Contents/MacOS/forcedeth

On Tue, Mar 10, 2009 at 09:10:13PM -0400, Christian wrote:
> Hello,
> 
> I keep getting kernel panics on my system with output similar to this:
> 
> skb_over_panic: text:fffffffff80456cc4 len:2580 put:2580
> head:ffff9900bf18a000 data:ffff8800bf18a010 tail:0xa end:0x640 dev:eth0
> --------[ cut here ] ----------
> kernel BUG at net/core/skbuff.c:124!xt:ffffffff80456cc4 len:2580
> put:2580 head:ffff8800bf18a000 data:ffff8800bf18a010 tail:0xa 
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/pci0000:00/0000:00:1f.0/resource
> CPU 5
> Modules linked in nvidia(P)
> Pid: 0, comm: swapper Tainted: P        2.6.28.7 #3
> RIP: 0010:[<ffffffff80531630>] [<ffffffff80531630>] skb_put+0x7a/0x89
> RSP: 0018:ffff8801bf9b3dd0 EFLAGS: 00010282
> 
> (I copied this output by hand so there may be a typo or two) 
> 
> Linux server1 2.6.28.7 #3 SMP Mon Mar 9 20:04:12 EDT 2009 x86_64
> Intel(R) Core(TM) i7 CPU 920 @ 2.67GHz GenuineIntel GNU/Linux
> 
> Before this my kernel was 2.6.27.5 and I was still getting the same
> panics.
> 
> eth0: RTL8168c/8111c at 0xffffc20000042000, 00:23:54:ed:7f:a6, XID
> 3c4000c0 IRQ 18
> r8169: eth0: link up
> 
> 00:00.0 Host bridge: Intel Corporation QuickPath Architecture I/O Hub to
> ESI Port (rev 12)
> 00:01.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub PCI
> Express Root Port 1 (rev 12)
> 00:03.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub PCI
> Express Root Port 3 (rev 12)
> 00:07.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub PCI
> Express Root Port 7 (rev 12)
> 00:10.0 PIC: Intel Corporation QuickPath Interconnect Physical and Link
> Layer Registers Port 0 (rev 12)
> 00:10.1 PIC: Intel Corporation QuickPath Interconnect Routing and
> Protocol Layer Registers Port 0 (rev 12)
> 00:13.0 PIC: Intel Corporation QuickPath Architecture I/O Hub I/OxAPIC
> Interrupt Controller (rev 12)
> 00:14.0 PIC: Intel Corporation QuickPath Architecture I/O Hub System
> Management Registers (rev 12)
> 00:14.1 PIC: Intel Corporation QuickPath Architecture I/O Hub GPIO and
> Scratch Pad Registers (rev 12)
> 00:14.2 PIC: Intel Corporation QuickPath Architecture I/O Hub Control
> Status and RAS Registers (rev 12)
> 00:14.3 PIC: Intel Corporation QuickPath Architecture I/O Hub Throttle
> Registers (rev 12)
> 00:1a.0 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB
> UHCI Controller #4
> 00:1a.1 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB
> UHCI Controller #5
> 00:1a.2 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB
> UHCI Controller #6
> 00:1a.7 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB2
> EHCI Controller #2
> 00:1b.0 Audio device: Intel Corporation 82801JI (ICH10 Family) HD Audio
> Controller
> 00:1c.0 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express
> Port 1
> 00:1c.2 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express
> Port 3
> 00:1c.3 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express
> Port 4
> 00:1c.4 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express
> Port 5
> 00:1d.0 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB
> UHCI Controller #1
> 00:1d.1 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB
> UHCI Controller #2
> 00:1d.2 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB
> UHCI Controller #3
> 00:1d.7 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB2
> EHCI Controller #1
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90)
> 00:1f.0 ISA bridge: Intel Corporation 82801JIR (ICH10R) LPC Interface
> Controller
> 00:1f.2 IDE interface: Intel Corporation 82801JI (ICH10 Family) 4 port
> SATA IDE Controller
> 00:1f.3 SMBus: Intel Corporation 82801JI (ICH10 Family) SMBus Controller
> 00:1f.5 IDE interface: Intel Corporation 82801JI (ICH10 Family) 2 port
> SATA IDE Controller
> 02:00.0 VGA compatible controller: nVidia Corporation G72 [GeForce 7300
> LE] (rev a1)
> 04:00.0 SATA controller: JMicron Technologies, Inc. JMicron 20360/20363
> AHCI Controller (rev 03)
> 04:00.1 IDE interface: JMicron Technologies, Inc. JMicron 20360/20363
> AHCI Controller (rev 03)
> 05:00.0 FireWire (IEEE 1394): VIA Technologies, Inc. Device 3403
> 06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
> 08:00.0 SCSI storage controller: Marvell Technology Group Ltd.
> MV88SX6081 8-port SATA II PCI-X Controller (rev 09)
> 08:01.0 Mass storage controller: Promise Technology, Inc. PDC40718 (SATA
> 300 TX4) (rev 02)
> 
> # lsmod
> Module                  Size  Used by
> nvidia               7797560  0 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
