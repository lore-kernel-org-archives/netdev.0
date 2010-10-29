From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [RFC PATCH 0/2] SL351x (Gemini) ethernet driver
Date: Fri, 29 Oct 2010 14:14:12 +0300
Message-ID: <AANLkTinTDZSC93fUsVzx2pbhZE9_39t-m=XNh3h3tkqs@mail.gmail.com>
References: <cover.1288321597.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Janos Laube <janos.dev@gmail.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40488 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757334Ab0J2LOO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 07:14:14 -0400
In-Reply-To: <cover.1288321597.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/10/29 Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>:
> This is a driver for SL351x (Gemini) SoC ethernet peripheral.
> Based on work by Paulius Zaleckas and GPLd code from Raidsonic
> and other NAS vendors.
>
> This is work in progress. Please comment and test if you can.
> Patches are against 2.6.37-rc (current Linus' tree) but should
> apply to 2.6.36. You probably also need patches for PATA from
> =A0 =A0 =A0 =A0git://git.berlios.de/gemini-board ib4220

Nice to hear!

> Known bugs:
> =A0- repeatable bad HW calculated TCP csum
> =A0 =A0happens for only some packets in a TCP stream
> =A0 =A0looks like it doesn't like some data pattern or timing
> =A0 =A0(difference between correct and generated csum is the same
> =A0 =A0when the packet is retransmitted with changed header/TCP tstam=
p)
> =A0- TX DMA hangs sometimes (needs module reload when that happens)
> =A0 =A0with debugging printks disabled and HW TX csum enabled

AFAIK DMA hangs are associated with HW checksum errors. So generally
disabling HW csum is the best solution so far. If I am not wrong, OpenW=
RT
does just this in their patches.

DMA hangs happen for other reasons as well and main cause seems to be M=
II
interface. If timing is wrong or some noise gets onto PCB tracks it is
very likely
that DMA will hang. Also using both ports at one time increases posibil=
ity of
hang.

> =A0- unsynced counters
>
> I started to work on Paulius' code to find out why the TX DMA hangs
> happen, but then I realized that complete rewrite was a better way
> to understand how the hardware works and why it doesn't. As a "bonus"
> this got some additional features:
> =A0- ethtool support
> =A0- 64-bit counters
> =A0- proper cleanup on ifdown/module unload
> =A0- better DMA API usage
> =A0- cleaned up code
> =A0- a lot of tx/rx debugging printks
> =A0- based on 2.6.36 DMA and netdev interfaces
>
> TODO:
> =A0- NAPI
> =A0- MTU changing

Super cool! NAPI shouldn't be very hard...

> For normal use tx-csum and tso have to be disabled:
> =A0 ethtool -K eth0 tso off tx off
>
> Tested on Raidsonic IcyBox 4220-B (dual SATA NAS).
>
> I'm also interested in getting copies of various GPL packages for
> StorLink SL3516. I already have following packages (md5sum):
>
> 89991e543eb2e473e3d380ac9a4cd8b4 =A0GPL_source_code(Raidsonic).zip
> 6ba8b833c429794315f0a73ce2961bd8 =A0Gemini_v2_6_0-n.tgz
> fe87e97a33554bcab8284d25ff86e383 =A0n299_n199_1.00.24_GPL.tar.bz2
> eca8994354368304ca3b5bd1429c20bb =A0sl-boot_1.0.9.tgz
> eafd6497074fe0651459bf38c39d66bd =A0vt4kern-1.5.tar.bz2.tar

I will see what I can provide you when I get home.

>
> Best Regards,
> Micha=B3 Miros=B3aw
>
> ---
>
> Micha=B3 Miros=B3aw (2):
> =A0Gemini: create platform device for ethernet in Raidsonic IB-4220B
> =A0Gemini: SL351x Ethernet driver
>
> =A0arch/arm/mach-gemini/board-nas4220b.c =A0 =A0| =A0 53 +
> =A0arch/arm/mach-gemini/common.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
> =A0arch/arm/mach-gemini/devices.c =A0 =A0 =A0 =A0 =A0 | =A0 52 +
> =A0arch/arm/mach-gemini/include/mach/gmac.h | =A0 21 +
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A07 +
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/net/sl351x.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 170=
6 ++++++++++++++++++++++++++++++
> =A0drivers/net/sl351x_hw.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| 1423 =
+++++++++++++++++++++++++
> =A08 files changed, 3265 insertions(+), 0 deletions(-)
> =A0create mode 100644 arch/arm/mach-gemini/include/mach/gmac.h
> =A0create mode 100644 drivers/net/sl351x.c
> =A0create mode 100644 drivers/net/sl351x_hw.h
>
>
