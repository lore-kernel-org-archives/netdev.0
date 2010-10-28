From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: cxgb3: kernel access of bad area with v2.6.36-6794-g12ba8d1
Date: Thu, 28 Oct 2010 05:29:23 +0200
Message-ID: <1288236563.2658.59.camel@edumazet-laptop>
References: <20101028015407.GA9564@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Divy Le Ray <divy@chelsio.com>, sonnyrao@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nishanth Aravamudan <nacc@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46765 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932714Ab0J1D33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 23:29:29 -0400
In-Reply-To: <20101028015407.GA9564@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 18:54 -0700, Nishanth Aravamudan a =C3=
=A9crit :
> Hi,
>=20
> I'm seeing the following trace w/ current git on a machine in our lab=
:
>=20
> Chelsio T3 Network Driver - version 1.1.4-ko
> cxgb3 0003:01:00.0: enabling device (0140 -> 0142)
> Unable to handle kernel paging request for data at address 0x00000010
> Faulting instruction address: 0xd000000008473ae8
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=3D32 NUMA pSeries
> last sysfs file: /sys/devices/virtual/block/dm-0/dev
> Modules linked in: cxgb3(+) mdio ehea ib_ehca ib_core ext4 jbd2 mbcac=
he sd_mod crc_t10dif ipr dm_mod [last unloaded: scsi_wait_scan]
> NIP: d000000008473ae8 LR: d000000008473ac4 CTR: c0000000004398a0
> REGS: c0000007a157f190 TRAP: 0300   Not tainted  (2.6.36)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24424444  XER: 00000000
> DAR: 0000000000000010, DSISR: 0000000040000000
> TASK =3D c0000007a3755290[741] 'modprobe' THREAD: c0000007a157c000 CP=
U: 24
> GPR00: 0000000000000000 c0000007a157f410 d000000008486978 c0000007a52=
6c000=20
> GPR04: c0000000006d25dd c0000007a526c005 c0000007a526c29e 00000000000=
00002=20
> GPR08: 0000000000000004 0000000000000010 c0000007a526c0a0 00000000000=
00000=20
> GPR12: d000000008474aa8 c00000000eed3c00 d00000000847aeb8 00000000000=
00001=20
> GPR16: 0000000000001000 0000000000000000 d000000008477aa8 00003c047ef=
7e000=20
> GPR20: c0000007a8b7d280 c0000007a8b7d310 d00000000847d1c0 d0000000084=
7d1d8=20
> GPR24: 0000000000000003 00003c047ef7efff 0000000000000001 c0000007a3c=
1c000=20
> GPR28: 0000000000000000 c0000007a526c000 d000000008484210 c0000007a3c=
1c000=20
> NIP [d000000008473ae8] .init_one+0x510/0xb7c [cxgb3]
> LR [d000000008473ac4] .init_one+0x4ec/0xb7c [cxgb3]
> Call Trace:
> [c0000007a157f410] [d000000008473ac4] .init_one+0x4ec/0xb7c [cxgb3] (=
unreliable)
> [c0000007a157f560] [c0000000002e40bc] .local_pci_probe+0x7c/0x100
> [c0000007a157f5f0] [c0000000002e5018] .pci_device_probe+0x148/0x150
> [c0000007a157f6a0] [c00000000034df68] .driver_probe_device+0x128/0x33=
0
> [c0000007a157f750] [c00000000034e27c] .__driver_attach+0x10c/0x110
> [c0000007a157f7e0] [c00000000034d15c] .bus_for_each_dev+0x9c/0xf0
> [c0000007a157f890] [c00000000034dbc8] .driver_attach+0x28/0x40
> [c0000007a157f910] [c00000000034c648] .bus_add_driver+0x218/0x3d0
> [c0000007a157f9c0] [c00000000034e718] .driver_register+0x98/0x1d0
> [c0000007a157fa60] [c0000000002e5354] .__pci_register_driver+0x64/0x1=
40
> [c0000007a157fb00] [d000000008474278] .cxgb3_init_module+0x2c/0x44 [c=
xgb3]
> [c0000007a157fb80] [c000000000009754] .do_one_initcall+0x64/0x1e0
> [c0000007a157fc40] [c0000000000d28b8] .SyS_init_module+0x1b8/0x1790
> [c0000007a157fe30] [c000000000008564] syscall_exit+0x0/0x40
> Instruction dump:
> 9b890018 9b090019 48000fe9 e8410028 801d0308 2f800000 419e003c 396000=
00=20
> e93d0300 796045e4 7d290214 39290010 <7c0048a8> 7c00d378 7c0049ad 40a2=
fff4=20
> ---[ end trace 2a530df8c4ad3d70 ]---
> udevd-work[600]: '/sbin/modprobe -b pci:v00001425d00000030sv00001014s=
d0000038Cbc02sc00i00' unexpected exit with status 0x000b
>=20
> I did an objdump -ldr of cxgb3.ko and:
>=20
>=20
>  4c0:   48 00 00 01     bl      4c0 <.init_one+0x4c0>
>                         4c0: R_PPC64_REL24      .alloc_etherdev_mq
>  4c4:   60 00 00 00     nop
>  4c8:   7c 7d 1b 79     mr.     r29,r3
>  4cc:   41 82 03 28     beq-    7f4 <.init_one+0x7f4>
>  4d0:   39 3d 07 00     addi    r9,r29,1792
>  4d4:   fa bd 03 f8     std     r21,1016(r29)
>  4d8:   fb bb 32 08     std     r29,12808(r27)
>  4dc:   fb fd 07 00     std     r31,1792(r29)
>  4e0:   9b 89 00 18     stb     r28,24(r9)
>  4e4:   9b 09 00 19     stb     r24,25(r9)
>  4e8:   48 00 00 01     bl      4e8 <.init_one+0x4e8>
>                         4e8: R_PPC64_REL24      .netif_carrier_off
>  4ec:   60 00 00 00     nop
>  4f0:   80 1d 03 08     lwz     r0,776(r29)
>  4f4:   2f 80 00 00     cmpwi   cr7,r0,0
>  4f8:   41 9e 00 3c     beq-    cr7,534 <.init_one+0x534>
>  4fc:   39 60 00 00     li      r11,0
>  500:   e9 3d 03 00     ld      r9,768(r29)
>  504:   79 60 45 e4     rldicr  r0,r11,8,55
>  508:   7d 29 02 14     add     r9,r9,r0
>  50c:   39 29 00 10     addi    r9,r9,16
>  510:   7c 00 48 a8     ldarx   r0,0,r9
>  514:   7c 00 d3 78     or      r0,r0,r26
>  518:   7c 00 49 ad     stdcx.  r0,0,r9
>  51c:   40 a2 ff f4     bne-    510 <.init_one+0x510>
>=20
> So I'm guessing it's somewhere in here:
>=20
>         for (i =3D 0; i < ai->nports0 + ai->nports1; ++i) {
>                 struct net_device *netdev;
>=20
>                 netdev =3D alloc_etherdev_mq(sizeof(struct port_info)=
, SGE_QSETS);
>                 if (!netdev) {
>                         err =3D -ENOMEM;
>                         goto out_free_dev;
>                 }
>=20
>                 SET_NETDEV_DEV(netdev, &pdev->dev);
>=20
>                 adapter->port[i] =3D netdev;
>                 pi =3D netdev_priv(netdev);
>                 pi->adapter =3D adapter;
>                 pi->rx_offload =3D T3_RX_CSUM | T3_LRO;
>                 pi->port_id =3D i;
>                 netif_carrier_off(netdev);
>                 netif_tx_stop_all_queues(netdev);
>                 netdev->irq =3D pdev->irq;
>                 netdev->mem_start =3D mmio_start;
>                 netdev->mem_end =3D mmio_start + mmio_len - 1;
>                 netdev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM | =
NETIF_F_TSO;
>                 netdev->features |=3D NETIF_F_GRO;
>                 if (pci_using_dac)
>                         netdev->features |=3D NETIF_F_HIGHDMA;
>=20
>                 netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW=
_VLAN_RX;
>                 netdev->netdev_ops =3D &cxgb_netdev_ops;
>                 SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
>         }
>=20
> Well, presuming the trace is mostly accurate?  I'm not sure what else=
 is
> needed to determine the problem further. I'm building 2.6.36 as I wri=
te
> this.  But it doesn't seem like this code has changed much and I had =
a
> working kernel around 2.6.36-rc7...
>=20

It seems this crash is because  alloc_etherdev_mq() (alloc_netdev_mq())
not anymore allocates tx_queues.


So netif_tx_stop_all_queues(netdev) is crashing, accessing a NULL
pointer in your driver.

netif_tx_stop_all_queues(netdev) should be called only once device is
registered : netif_alloc_netdev_queues() is called from
register_netdevice()

Take a look at commit 8f6d9f40476895571 to have an example of how to fi=
x
this problem.

Thanks




