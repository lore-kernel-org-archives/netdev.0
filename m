From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6 2/2] be2net: remove netif_stop_queue being
 called before register_netdev.
Date: Thu, 24 Feb 2011 16:15:43 +0100
Message-ID: <1298560543.2814.4.camel@edumazet-laptop>
References: <20110131232755.GA4691@akhaparde-VBox>
	 <20110201.154209.179944086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51898 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab1BXPPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 10:15:50 -0500
Received: by bwz15 with SMTP id 15so1100707bwz.19
        for <netdev@vger.kernel.org>; Thu, 24 Feb 2011 07:15:49 -0800 (PST)
In-Reply-To: <20110201.154209.179944086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 f=C3=A9vrier 2011 =C3=A0 15:42 -0800, David Miller a =C3=A9=
crit :
> From: Ajit Khaparde <ajit.khaparde@emulex.com>
> Date: Mon, 31 Jan 2011 17:27:55 -0600
>=20
> > It is illegal to call netif_stop_queue before register_netdev.
> >=20
> > Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
>=20
> Applied, thanks.

Not sure if this patch is queued for stable, I hit the bug (a Warning
actually) on 2.6.37.1

Thanks !

[   40.592799] be2net 0000:02:00.0: PCI INT A -> GSI 24 (level, low) ->=
 IRQ 24
[   40.592812] be2net 0000:02:00.0: setting latency timer to 64
[   40.735947] be2net 0000:02:00.0: irq 68 for MSI/MSI-X
[   40.735952] be2net 0000:02:00.0: irq 69 for MSI/MSI-X
[   40.735956] be2net 0000:02:00.0: irq 70 for MSI/MSI-X
[   40.735960] be2net 0000:02:00.0: irq 71 for MSI/MSI-X
[   40.735964] be2net 0000:02:00.0: irq 72 for MSI/MSI-X
[   40.735967] be2net 0000:02:00.0: irq 73 for MSI/MSI-X
[   40.956881] ------------[ cut here ]------------
[   40.956892] WARNING: at include/linux/netdevice.h:1557 be_probe+0xb3=
d/0xb4e [be2net]()
[   40.956895] Hardware name: ProLiant BL460c G7
[   40.956897] Modules linked in: be2net(+) bnx2 bonding ipv6
[   40.956904] Pid: 6226, comm: modprobe Not tainted 2.6.37.1 #5
[   40.956906] Call Trace:
[   40.956914]  [<f8a959ad>] ? be_probe+0xb3d/0xb4e [be2net]
[   40.956921]  [<f8a959ad>] ? be_probe+0xb3d/0xb4e [be2net]
[   40.956930]  [<c023c03c>] warn_slowpath_common+0x7c/0xa0
[   40.956937]  [<f8a959ad>] ? be_probe+0xb3d/0xb4e [be2net]
[   40.956941]  [<c023c07d>] warn_slowpath_null+0x1d/0x20
[   40.956947]  [<f8a959ad>] be_probe+0xb3d/0xb4e [be2net]
[   40.956953]  [<c0329314>] ? sysfs_addrm_finish+0x14/0xa0
[   40.956959]  [<c0206c40>] ? dma_generic_alloc_coherent+0x0/0x150
[   40.956964]  [<c039a6ee>] local_pci_probe+0xe/0x10
[   40.956968]  [<c039a946>] pci_device_probe+0xc6/0xd0
[   40.956975]  [<c0409d62>] driver_probe_device+0xf2/0x170
[   40.956980]  [<c0409fc5>] __driver_attach+0x75/0x80
[   40.956984]  [<c04090a3>] bus_for_each_dev+0x43/0x70
[   40.956988]  [<c0409b69>] driver_attach+0x19/0x20
[   40.956992]  [<c0409f50>] ? __driver_attach+0x0/0x80
[   40.956996]  [<c040993c>] bus_add_driver+0x1bc/0x2b0
[   40.957000]  [<c039a730>] ? pci_device_shutdown+0x0/0x30
[   40.957003]  [<c040a19a>] driver_register+0x5a/0x130
[   40.957007]  [<c039ab80>] __pci_register_driver+0x40/0xa0
[   40.957014]  [<f8a9b069>] be_init_module+0x69/0x6b [be2net]
[   40.957017]  [<c0201133>] do_one_initcall+0x123/0x170
[   40.957024]  [<f8a9b000>] ? be_init_module+0x0/0x6b [be2net]
[   40.957030]  [<c026d2ef>] sys_init_module+0xcf/0x1070
[   40.957035]  [<c0202b4c>] sysenter_do_call+0x12/0x22
[   40.957038] ---[ end trace 7df725351c768e59 ]---
[   40.957040] netif_stop_queue() cannot be called before register_netd=
ev()


