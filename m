From: Baruch Siach <baruch@tkos.co.il>
Subject: usb/net/hso: WARNING: ungligned urb->setup_dma
Date: Tue, 28 Feb 2017 10:28:10 +0200
Message-ID: <20170228082810.syn656o2zzms7urf@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, John Youn <johnyoun@synopsys.com>,
        netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:59225 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751395AbdB1I2y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 03:28:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jan, linux-usb list,

I'm hitting this warning consistently on my Raspberry Pi 3 running kernel 
v4.10.1 with some unrelated device tree changes, and a debug print (below). 
The device identifies as "GlobeTrotter HSDPA Modem", VID: 0af0, PID: 6971.
The warning triggers consistently on first write access to /dev/ttyHS0 that 
ModemManager attempts. The first line in the log is my debug print.

[   65.004892] dwc2_map_urb_for_dma: setup_dma: f5635066
[   65.010718] ------------[ cut here ]------------
[   65.016079] WARNING: CPU: 1 PID: 794 at drivers/usb/dwc2/hcd.c:2631 dwc2_map_urb_for_dma+0x94/0x130
[   65.025930] 
[   65.028143] CPU: 1 PID: 794 Comm: ModemManager Not tainted 4.10.1-00008-g76809ec3947f-dirty #719
[   65.037747] Hardware name: Raspberry Pi 3 Model B (DT)
[   65.043656] task: ffff8000362e3e80 task.stack: ffff80003556c000
[   65.050359] PC is at dwc2_map_urb_for_dma+0x94/0x130
[   65.056090] LR is at dwc2_map_urb_for_dma+0x34/0x130
[   65.061819] pc : [<ffff0000083ff0ac>] lr : [<ffff0000083ff04c>] pstate: 000001c5
[   65.070018] sp : ffff80003556fa70
[   65.074080] x29: ffff80003556fa70 x28: 0000000000000005 
[   65.080167] x27: ffff80003563d000 x26: ffff8000350d4600 
[   65.086252] x25: ffff800035686780 x24: 0000000000000002 
[   65.092247] x23: 0000000000000001 x22: 0000000001080020 
[   65.097635] x21: ffff800035425800 x20: 0000000001080020 
[   65.103024] x19: ffff800035b72400 x18: 0000000000000010 
[   65.108413] x17: 0000ffff908f5a40 x16: ffff0000081abad8 
[   65.113801] x15: 0000000000000006 x14: ffff00008882c047 
[   65.119191] x13: ffff00000882c055 x12: ffff00000882e458 
[   65.124579] x11: ffff80003556f7d0 x10: ffff0000087c9a38 
[   65.129968] x9 : ffff0000083613e0 x8 : 363566203a616d64 
[   65.135356] x7 : 5f7075746573203a x6 : 00000000000002fc 
[   65.140744] x5 : 0000000000000000 x4 : 0000000000000000 
[   65.146132] x3 : 0000000000000000 x2 : ffff8000362e3e80 
[   65.151521] x1 : 0000000000000001 x0 : ffff00000880e000 
[   65.156907] 
[   65.158414] ---[ end trace a78d20eaecac455a ]---
[   65.163093] Call trace:
[   65.165573] Exception stack(0xffff80003556f8a0 to 0xffff80003556f9d0)
[   65.172108] f8a0: ffff800035b72400 0001000000000000 ffff80003556fa70 ffff0000083ff0ac
[   65.180052] f8c0: ffff0000086f8f70 ffff000008795000 ffff00000882dce8 ffff0000087fb318
[   65.187996] f8e0: ffff00000882c048 000000010882bae8 ffff80003556f990 ffff0000080dc664
[   65.195940] f900: ffff800035b72400 0000000001080020 ffff800035425800 0000000001080020
[   65.203883] f920: 0000000000000001 0000000000000002 ffff800035686780 ffff8000350d4600
[   65.211827] f940: ffff00000880e000 0000000000000001 ffff8000362e3e80 0000000000000000
[   65.219771] f960: 0000000000000000 0000000000000000 00000000000002fc 5f7075746573203a
[   65.227715] f980: 363566203a616d64 ffff0000083613e0 ffff0000087c9a38 ffff80003556f7d0
[   65.235659] f9a0: ffff00000882e458 ffff00000882c055 ffff00008882c047 0000000000000006
[   65.243601] f9c0: ffff0000081abad8 0000ffff908f5a40
[   65.248548] [<ffff0000083ff0ac>] dwc2_map_urb_for_dma+0x94/0x130
[   65.254643] [<ffff0000083e8984>] usb_hcd_submit_urb+0x8c/0x8c0
[   65.260560] [<ffff0000083eb0b8>] usb_submit_urb+0x248/0x480
[   65.266215] [<ffff0000083d2d2c>] mux_device_request+0xdc/0x1f8
[   65.272134] [<ffff0000083d2e70>] hso_mux_serial_write_data+0x28/0x38
[   65.278581] [<ffff0000083d2fa8>] hso_kick_transmit+0x88/0xb8
[   65.284323] [<ffff0000083d4dc8>] hso_serial_write+0x60/0xc0
[   65.289979] [<ffff000008345e80>] n_tty_write+0x300/0x3e0
[   65.295369] [<ffff000008340a50>] tty_write+0x170/0x2b8
[   65.300585] [<ffff0000081ab6ac>] __vfs_write+0x1c/0x100
[   65.305884] [<ffff0000081ab92c>] vfs_write+0x9c/0x1a8
[   65.311010] [<ffff0000081abb1c>] SyS_write+0x44/0xa0
[   65.316049] [<ffff000008082730>] el0_svc_naked+0x24/0x28

The debug print otherwise just shows:

[   64.476785] dwc2_map_urb_for_dma: setup_dma: 00000000

So it looks like urb->setup_dma content is garbage.

Any thoughts?

Thanks,
baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
