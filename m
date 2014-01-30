From: renevant@internode.on.net
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 23:46:41 +1100
Message-ID: <32352923.yjoGibof8o@athas>
References: <22081260.RNay0J72dY@athas> <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com> <1703720.2GNpoTUMCv@athas>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Laight <David.Laight@aculab.com>,
	'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Mark Lord <mlord@pobox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: renevant@internode.on.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:56016 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780AbaA3Mqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 07:46:53 -0500
In-Reply-To: <1703720.2GNpoTUMCv@athas>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

via vl800 pcie card 
kernel parameter iommu=pt
ethtool -K xxx sg off
ifconfig xxx mtu 4060 up

stable so far, it's way past the point that it usually crashes.

i'll do proper testing tomorrow


iommu=pt   bah !

Regards,

Will Trives

On Thursday 30 January 2014 21:46:27 renevant@internode.on.net wrote:
> When using the ax88179 connected via the via based card the whole system
> gets brought down after a while i got this my system log.
> 
> I'm going to take a break and see if I can narrow anything more down
> tomorrow. This log is in reverse because of the wonderful way journalctl
> works.
> 
> I suppose I could try using iommu=pt as a kernel boot parameter but that
> doesn't sound like a safe thing to do.
> 
> 
>  Jan 30 21:04:38 athas kernel: [<ffffffffc11281a0>] xhci_msi_irq [xhci_hcd]
> Jan 30 21:04:38 athas kernel: handlers:
> Jan 30 21:04:38 athas kernel:  [<ffffffffa74f9ee6>]
> system_call_fastpath+0x1a/0x1f
> Jan 30 21:04:38 athas kernel:  [<ffffffffa715ef6a>] ?
> SyS_epoll_ctl+0x4fa/0xb00
> Jan 30 21:04:38 athas kernel:  <EOI>  [<ffffffffa715f181>] ?
> SyS_epoll_ctl+0x711/0xb00
> Jan 30 21:04:38 athas kernel:  [<ffffffffa74f982a>]
> common_interrupt+0x6a/0x6a Jan 30 21:04:38 athas kernel: 
> [<ffffffffa700445a>] do_IRQ+0x4a/0xf0 Jan 30 21:04:38 athas kernel: 
> [<ffffffffa7004679>] handle_irq+0x19/0x30 Jan 30 21:04:38 athas kernel: 
> [<ffffffffa708200f>] handle_edge_irq+0x6f/0x120 Jan 30 21:04:38 athas
> kernel:  [<ffffffffa707f8b1>] handle_irq_event+0x31/0x50 Jan 30 21:04:38
> athas kernel:  [<ffffffffa707f802>]
> handle_irq_event_percpu+0xc2/0x140
> Jan 30 21:04:38 athas kernel:  [<ffffffffa7081b00>]
> note_interrupt+0xe0/0x1e0 Jan 30 21:04:38 athas kernel: 
> [<ffffffffa708176d>] __report_bad_irq+0x2d/0xc0 Jan 30 21:04:38 athas
> kernel:  <IRQ>  [<ffffffffa74efd3f>]
> dump_stack+0x45/0x56
> Jan 30 21:04:38 athas kernel: Call Trace:
> Jan 30 21:04:38 athas kernel:  0000000000000000 ffff88043edc3ed8
> ffffffffa7081b00 0000000000000000
> Jan 30 21:04:38 athas kernel:  ffff88043edc3e98 ffffffffa708176d
> ffff880425031b00 000000000000004d
> Jan 30 21:04:38 athas kernel:  ffff880425031b84 ffff88043edc3e70
> ffffffffa74efd3f ffff880425031b00
> Jan 30 21:04:38 athas kernel: Hardware name: To be filled by O.E.M. To be
> filled by O.E.M./M5A99FX PRO R2.0, BIOS 2201 11/22/2013
> Jan 30 21:04:38 athas kernel: CPU: 7 PID: 1160 Comm: Chrome_IOThread Not
> tainted 3.13.0+ #13
> Jan 30 21:04:38 athas kernel: irq event 77: bogus return value ffffff94
> Jan 30 21:04:38 athas kernel: xhci_hcd 0000:02:00.0: Host not halted after
> 16000 microseconds.
> Jan 30 21:04:38 athas kernel: AMD-Vi: Event logged [IO_PAGE_FAULT
> device=02:00.0 domain=0x0019 address=0x00000000002b2000 flags=0x0000]
> Jan 30 21:04:38 athas kernel: xhci_hcd 0000:02:00.0: WARNING: Host System
> Error
> 
> 
> Regards,
> 
> Will Trives
