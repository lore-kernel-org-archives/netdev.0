From: Phillip Michael Jordan <phil@philjordan.eu>
Subject: Re: [PATCH] skge: Fix/workaround for DMA mask quirk on ASUS
	P5NSLI/Marvell Yukon-Lite
Date: Tue, 10 Feb 2009 23:15:43 +0100
Message-ID: <f1a0791a0902101415n47a825d9gf83d6908d6a8646a@mail.gmail.com>
References: <f1a0791a0902101056i6fd47886gc3cee4b5aff2a23e@mail.gmail.com>
	 <20090210111408.2225e90b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:49845 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755477AbZBJWPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 17:15:46 -0500
Received: by fg-out-1718.google.com with SMTP id 16so53425fgg.17
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 14:15:44 -0800 (PST)
In-Reply-To: <20090210111408.2225e90b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This looks like a good start to a workable workaround.

Thanks,

> I wonder if other PCI devices in same system have the same problem?
> If so, it should be move to PCI quirk.

This is the odd part: everything else works, and has done so with
rock-solid stability for months of fairly heavy use, during which time I
used a replacement PCI network card while the Marvell chip wasn't working.

The other devices include: 2 soundcards (onboard:
snd_hda_intel/snd_ac97_codec and PCI: snd_ca0106), graphics (PCIe:
nvidia or nv), PATA (pata_amd), SATA (sata_nv), USB and the
aforementioned network card (r8169).

However, looking deeper I've been grepping through the kernel source for
DMA_64BIT_MASK. The only drivers that can even handle 64-bit DMA and
also happen to be used in this system are r8169: only if the module
parameter use_dac is set. (described as "Unsafe on 32 bit PCI slot."
which doesn't sound good - my 8169 card has
a 32-bit PCI connector and is therefore probably unsuitable for
testing in this case) and hda_intel: if the capability bit is set by
the hardware, which it is on mine, I printk'd it.

The sound chip in question resides on a different bus though (00 vs
06) as it's integrated into the chipset, so that might it useless for
comparison?

So the skge module is the only one for devices on the external bus
that currently even attempts to use 64-bit DMA addresses, and
unfortunately, I don't happen to own any other
pluggable hardware on that 64-bit list.

> Also, since the problem is almost certainly in the PCI bridge to
> skge connection, the quirk should identify based on the upstream bridge,
> rather than the Marvell chip and DMI.

After all that, I now agree that it's probably purely a motherboard
issue, even if I can't verify it with another device.

Sorry to waste your (and the rest of linux-netdev's) time on this. I'll
try and cook up a patch against pci-dma.c and try my luck on linux-pci
instead.

phil
