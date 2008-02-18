From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.25-rc2, 2.6.24-rc8] page allocation failure...
Date: Mon, 18 Feb 2008 04:58:49 -0800
Message-ID: <20080218045849.59311851.akpm@linux-foundation.org>
References: <6278d2220802141240g6ee2421ew94e57669ef930be6@mail.gmail.com>
	<6278d2220802170520k2ddf9072x386e4a9e3062f4da@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39380 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699AbYBRM7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 07:59:52 -0500
In-Reply-To: <6278d2220802170520k2ddf9072x386e4a9e3062f4da@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Feb 2008 13:20:59 +0000 "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:

> I'm still hitting this with e1000e on 2.6.25-rc2, 10 times again.
> 
> It's clearly non-fatal, but then do we expect it to occur?
> 
> Daniel
> 
> --- [dmesg]
> 
> [ 1250.822786] swapper: page allocation failure. order:3, mode:0x4020
> [ 1250.822786] Pid: 0, comm: swapper Not tainted 2.6.25-rc2-119 #2
> [ 1250.822786]
> [ 1250.822786] Call Trace:
> [ 1250.822786]  <IRQ>  [<ffffffff8025fe9e>] __alloc_pages+0x34e/0x3a0
> [ 1250.822786]  [<ffffffff8048c6df>] ? __netdev_alloc_skb+0x1f/0x40
> [ 1250.822786]  [<ffffffff8027acc2>] __slab_alloc+0x102/0x3d0
> [ 1250.822786]  [<ffffffff8048c6df>] ? __netdev_alloc_skb+0x1f/0x40
> [ 1250.822786]  [<ffffffff8027b8cb>] __kmalloc_track_caller+0x7b/0xc0
> [ 1250.822786]  [<ffffffff8048b74f>] __alloc_skb+0x6f/0x160
> [ 1250.822786]  [<ffffffff8048c6df>] __netdev_alloc_skb+0x1f/0x40
> [ 1250.822786]  [<ffffffff8042652d>] e1000_alloc_rx_buffers+0x1ed/0x260
> [ 1250.822786]  [<ffffffff80426b5a>] e1000_clean_rx_irq+0x22a/0x330
> [ 1250.822786]  [<ffffffff80422981>] e1000_clean+0x1e1/0x540
> [ 1250.822786]  [<ffffffff8024b7a5>] ? tick_program_event+0x45/0x70
> [ 1250.822786]  [<ffffffff804930ba>] net_rx_action+0x9a/0x150
> [ 1250.822786]  [<ffffffff802336b4>] __do_softirq+0x74/0xf0
> [ 1250.822786]  [<ffffffff8020c5fc>] call_softirq+0x1c/0x30
> [ 1250.822786]  [<ffffffff8020eaad>] do_softirq+0x3d/0x80
> [ 1250.822786]  [<ffffffff80233635>] irq_exit+0x85/0x90
> [ 1250.822786]  [<ffffffff8020eba5>] do_IRQ+0x85/0x100
> [ 1250.822786]  [<ffffffff8020a5b0>] ? mwait_idle+0x0/0x50
> [ 1250.822786]  [<ffffffff8020b981>] ret_from_intr+0x0/0xa
> [ 1250.822786]  <EOI>  [<ffffffff8020a5f5>] ? mwait_idle+0x45/0x50
> [ 1250.822786]  [<ffffffff80209a92>] ? enter_idle+0x22/0x30
> [ 1250.822786]  [<ffffffff8020a534>] ? cpu_idle+0x74/0xa0
> [ 1250.822786]  [<ffffffff80527825>] ? rest_init+0x55/0x60

They're regularly reported with e1000 too - I don't think aything really
changed.

e1000 has this crazy problem where because of a cascade of follies (mainly
borked hardware) it has to do a 32kb allocation for a 9kb(?) packet.  It
would be sad if that was carried over into e1000e?

