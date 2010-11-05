From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more
 per-cpu memory?
Date: Fri, 05 Nov 2010 21:20:03 +0100
Message-ID: <1288988403.2665.268.camel@edumazet-laptop>
References: <4CD43C87.5040403@candelatech.com>
	 <1288980361.2882.1070.camel@edumazet-laptop>
	 <4CD449A5.5070305@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CD449A5.5070305@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 05 novembre 2010 =C3=A0 11:15 -0700, Ben Greear a =C3=A9cri=
t :

> root@lanforge-ubuntu:/home/lanforge# cat /proc/vmallocinfo
> 0xf7ffe000-0xf8000000    8192 hpet_enable+0x2d/0x1b8 phys=3Dfed00000 =
ioremap
> 0xf8002000-0xf8004000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9e000 ioremap
> 0xf8004000-0xf8007000   12288 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
a0000 ioremap
> 0xf8008000-0xf800a000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
90000 ioremap
> 0xf800b000-0xf8010000   20480 module_alloc+0x72/0x80 pages=3D4 vmallo=
c
> 0xf8010000-0xf8019000   36864 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
90000 ioremap
> 0xf801a000-0xf801c000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf801d000-0xf8020000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8023000-0xf8026000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xf8026000-0xf8028000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4fe000 ioremap
> 0xf8028000-0xf802a000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf802b000-0xf802e000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf802f000-0xf8032000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8033000-0xf8036000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8037000-0xf803a000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf803b000-0xf803e000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf803f000-0xf8048000   36864 module_alloc+0x72/0x80 pages=3D8 vmallo=
c
> 0xf804b000-0xf8055000   40960 module_alloc+0x72/0x80 pages=3D9 vmallo=
c
> 0xf8056000-0xf8059000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf805b000-0xf8063000   32768 module_alloc+0x72/0x80 pages=3D7 vmallo=
c
> 0xf8066000-0xf8068000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4fa000 ioremap
> 0xf8068000-0xf8070000   32768 module_alloc+0x72/0x80 pages=3D7 vmallo=
c
> 0xf8072000-0xf8075000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xf8076000-0xf8083000   53248 module_alloc+0x72/0x80 pages=3D12 vmall=
oc
> 0xf8084000-0xf8087000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8088000-0xf808b000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf808c000-0xf808f000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8090000-0xf8093000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8094000-0xf8097000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8098000-0xf809b000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf809c000-0xf809f000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80a2000-0xf80ad000   45056 module_alloc+0x72/0x80 pages=3D10 vmall=
oc
> 0xf80ae000-0xf80b2000   16384 module_alloc+0x72/0x80 pages=3D3 vmallo=
c
> 0xf80b3000-0xf80b6000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80b7000-0xf80ba000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80bb000-0xf80be000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80bf000-0xf80c2000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80c3000-0xf80c6000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80c8000-0xf80cd000   20480 pci_iomap+0x81/0x90 phys=3Dfa4fc000 ior=
emap
> 0xf80ce000-0xf80d1000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80d2000-0xf80d5000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80d6000-0xf80d9000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80da000-0xf80dd000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80de000-0xf80e1000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80e2000-0xf80e5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80e6000-0xf80e9000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80ea000-0xf80ed000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80ee000-0xf80f1000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80f2000-0xf80f5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80f6000-0xf80f9000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80fa000-0xf80fd000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf80fe000-0xf8101000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8102000-0xf8105000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8106000-0xf8109000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf810a000-0xf810d000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf810d000-0xf8118000   45056 module_alloc+0x72/0x80 pages=3D10 vmall=
oc
> 0xf8119000-0xf811c000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf811d000-0xf8120000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8121000-0xf8124000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8125000-0xf8128000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8129000-0xf812c000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf812d000-0xf8130000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8130000-0xf8132000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf8133000-0xf8136000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xf8137000-0xf813a000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf813e000-0xf8140000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4f6000 ioremap
> 0xf8140000-0xf8145000   20480 pci_iomap+0x81/0x90 phys=3Dfa4f8000 ior=
emap
> 0xf8146000-0xf8148000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4f2000 ioremap
> 0xf8148000-0xf814d000   20480 pci_iomap+0x81/0x90 phys=3Dfa4f4000 ior=
emap
> 0xf814e000-0xf8150000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4ee000 ioremap
> 0xf8150000-0xf8155000   20480 pci_iomap+0x81/0x90 phys=3Dfa4f0000 ior=
emap
> 0xf8156000-0xf8158000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4ea000 ioremap
> 0xf8158000-0xf815d000   20480 pci_iomap+0x81/0x90 phys=3Dfa4ec000 ior=
emap
> 0xf815e000-0xf8160000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4e6000 ioremap
> 0xf8160000-0xf8165000   20480 pci_iomap+0x81/0x90 phys=3Dfa4e8000 ior=
emap
> 0xf8166000-0xf8168000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa4e2000 ioremap
> 0xf8168000-0xf816d000   20480 pci_iomap+0x81/0x90 phys=3Dfa4e4000 ior=
emap
> 0xf816e000-0xf8170000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf8170000-0xf8175000   20480 pci_iomap+0x81/0x90 phys=3Dfa4e0000 ior=
emap
> 0xf8176000-0xf8179000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf817a000-0xf817d000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf817e000-0xf8181000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8182000-0xf8185000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8186000-0xf8189000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf818e000-0xf819d000   61440 module_alloc+0x72/0x80 pages=3D14 vmall=
oc
> 0xf819e000-0xf81a1000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81a2000-0xf81a5000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81a6000-0xf81a9000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81aa000-0xf81ad000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81ae000-0xf81b1000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81b2000-0xf81b5000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81b6000-0xf81b9000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81ba000-0xf81bd000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81be000-0xf81c1000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81c2000-0xf81c5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf81fe000-0xf8201000   12288 e1000e_setup_tx_resources+0x27/0xb0 [e1=
000e] pages=3D2 vmalloc
> 0xf8202000-0xf8205000   12288 e1000e_setup_rx_resources+0x2a/0x120 [e=
1000e] pages=3D2 vmalloc
> 0xf8206000-0xf8209000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf820c000-0xf820f000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xf8210000-0xf8213000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8214000-0xf8217000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8218000-0xf821c000   16384 module_alloc+0x72/0x80 pages=3D3 vmallo=
c
> 0xf8225000-0xf8228000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8229000-0xf822b000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf82ab000-0xf82ae000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82af000-0xf82b2000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82b3000-0xf82b6000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82b7000-0xf82ba000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82bb000-0xf82be000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82bf000-0xf82c2000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82c3000-0xf82c6000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82c7000-0xf82ca000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82cb000-0xf82ce000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82cf000-0xf82d2000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82d3000-0xf82d6000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82d7000-0xf82da000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82db000-0xf82de000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82df000-0xf82e2000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82e3000-0xf82e6000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82e7000-0xf82ea000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82eb000-0xf82ee000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf82ef000-0xf82f2000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8332000-0xf8363000  200704 module_alloc+0x72/0x80 pages=3D48 vmall=
oc
> 0xf8364000-0xf8367000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8368000-0xf836b000   12288 e1000e_setup_tx_resources+0x27/0xb0 [e1=
000e] pages=3D2 vmalloc
> 0xf836c000-0xf836f000   12288 e1000e_setup_rx_resources+0x2a/0x120 [e=
1000e] pages=3D2 vmalloc
> 0xf8370000-0xf8373000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8374000-0xf8377000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8378000-0xf837b000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf837c000-0xf837f000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf837f000-0xf83a0000  135168 module_alloc+0x72/0x80 pages=3D32 vmall=
oc
> 0xf83a1000-0xf83a4000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf83a5000-0xf83a8000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf83a9000-0xf83ac000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf83ad000-0xf83b0000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf83b0000-0xf83ba000   40960 module_alloc+0x72/0x80 pages=3D9 vmallo=
c
> 0xf83bb000-0xf83bd000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf83be000-0xf83c1000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf83cc000-0xf83e5000  102400 module_alloc+0x72/0x80 pages=3D24 vmall=
oc
> 0xf83ec000-0xf83ee000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
faedc000 ioremap
> 0xf83f0000-0xf83f2000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa69c000 ioremap
> 0xf83fa000-0xf83fc000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fafdc000 ioremap
> 0xf83fe000-0xf8400000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa698000 ioremap
> 0xf8400000-0xf8421000  135168 e1000_probe+0x206/0x9d0 [e1000e] phys=3D=
faee0000 ioremap
> 0xf8422000-0xf8424000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa79c000 ioremap
> 0xf8426000-0xf8428000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa798000 ioremap
> 0xf842a000-0xf842c000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa99c000 ioremap
> 0xf842e000-0xf8430000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fa998000 ioremap
> 0xf8432000-0xf8434000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
faa9c000 ioremap
> 0xf8436000-0xf8438000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
faa98000 ioremap
> 0xf843a000-0xf843c000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fac9c000 ioremap
> 0xf843e000-0xf8440000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fac98000 ioremap
> 0xf8440000-0xf8461000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa6e=
0000 ioremap
> 0xf8462000-0xf8464000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fad9c000 ioremap
> 0xf8466000-0xf8468000    8192 msix_capability_init+0xae/0x2b0 phys=3D=
fad98000 ioremap
> 0xf846c000-0xf846e000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf8476000-0xf8478000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf8480000-0xf84a1000  135168 e1000_probe+0x206/0x9d0 [e1000e] phys=3D=
fafe0000 ioremap
> 0xf84a9000-0xf84af000   24576 module_alloc+0x72/0x80 pages=3D5 vmallo=
c
> 0xf84bc000-0xf84bf000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84c0000-0xf84e1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa66=
0000 ioremap
> 0xf84e2000-0xf84e5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84e6000-0xf84e9000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84ea000-0xf84ed000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84ee000-0xf84f1000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84f2000-0xf84f5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84f6000-0xf84f9000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf84fb000-0xf84ff000   16384 module_alloc+0x72/0x80 pages=3D3 vmallo=
c
> 0xf8500000-0xf8521000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa7e=
0000 ioremap
> 0xf8522000-0xf852f000   53248 module_alloc+0x72/0x80 pages=3D12 vmall=
oc
> 0xf8530000-0xf8533000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8534000-0xf8537000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8538000-0xf853b000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf853c000-0xf853f000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8540000-0xf8561000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa76=
0000 ioremap
> 0xf8562000-0xf8565000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xf8566000-0xf8569000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf856a000-0xf856c000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xf856d000-0xf8570000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8571000-0xf8574000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8575000-0xf8578000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8579000-0xf857c000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf857d000-0xf857f000    8192 swap_cgroup_swapon+0x3c/0x140 pages=3D1=
 vmalloc
> 0xf8580000-0xf85a1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa9e=
0000 ioremap
> 0xf85a2000-0xf85a5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf85a6000-0xf85a9000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf85aa000-0xf85ad000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf85af000-0xf85b7000   32768 module_alloc+0x72/0x80 pages=3D7 vmallo=
c
> 0xf85b8000-0xf85bb000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf85bc000-0xf85bf000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf85c0000-0xf85e1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa96=
0000 ioremap
> 0xf85e2000-0xf85ed000   45056 sys_swapon+0x5a6/0xa40 pages=3D10 vmall=
oc
> 0xf85ee000-0xf8600000   73728 module_alloc+0x72/0x80 pages=3D17 vmall=
oc
> 0xf8600000-0xf8621000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfaae=
0000 ioremap
> 0xf8622000-0xf8625000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8626000-0xf8629000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf862a000-0xf862d000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf862e000-0xf8631000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8632000-0xf8635000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8636000-0xf8639000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf863a000-0xf863d000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8640000-0xf8661000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfaa6=
0000 ioremap
> 0xf8662000-0xf8665000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8666000-0xf8669000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf866a000-0xf866d000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf866e000-0xf8671000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8672000-0xf8675000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8676000-0xf8679000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf867a000-0xf867d000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8680000-0xf86a1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dface=
0000 ioremap
> 0xf86a2000-0xf86a5000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86a6000-0xf86a9000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86aa000-0xf86ad000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86ae000-0xf86b1000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86b2000-0xf86b5000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86b6000-0xf86b9000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86ba000-0xf86bd000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf86c0000-0xf86e1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfac6=
0000 ioremap
> 0xf86e2000-0xf86e5000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8700000-0xf8721000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfade=
0000 ioremap
> 0xf8740000-0xf8761000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfad6=
0000 ioremap
> 0xf8762000-0xf8767000   20480 module_alloc+0x72/0x80 pages=3D4 vmallo=
c
> 0xf8768000-0xf876b000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf876c000-0xf876f000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8770000-0xf8773000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8774000-0xf8777000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8778000-0xf877b000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf877c000-0xf877f000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8780000-0xf8783000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8784000-0xf8787000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8788000-0xf878b000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf878c000-0xf878f000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8790000-0xf8793000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8793000-0xf87a4000   69632 module_alloc+0x72/0x80 pages=3D16 vmall=
oc
> 0xf87a5000-0xf87a8000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf87aa000-0xf87e7000  249856 module_alloc+0x72/0x80 pages=3D60 vmall=
oc
> 0xf87f4000-0xf87f7000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf87f8000-0xf87fb000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf87fe000-0xf8877000  495616 module_alloc+0x72/0x80 pages=3D120 vmal=
loc
> 0xf8878000-0xf887b000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf887c000-0xf887f000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8880000-0xf8883000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8884000-0xf8887000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8888000-0xf888b000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf888c000-0xf888f000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8890000-0xf8893000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8894000-0xf8897000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf8898000-0xf889b000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf889c000-0xf889f000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf88a0000-0xf88a3000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf88a4000-0xf88a7000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf88a8000-0xf88ab000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf88ac000-0xf88af000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xf88af000-0xf88d5000  155648 module_alloc+0x72/0x80 pages=3D37 vmall=
oc
> 0xf8a65000-0xf8a67000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfa026000-0xfa028000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9e000 ioremap
> 0xfa02a000-0xfa02c000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
90000 ioremap
> 0xfa03a000-0xfa03c000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
90000 ioremap
> 0xfa03e000-0xfa040000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
90000 ioremap
> 0xfa042000-0xfa044000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9e000 ioremap
> 0xfa046000-0xfa048000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9a000 ioremap
> 0xfa04a000-0xfa04c000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9a000 ioremap
> 0xfa04e000-0xfa050000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9a000 ioremap
> 0xfa052000-0xfa054000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9a000 ioremap
> 0xfa056000-0xfa058000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf7=
9a000 ioremap
> 0xfa05e000-0xfa060000    8192 acpi_os_map_memory+0x16/0x1f phys=3Dfed=
1f000 ioremap
> 0xfa06e000-0xfa070000    8192 usb_hcd_pci_probe+0x17b/0x350 phys=3Dfa=
4de000 ioremap
> 0xfa072000-0xfa074000    8192 usb_hcd_pci_probe+0x17b/0x350 phys=3Dfa=
4dc000 ioremap
> 0xfa78c000-0xfa79d000   69632 module_alloc+0x72/0x80 pages=3D16 vmall=
oc
> 0xfa805000-0xfa84a000  282624 module_alloc+0x72/0x80 pages=3D68 vmall=
oc
> 0xfc000000-0xfc400000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfc400000-0xfc800000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfc93f000-0xfc941000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfc94b000-0xfc94e000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xfc95e000-0xfc964000   24576 module_alloc+0x72/0x80 pages=3D5 vmallo=
c
> 0xfc96f000-0xfc972000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xfcdcc000-0xfcddf000   77824 module_alloc+0x72/0x80 pages=3D18 vmall=
oc
> 0xfce11000-0xfce14000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 v=
malloc
> 0xfce15000-0xfce18000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 v=
malloc
> 0xfce19000-0xfce1c000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 v=
malloc
> 0xfce21000-0xfce23000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfce2a000-0xfce2c000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfce30000-0xfce33000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 v=
malloc
> 0xfce34000-0xfce37000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 v=
malloc
> 0xfce38000-0xfce3b000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 v=
malloc
> 0xfd0e7000-0xfd0ea000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd0eb000-0xfd0ee000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd0ef000-0xfd0f2000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd0f3000-0xfd0f6000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd0f7000-0xfd0fa000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd0fb000-0xfd0fe000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd0ff000-0xfd102000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd103000-0xfd106000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd107000-0xfd10a000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd10b000-0xfd10e000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd10f000-0xfd112000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd113000-0xfd116000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd117000-0xfd11a000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd11b000-0xfd11e000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd11f000-0xfd122000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd123000-0xfd126000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd127000-0xfd12a000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd12b000-0xfd12e000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd12f000-0xfd132000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd133000-0xfd136000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd137000-0xfd13a000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd13b000-0xfd13e000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd13f000-0xfd142000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd143000-0xfd146000   12288 igb_setup_tx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd147000-0xfd14a000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd14b000-0xfd14e000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd14f000-0xfd152000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd153000-0xfd156000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd157000-0xfd15a000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd15b000-0xfd15e000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd15f000-0xfd162000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd163000-0xfd166000   12288 igb_setup_rx_resources+0x27/0x140 [igb]=
 pages=3D2 vmalloc
> 0xfd1b2000-0xfd1b6000   16384 module_alloc+0x72/0x80 pages=3D3 vmallo=
c
> 0xfd1bf000-0xfd1c1000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd1cb000-0xfd1ce000   12288 module_alloc+0x72/0x80 pages=3D2 vmallo=
c
> 0xfd1d5000-0xfd1d7000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd1de000-0xfd1e0000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd1e8000-0xfd1ea000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd1f2000-0xfd1f4000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd1fb000-0xfd1fd000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd205000-0xfd207000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd20f000-0xfd211000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd219000-0xfd21b000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd223000-0xfd225000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd22d000-0xfd22f000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd23a000-0xfd23c000    8192 module_alloc+0x72/0x80 pages=3D1 vmallo=
c
> 0xfd248000-0xfd24c000   16384 module_alloc+0x72/0x80 pages=3D3 vmallo=
c
> 0xfd400000-0xfd800000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfd800000-0xfdc00000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfdc00000-0xfe000000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfe000000-0xfe400000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfe400000-0xfe800000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfe800000-0xfec00000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xfec00000-0xff000000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
> 0xff000000-0xff400000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
>=20

Thanks

Your vmalloc space is very fragmented. pcpu_get_vm_areas() want
hugepages (4MB on your machine, 2MB on mine because I have
CONFIG_HIGHMEM64G=3Dy)

You could :

1) Use a 64 bit kernel ( :) )

or

2) boot parameter vmalloc=3D256M   to get more room
   (default is 128 Mbytes)

and eventually

select a 2G/2G User/Kernel split to get more LOWMEM, because big vmallo=
c
windows shrinks the LOWMEM zone. (CONFIG_VMSPLIT_2G=3Dy)
