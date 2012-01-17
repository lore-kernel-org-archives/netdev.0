From: "Bishop, Mark" <Mark.Bishop@cooperindustries.com>
Subject: RE: Question with interfacing to a SMSC9215
Date: Mon, 16 Jan 2012 23:04:04 -0500
Message-ID: <5D308BD40154E4439D82454FE483A50205B39F28@EVS4.nam.ci.root>
References: <5D308BD40154E4439D82454FE483A50205AF1FBA@EVS4.nam.ci.root>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooperlighting-sw.cooperlighting.com ([216.130.131.68]:39687
	"EHLO cooperlighting-sw.cooperlighting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750758Ab2AQEO7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 23:14:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <5D308BD40154E4439D82454FE483A50205AF1FBA@EVS4.nam.ci.root>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replying to my own email.  Hopefully with enough data for some help.

> -----Original Message-----
...
> 
> smsc911x: Driver version 2008-10-21.
> setting trigger mode 8 for irq 211 failed
> (_bfin_gpio_irq_type+0x0/0x1e4)
> 
...
> 
> #include <linux/smsc911x.h>
> 
> static struct resource smsc911x_resources[] = {
>         {
>                 .name = "smsc911x-memory",
>                 .start = 0x24000000,
>                 .end = 0x24000000 + 0xFF,
>                 .flags = IORESOURCE_MEM,
>         },
>         {
>                 /* .start = IRQ_PE8, */
>                 /* .end = IRQ_PE8, */
>                 .start = IRQ_PG12,
>                 .end = IRQ_PG12,
>                 .flags = IORESOURCE_IRQ | IORESOURCE_IRQ_LOWLEVEL,
>         },
> };
> 
> static struct smsc911x_platform_config smsc911x_config = {
>         .flags = SMSC911X_USE_32BIT,
>         .irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
>         .irq_type = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
>         .phy_interface = PHY_INTERFACE_MODE_MII,
> };
> 
> static struct platform_device smsc911x_device = {
>         .name = "smsc911x",
>         .id = 0,
>         .num_resources = ARRAY_SIZE(smsc911x_resources),
>         .resource = smsc911x_resources,
>         .dev = {
>                 .platform_data = &smsc911x_config,
>         },
> };
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This was due to the mapping of the pin at the low level.  I have that
taken care of and now I am getting it to probe, but then the kernel
'oops'

I don't know if this line is correct or not. I am wondering about the
'-1':

smsc911x-mdio: probed
eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=0:01, irq=-1)

i2c /dev entries driver
TCP cubic registered
NET: Registered protocol family 17
dma_alloc_init: dma_page @ 0x02945000 - 512 pages at 0x03e00000
Freeing unused kernel memory: 6700k freed
Jan  1 00:00:01 dhcpcd[261]: [truncated] m

                           _____________________________________
|     8'    .88       \        |U|nd ef|in_ed| i ns|tr uc ti on

 \ <5 >  - .Ma'y 8be  u se\d  to  e mu_la te| i ns|tr uc/ti\on s  th|at
a red n ot  d8ef in ed  f or
em es so r .im pl8em en ta ti ono.r
  edKedrnrele OoOP S cind pgro gr
8:                               es s
esD ef er:rebd  Ex ce\pt iohn Acolnt exvt
   ES8S:iEN T  PR
__  C OM8M= kl og d _PI_D=_27_0  _CP_U=_0
:x 02Pa0 00 00 -0:x082a 4e89e c :     _  8 D AT A  =
o0xf02tbar09necr-0tx0n2bca4c29oc
 . /BSaS :=  0x 02Pba 42 9c -0 x0 2btc0/00l0 k UnSEcR-nST.ACgK
                                                               =  0x
02"bd fe|d0
  .
    r et-urtn :adddrsesls:k [n0xc02n01.c3g90
                                            ];  c on.te_nt|s  of':
    0 x0h20p1c/37w0:c i u00o00/  0`00.0 _ 0800P0 _ '00j00/ :f  00-00t
:00w00.  a00g00o  0l00k0 n

av0 x0l20 1c 38n0:.  0000  0000  0000  0000  0000  0000  0000  0000
0x0201c390: [ffff] ffff  ffff  ffff  feff  ffff  ffff  ffff
0x0201c3a0:  ffff  ffff  ffff  ffff  c5dc  001c  cb5c  001c

SEQUENCER STATUS:               Not tainted
 SEQSTAT: 00000021  IPEND: c008  IMASK: ffff  SYSCFG: 0006
  EXCAUSE   : 0x21
  physical IVG3 asserted : <0xffa007a0> { _trap + 0x0 }
  physical IVG14 asserted : <0xffa00ae8> { _evt_evt14 + 0x0 }
  physical IVG15 asserted : <0xffa00fe8> { _evt_system_call + 0x0 }
  logical irq   6 mapped  : <0xffa003dc> { _bfin_coretmr_interrupt + 0x0
}
  logical irq  48 mapped  : <0x000cf8e0> { _bfin_serial_dma_rx_int + 0x0
}
  logical irq  49 mapped  : <0x000cf664> { _bfin_serial_dma_tx_int + 0x0
}
  logical irq  52 mapped  : <0x000f12c4> { _bfin_twi_interrupt_entry +
0x0 }
  logical irq  53 mapped  : <0x000f12c4> { _bfin_twi_interrupt_entry +
0x0 }
 RETE: <0x00000000> /* Maybe null pointer? */
 RETN: <0x02947d30> /* kernel dynamic memory (maybe user-space) */
 RETX: <0x00000480> /* Maybe fixed code section */
 RETS: <0x00017e96> { _run_timer_softirq + 0xea }
 PC  : <0x0201c390> /* kernel dynamic memory (maybe user-space) */
DCPLB_FAULT_ADDR: <0x001bbffc> /* kernel dynamic memory (maybe
user-space) */
ICPLB_FAULT_ADDR: <0x0201c390> /* kernel dynamic memory (maybe
user-space) */
PROCESSOR STATE:
......
