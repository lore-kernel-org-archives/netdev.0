From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 11:05:33 +0200
Message-ID: <20070807090533.GC2120@ff.dom.local>
References: <JME9DM$ADEFA900BA9A4E6A40FE3AEF8CADB888@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert <cebbert@redhat.com>, mingo <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <JME9DM$ADEFA900BA9A4E6A40FE3AEF8CADB888@xandmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 10:10:34AM +0200, Jean-Baptiste Vignaud wrote:
> 
> > BTW: Jean-Babtiste, could you send or point to you current configs?

Oops! I'm very sorry for misspelling!

> > I mean at least proc/interrupts, but with dmesg and .config it would
> > be even better. (I assume this last report was about the revert patch
> > mentioned by Chuck, not the one below your message?)
> 
> Sure.
> 
> Last reports are with the 2.6.22.1-41.fc7 kernel, which has in changelog :
> 
> * Sat Jul 28 2007 Chuck Ebbert <cebbert@redhat.com>
> - revert upstream "genirq: do not mask interrupts by default"
> 
> 
> * interrupts (i use irqbalance, but problem was the same without)

I wonder if you tried without SMP too?

> 
> [root@loki ~]# cat /proc/interrupts
>            CPU0       CPU1
...
>  16:      72625         96   IO-APIC-fasteoi   eth1
>  17:       4667        128   IO-APIC-fasteoi   eth2
>  20:       4156      39870   IO-APIC-fasteoi   sata_nv
>  21:      34794       9177   IO-APIC-fasteoi   sata_nv
>  22:          0          0   IO-APIC-fasteoi   ehci_hcd:usb2
>  23:       6005       1565   IO-APIC-fasteoi   ohci_hcd:usb1, sata_nv
> 2297:          3     492180   PCI-MSI-edge      eth0
> NMI:          0          0
> LOC:    4915345    4915282
> ERR:          0

So, here it's not about irq sharing...

> 
> problems are with eth1 and eth2 here. never had any problems with the onboard (eth0).
...
> 
> * .config
> 
> i dont have it, it was the standard fedora one.
> 
> i'm not sure that the problem is related to 3com, because i replaced those cards by old card i had in spare :
> 
> 01:06.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 42)
> 01:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
> 
> and i had the exact same problem.
> 
> Those 3com cards were working 24/24 before i went to fedora 7 (and kernel 2.6.21 then).

It seems from 2.6.21 the problems are mainly about 'older' network
chips on x86_64. This reverted patch should mean only for those
using disable_irq, but I see forcedeth could use this too so it's
not clear yet, and btw. there where other changes around irqs and
pci, so everybody could have something a bit different with similar
time outs logs...

BTW, Jean-Baptiste and Chuck - it seems, unless you have too much
time, there is no use for testing my "genirq: fix simple and fasteoi
irq handlers" patch.

Thanks,
Jarek P.
