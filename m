From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: kernel 3.5.2/amd64: iwlwifi 0000:03:00.0: failed to allocate
 pci memory
Date: Sat, 08 Sep 2012 20:57:21 +0200
Message-ID: <1347130641.11167.0.camel@jlt4.sipsolutions.net>
References: <20120908161038.GF3347@merlins.org>
	 <1347122927.1234.849.camel@edumazet-glaptop>
	 <20120904003014.GB6287@merlins.org> <20120908170128.GK3347@merlins.org>
	 (sfid-20120908_190214_109241_625AC686)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-q7rQbLoQdy39qxiX1TGQuw@public.gmane.org
To: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120908170128.GK3347-xnduUnryOU1AfugRpC6u6w@public.gmane.org> (sfid-20120908_190214_109241_625AC686)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-09-08 at 10:01 -0700, Marc MERLIN wrote:

> I realize it's likely a memory fragmentation problem, but I have 8GB and
> plenty of 'free' space, so I'm hoping that somehow it can be defragmented
> enough for module loading ot work?

> [856806.443647] cfg80211: Calling CRDA to update world regulatory domain
> [856806.448428] iwlwifi: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
> [856806.448431] iwlwifi: Copyright(c) 2003-2012 Intel Corporation
> [856806.448929] cfg80211: World regulatory domain updated:
> [856806.448931] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
> [856806.448933] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
> [856806.448941] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
> [856806.448942] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
> [856806.448943] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
> [856806.448945] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
> [856806.483929] iwlwifi 0000:03:00.0: pci_resource_len = 0x00002000
> [856806.483932] iwlwifi 0000:03:00.0: pci_resource_base = ffffc900057bc000
> [856806.483933] iwlwifi 0000:03:00.0: HW Revision ID = 0x3E
> [856806.484004] iwlwifi 0000:03:00.0: irq 46 for MSI/MSI-X
> [856806.497476] iwlwifi 0000:03:00.0: loaded firmware version 9.221.4.1 build 25532
> [856806.497944] kworker/3:0: page allocation failure: order:5, mode:0xd0
> [856806.497948] Pid: 17936, comm: kworker/3:0 Tainted: G        W  O 3.5.2-amd64-preempt-noide-20120731 #1
> [856806.497949] Call Trace:
> [856806.497959]  [<ffffffff810cf54c>] warn_alloc_failed+0x117/0x12c
> [856806.497963]  [<ffffffff810d23af>] __alloc_pages_nodemask+0x6e3/0x792
> [856806.497969]  [<ffffffff812b7f41>] ? pfn_to_dma_pte+0x116/0x15e
> [856806.497976]  [<ffffffff810ff58b>] alloc_pages_current+0xcd/0xee
> [856806.497979]  [<ffffffff810cecca>] __get_free_pages+0x9/0x45
> [856806.497982]  [<ffffffff812ba67d>] intel_alloc_coherent+0x84/0xe7
> [856806.497986]  [<ffffffff81085cf8>] ? arch_local_irq_save+0x15/0x1b
> [856806.497999]  [<ffffffffa0b84afc>] iwl_ucode_callback+0xa49/0xc0d [iwlwifi]

Yes, unfortunately we need a whole bunch of contiguous memory to load
the firmware.

> Any ideas?

Nothing we can do from the driver side, I'm afraid.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
