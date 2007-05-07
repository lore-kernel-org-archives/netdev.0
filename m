From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Mon, 7 May 2007 14:45:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705071310210.20970@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
 <4630D069.30605@redhat.com> <Pine.LNX.4.64.0704262219200.18515@kivilampi-30.cs.helsinki.fi>
 <20070427031757.513f6ad7.billfink@mindspring.com>
 <Pine.LNX.4.64.0704271122230.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-2012744157-1178533161=:20970"
Cc: Bill Fink <billfink@mindspring.com>,
	Chuck Ebbert <cebbert@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39224 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933286AbXEGLpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 07:45:55 -0400
In-Reply-To: <Pine.LNX.4.64.0704271122230.28337@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0705071434251.20970@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2012744157-1178533161=:20970
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0705071319371.20970@kivilampi-30.cs.helsinki.fi>

On Fri, 27 Apr 2007, Ilpo Järvinen wrote:
> > On Thu, 26 Apr 2007, Ilpo Järvinen wrote:
> > > On Thu, 26 Apr 2007, Chuck Ebbert wrote:
> > > > 
> > > > Try a different network adapter.
> > > 
> > > Hmm, I thought I had already done this but I just noticed that it is so 
> > > that the adapter was still the same as the other host has two adapter (now 
> > > that I look again). I'll give it a try tomorrow to see if using the 
> > > another adapter makes any difference.
> 
> ...Much more promising result this time. I noticed that there was another 
> eth hw on mainboard, thus my previous test with different hw was not 
> valid as I assumed "wrong" (didn't even notice the other) one to be eth0:
> 
> 02:05.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74)
> 02:08.0 Ethernet controller: Intel Corporation 82801DB PRO/100 VE (LOM) Ethernet Controller (rev 82)
> 
> With 3c905 I have the problem, with Intel one it does not show up 
> (tested today).

I found out this shows up when 900fd17dd01d2c99dfd1ec0b53a860894a2673ee is 
included, kernels before that seem to work fine. The problem description 
is in this same thread. I'm not going to repeat it here as it is valid 
except for the fact that my original claim that it happens with another 
hardware is false, please see it in here:

http://marc.info/?l=linux-netdev&m=117758295411277&w=2


Should these delays I see be considered as evindence of mmio not working 
with this card/model or could there be something else wrong somewhere? 
...I can just disable it using global_use_mmio parameter, which removes 
the problem in 2.6.20.7 (tested) but just in case somebody has more clue 
than I do about this, I'm willing to do more testing...


This output comes from 2.6.20.7:


[   15.553104] 3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
[   15.553214] 0000:02:05.0: 3Com PCI 3c905C Tornado at f8800c00.

02:05.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74)
        Subsystem: 3Com Corporation 3C905C-TX Fast Etherlink for PC Management NIC
        Flags: bus master, medium devsel, latency 32, IRQ 18
        I/O ports at dc00 [size=128]
        Memory at feaffc00 (32-bit, non-prefetchable) [size=128]
        Expansion ROM at f5700000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
00: b7 10 00 92 17 01 10 02 74 00 00 02 08 20 00 00
10: 01 dc 00 00 00 fc af fe 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 b7 10 00 10
30: 00 00 ac fe dc 00 00 00 00 00 00 00 09 01 0a 0a

# cat /proc/interrupts 
           CPU0       
  0:     126277   IO-APIC-edge      timer
  1:          8   IO-APIC-edge      i8042
  2:          0    XT-PIC-XT        cascade
  6:          5   IO-APIC-edge      floppy
 12:          4   IO-APIC-edge      i8042
 14:       3392   IO-APIC-edge      ide0
 15:          0   IO-APIC-edge      ide1
 18:       1269   IO-APIC-fasteoi   eth0
 20:          4   IO-APIC-fasteoi   eth1
NMI:          0 
LOC:     126238 
ERR:          0
MIS:          0

eth0 is the 3c59x, eth1 is the intel.

Network is 100/Full duplex, switched. No additional parameters are given 
to 3c59x.



-- 
 i.
---696243703-2012744157-1178533161=:20970--
