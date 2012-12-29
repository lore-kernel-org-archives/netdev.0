From: Martin Nybo Andersen <tweek@tweek.dk>
Subject: Re: Panic: dma_map_area overflow 66 bytes on 3.7+
Date: Sat, 29 Dec 2012 11:29:32 +0100
Message-ID: <201212291129.33076.tweek@tweek.dk>
References: <201212282005.10812.tweek@tweek.dk> <1356724390.21409.641.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Schmidt <mschmidt@redhat.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356724390.21409.641.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 28 December 2012 20:53:10 Eric Dumazet wrote:
> On Fri, 2012-12-28 at 20:05 +0100, Martin Nybo Andersen wrote:
> > Hi list,
> > 
> > Since the release of 3.7 my main computer has been panicking a couple of
> > times on both 3.7.0 and 3.7.1 because of a 'dma_map_area overflow xx bytes'.
> > 
> > Example screen shot:
> > http://www.tweek.dk/panic.jpg
> > 
> > I can reproduce it somewhat easily by visiting http://www.openstreetmap.org/
> > and zoom erratically with the scroll-button on the mouse.
> > 
> > The panic seems to occur on line 229 of arch/x86/kernel/amd_gart_64.c, and
> > reverting commit aee77e4accbeb2c86b1d294cd84fec4a12dde3bd (r8169: use
> > unlimited DMA burst for TX) seems to fix the problem for me (at least I've
> > not been able to make it panic as before (yet)).
> > 
> > 
> > lspci -v:
> > 00:00.0 Host bridge: Advanced Micro Devices [AMD] nee ATI RS480 Host Bridge (rev 01)
> > 00:02.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RS480 PCI-X Root Port
> > 00:05.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RS480 PCI Bridge
> > 00:12.0 SATA controller: Advanced Micro Devices [AMD] nee ATI SB600 Non-Raid-5 SATA
> > 00:13.0 USB controller: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI0)
> > 00:13.1 USB controller: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI1)
> > 00:13.2 USB controller: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI2)
> > 00:13.3 USB controller: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI3)
> > 00:13.4 USB controller: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI4)
> > 00:13.5 USB controller: Advanced Micro Devices [AMD] nee ATI SB600 USB Controller (EHCI)
> > 00:14.0 SMBus: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus Controller (rev 13)
> > 00:14.1 IDE interface: Advanced Micro Devices [AMD] nee ATI SB600 IDE
> > 00:14.2 Audio device: Advanced Micro Devices [AMD] nee ATI SBx00 Azalia (Intel HDA)
> > 00:14.3 ISA bridge: Advanced Micro Devices [AMD] nee ATI SB600 PCI to LPC Bridge
> > 00:14.4 PCI bridge: Advanced Micro Devices [AMD] nee ATI SBx00 PCI to PCI Bridge
> > 00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
> > 00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
> > 00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
> > 00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
> > 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)
> > 02:00.0 VGA compatible controller: NVIDIA Corporation G84 [GeForce 8600 GT] (rev a1)
> > 03:07.0 Multimedia controller: Twinhan Technology Co. Ltd Mantis DTV PCI Bridge Controller [Ver 1.0] (rev 01)
> > 
> > 
> > Please tell, if more info is needed.
> 
> Seems you have CONFIG_IOMMU_DEBUG, is it really what you want ?
That is true, I've enabled CONFIG_IOMMU_DEBUG.
If I want it? It seems like I don't... :-)

> It seems a bit strange we panic in this case
> ( panic_on_overflow = 1;)
I don't know much about IOMMUs, but if the alternative is trashed memory then
I'm in for it.

panic_on_overflow is set on lines 26--27 of arch/x86/kernel/pci-dma.c along
with force_iommu if CONFIG_IOMMU_DEBUG is enabled.

> You could try to add iommu=nopanic to your boot command : packet should
> be dropped, instead of panic.
I opt for disabling CONFIG_IOMMU_DEBUG, as it sets force_iommu as well.

If the only consequence of this is stats.tx_dropped being bumped not too
often, that's ok for me.


Thanks for the quick help! :-)


Regards,
Martin Nybo Andersen
