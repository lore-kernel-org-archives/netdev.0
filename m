From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 05 Nov 2008 10:30:27 +0100
Message-ID: <1225877427.29712.4.camel@localhost.localdomain>
References: <1225809909.10206.90.camel@localhost.localdomain>
	 <20081104.134236.115613394.davem@davemloft.net>
	 <1225868744.31605.12.camel@localhost.localdomain>
	 <20081104.233313.109709104.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:46590 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbYKEJa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:30:29 -0500
In-Reply-To: <20081104.233313.109709104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-11-04 at 23:33 -0800, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Wed, 05 Nov 2008 08:05:44 +0100
> 
> > A strange observation is the IRQ allocations seen via /proc/interrupts:
> > (e.g. eth2 has assigned no less than 12 IRQs !?!)
> 
> One for each TX and RX queue and then one for "other events".
> 
> If you disable MSI on the system (I forget the kernel command
> line option offhand) 

pci=nomsi

> does that make the problem go away?

No :-(

I can trick the bug by simply doing a 'ping -A' from the host it self.

The /proc/interrupts output now only has one IRQ per interface.

dcu-router-ng:~# cat /proc/interrupts 
           CPU0       CPU1       CPU2       CPU3       
  0:        124          2          0          0   IO-APIC-edge      timer
  1:          1          0          0          1   IO-APIC-edge      i8042
  3:          2          2          1          2   IO-APIC-edge      serial
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          0          1          2          1   IO-APIC-edge      i8042
 14:         14         15         13         15   IO-APIC-edge      ata_piix
 15:          0          0          0          0   IO-APIC-edge      ata_piix
 16:        627        620        603        614   IO-APIC-fasteoi   uhci_hcd:usb1, ehci_hcd:usb6, eth0, eth2
 17:         60         64         60         59   IO-APIC-fasteoi   uhci_hcd:usb2, eth3
 18:       2623       2623       2629       2622   IO-APIC-fasteoi   cciss0, uhci_hcd:usb3
 19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 21:       1182       1179       1203       1196   IO-APIC-fasteoi   ipmi_si
 22:         24         26         23         24   IO-APIC-fasteoi   uhci_hcd:usb5
NMI:          0          0          0          0   Non-maskable interrupts
LOC:     104435     484481     543096     164600   Local timer interrupts
RES:        111        123        234        229   Rescheduling interrupts
CAL:         89        130        133         68   Function call interrupts
TLB:        266        263        363        449   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
SPU:          0          0          0          0   Spurious interrupts
ERR:          0
MIS:          0


niu: eth2: Link is up at 1Gb/sec, full duplex
niu: eth3: Link is up at 1Gb/sec, full duplex
bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x21e/0x230()
NETDEV WATCHDOG: eth3 (niu): transmit timed out
Modules linked in: ehci_hcd hpwdt ipmi_si ipmi_msghandler uhci_hcd bnx2 zlib_inflate rng_core serio_raw hpilo niu sr_mod cdrom
Pid: 0, comm: swapper Not tainted 2.6.28-rc2-davem #15
Call Trace:
 [<c01256a3>] warn_slowpath+0x63/0x80
 [<c0145154>] ? __lock_acquire+0x104/0x8e0
 [<c0145154>] ? __lock_acquire+0x104/0x8e0
 [<c0145154>] ? __lock_acquire+0x104/0x8e0
 [<c0144899>] ? lock_release_holdtime+0x79/0xc0
 [<c021fb4e>] ? strlcpy+0x1e/0x60
 [<c031f2ae>] dev_watchdog+0x21e/0x230
 [<c0144899>] ? lock_release_holdtime+0x79/0xc0
 [<c012e33d>] ? run_timer_softirq+0x10d/0x190
 [<c012e34f>] run_timer_softirq+0x11f/0x190
 [<c014333c>] ? tick_dev_program_event+0x3c/0xc0
 [<c031f090>] ? dev_watchdog+0x0/0x230
 [<c012a084>] __do_softirq+0x94/0x160
 [<c013c4c0>] ? hrtimer_interrupt+0x150/0x180
 [<c012a18b>] do_softirq+0x3b/0x50
 [<c012a395>] irq_exit+0x75/0x90
 [<c011365a>] smp_apic_timer_interrupt+0x5a/0x90
 [<c0103f0c>] apic_timer_interrupt+0x28/0x30
 [<c01090e5>] ? mwait_idle+0x35/0x40
 [<c0101c1e>] cpu_idle+0x4e/0xa0
---[ end trace aceba7adff184265 ]---
niu 0000:0b:00.1: niu: eth3: Transmit timed out, resetting




-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
