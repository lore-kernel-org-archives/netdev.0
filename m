From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8390: Don't oops on starting dev queue
Date: Thu, 28 Oct 2010 10:28:48 -0700 (PDT)
Message-ID: <20101028.102848.48509225.davem@davemloft.net>
References: <4CC93BCE.4020303@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934077Ab0J1R2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:28:24 -0400
In-Reply-To: <4CC93BCE.4020303@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 28 Oct 2010 13:01:02 +0400

> The __NS8390_init tries to start the device queue before the
> device is registered. This results in an oops (snipped):
> 
> [    2.865493] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
> [    2.866106] IP: [<ffffffffa000602a>] netif_start_queue+0xb/0x12 [8390]
> [    2.881267] Call Trace:
> [    2.881437]  [<ffffffffa000624d>] __NS8390_init+0x102/0x15a [8390]
> [    2.881999]  [<ffffffffa00062ae>] NS8390_init+0x9/0xb [8390]
> [    2.882237]  [<ffffffffa000d820>] ne2k_pci_init_one+0x297/0x354 [ne2k_pci]
> [    2.882955]  [<ffffffff811c7a0e>] local_pci_probe+0x12/0x16
> [    2.883308]  [<ffffffff811c85ad>] pci_device_probe+0xc3/0xef
> [    2.884049]  [<ffffffff8129218d>] driver_probe_device+0xbe/0x14b
> [    2.884937]  [<ffffffff81292260>] __driver_attach+0x46/0x62
> [    2.885170]  [<ffffffff81291788>] bus_for_each_dev+0x49/0x78
> [    2.885781]  [<ffffffff81291fbb>] driver_attach+0x1c/0x1e
> [    2.886089]  [<ffffffff812912ab>] bus_add_driver+0xba/0x227
> [    2.886330]  [<ffffffff8129259a>] driver_register+0x9e/0x115
> [    2.886933]  [<ffffffff811c8815>] __pci_register_driver+0x50/0xac
> [    2.887785]  [<ffffffffa001102c>] ne2k_pci_init+0x2c/0x2e [ne2k_pci]
> [    2.888093]  [<ffffffff81000212>] do_one_initcall+0x7c/0x130
> [    2.888693]  [<ffffffff8106d74f>] sys_init_module+0x99/0x1da
> [    2.888946]  [<ffffffff81002a2b>] system_call_fastpath+0x16/0x1b
> 
> This happens because the netif_start_queue sets respective bit on the dev->_tx
> array which is not yet allocated.
> 
> As far as I understand the code removing the netif_start_queue from __NS8390_init
> is OK, since queue will be started later on device open. Plz, correct me if I'm wrong.
> 
> Found in the Dave's current tree, so he's in Cc.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
