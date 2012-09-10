From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: kernel 3.5.2/amd64: iwlwifi 0000:03:00.0: failed to allocate
 pci memory
Date: Mon, 10 Sep 2012 12:24:01 +0200
Message-ID: <1347272641.4272.1.camel@jlt4.sipsolutions.net>
References: <20120908161038.GF3347@merlins.org>
	 <1347122927.1234.849.camel@edumazet-glaptop>
	 <20120904003014.GB6287@merlins.org> <20120908170128.GK3347@merlins.org>
	 (sfid-20120908_190214_109241_625AC686) <1347130641.11167.0.camel@jlt4.sipsolutions.net>
	 (sfid-20120908_205654_374994_2998A2BE)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-q7rQbLoQdy39qxiX1TGQuw@public.gmane.org
To: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347130641.11167.0.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org> (sfid-20120908_205654_374994_2998A2BE)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-09-08 at 20:57 +0200, Johannes Berg wrote:

> > [856806.497959]  [<ffffffff810cf54c>] warn_alloc_failed+0x117/0x12c
> > [856806.497963]  [<ffffffff810d23af>] __alloc_pages_nodemask+0x6e3/0x792
> > [856806.497969]  [<ffffffff812b7f41>] ? pfn_to_dma_pte+0x116/0x15e
> > [856806.497976]  [<ffffffff810ff58b>] alloc_pages_current+0xcd/0xee
> > [856806.497979]  [<ffffffff810cecca>] __get_free_pages+0x9/0x45
> > [856806.497982]  [<ffffffff812ba67d>] intel_alloc_coherent+0x84/0xe7
> > [856806.497986]  [<ffffffff81085cf8>] ? arch_local_irq_save+0x15/0x1b
> > [856806.497999]  [<ffffffffa0b84afc>] iwl_ucode_callback+0xa49/0xc0d [iwlwifi]
> 
> Yes, unfortunately we need a whole bunch of contiguous memory to load
> the firmware.
> 
> > Any ideas?
> 
> Nothing we can do from the driver side, I'm afraid.

Turns out I was wrong. Here's a patch you can test. Note that we still
need a lot of DMA-coherent memory for other things, but at least for the
firmware image we don't.

http://p.sipsolutions.net/11ea33b376a5bac5.txt

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
