From: Anton Blanchard <anton@samba.org>
Subject: Re: oops in ip_rcv
Date: Fri, 6 May 2005 11:02:46 +1000
Message-ID: <20050506010246.GA8255@krispykreme>
References: <20050505101542.GB7916@krispykreme> <E1DTeis-0005gu-00@gondolin.me.apana.org.au> <20050505130904.GA16593@krispykreme> <20050505112624.3ffd7f3d.davem@davemloft.net> <20050505213740.GB29526@gondor.apana.org.au> <20050505214453.GA29853@gondor.apana.org.au> <20050505150943.566280f0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050505150943.566280f0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Hi,

> Of course... But I don't want to apply this until Anton
> tells us how in the world he is receiving packets so
> early in the boot.
> 
> If I put this patch in now, he may get lazy just like me
> and never try and figure out where they are coming from :)

You know me too well :)

I start getting acenic irqs straight after the card is initialised:

acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk
                            http://home.cern.ch/~jes/gige/acenic.html
0001:40:0c.0: Alteon AceNIC Gigabit Ethernet at 0xd7fcc000, irq 45
  Tigon II (Rev. 6), Firmware: 12.4.11, MAC: 00:02:55:9a:0c:bd
  PCI bus width: 64 bits, speed: 66MHz, latency: 72 clks
0001:40:0c.0: Firmware up and running
drivers/net/ibmveth.c: ibmveth: IBM i/pSeries Virtual Ethernet Driver 1.03
eth1: Optical link UP (Full Duplex, Flow Control: )
netconsole: not configured, aborting
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
sym0: <875> rev 

cpu 0x0: Vector: 700 (Program Check) at
[c00000000fffxbb10]
    pc: c00000000043a6fc: .netif_rx+0x1c/0x4 00
    lr: c0000000002aae20: .ace_interrupt+0x1c0/t0xac0
    sp: c00000000fffbd90
   msr: a000000000029032
  current = 0xc0000000005ca500
  paca    = 0xc000000000585400
    pid   = 0, comm = swapper
kernel BUG in netif_rx at 0net/core/dev.c:1443!
0:mon> t
c0000000002aae20 .ace_interrupt+0x1c0/0xac0
c000000000084ca4 .handle_IRQ_event+0x84/0x100
c00000000001457c .call_handle_IRQ_event+0x14/0x24
c00000000000fa74 .ppc_irq_dispatch_handler+0x224/0x3f0
c00000000000fcb8 .do_IRQ+0x78/0xf0
c00000000000ae34 hardware_interrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c000000000010270 .default_idle+0xa0/0x130
c000000000010074 .cpu_idle+0x34/0x50
c00000000000c03c .rest_init+0x3c/0x60
c0000000004d3904 .start_kernel+0x2a4/0x320
c00000000000bfb4 .__setup_cpu_power3+0x0/0x4
