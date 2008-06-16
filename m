From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:59:57 +0300
Message-ID: <20080616205459.M59264@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	linux.nics@intel.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:46733 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbYFPVAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:00:19 -0400
In-Reply-To: <4856D1D6.7040207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_conntrack unloaded later (just it is not giving message about unloading).


MegaRouter-KARAM ~ # lsmod
Module                  Size  Used by    Not tainted
iTCO_wdt               10404  0
coretemp                5888  0
hwmon                   3100  1 coretemp
i2c_i801                8592  0
i2c_core               17556  1 i2c_i801
e1000e                 85924  0
iptable_filter          3456  1
ip_tables              10768  1 iptable_filter
x_tables               12292  1 ip_tables
8021q                  17184  0
tun                     9092  0
tulip                  45216  0
r8169                  24708  0
sky2                   38660  0
via_velocity           27272  0
via_rhine              19848  0
sis900                 18176  0
ne2k_pci                8928  0
8390                    8704  1 ne2k_pci
skge                   34448  0
tg3                   102148  0
8139too                19968  0
e1000                 103488  0
e100                   30348  0
usb_storage            72896  1
mtdblock                4736  0
mtd_blkdevs             6400  1 mtdblock
usbhid                 18340  0
uhci_hcd               19340  0
ehci_hcd               28940  0
ohci_hcd               19204  0
usbcore               112496  6 usb_storage,usbhid,uhci_hcd,ehci_hcd,ohci_hcd

MegaRouter-KARAM ~ # rmmod iptable_filter
MegaRouter-KARAM ~ # rmmod ip_tables
MegaRouter-KARAM ~ # ifconfig eth1;sleep 10;ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:59092374 errors:0 dropped:1223955 overruns:0 frame:0
          TX packets:59034276 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1495703425 (1.3 GiB)  TX bytes:1378135513 (1.2 GiB)
          Memory:90300000-90320000


eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:59840912 errors:0 dropped:1237198 overruns:0 frame:0
          TX packets:59782319 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1924123084 (1.7 GiB)  TX bytes:1805153608 (1.6 GiB)
          Memory:90300000-90320000

even
MegaRouter-KARAM ~ # rmmod i2c_i801 i2c_core
MegaRouter-KARAM ~ # ifconfig eth1;sleep 10;ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:61504491 errors:0 dropped:1277608 overruns:0 frame:0
          TX packets:61444301 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2873416996 (2.6 GiB)  TX bytes:2751062058 (2.5 GiB)
          Memory:90300000-90320000



eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:62252150 errors:0 dropped:1297292 overruns:0 frame:0
          TX packets:62191551 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3296181383 (3.0 GiB)  TX bytes:3172426660 (2.9 GiB)
          Memory:90300000-90320000

removing iTCO_wdt and USB modules doesn't help too.



On Mon, 16 Jun 2008 13:49:26 -0700, Kok, Auke wrote
> Denys Fedoryshchenko wrote:
> > [    5.227679] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
> > [    5.227681] e1000e: Copyright (c) 1999-2008 Intel Corporation.
> > [    5.227724] e1000e 0000:00:19.0: enabling device (0000 -> 0003)
> > [    5.227731] ACPI: PCI Interrupt 0000:00:19.0[A] -> GSI 20 (level, low) ->
> > IRQ 20
> > [    5.227742] PCI: Setting latency timer of device 0000:00:19.0 to 64
> > [    5.424362] eth1: (PCI Express:2.5GB/s:Width x1) 00:19:d1:71:5f:33
> > [    5.424364] eth1: Intel(R) PRO/1000 Network Connection
> > [    5.424385] eth1: MAC: 4, PHY: 6, PBA No: ffffff-0ff
> > [    5.985995] warning: `zebra' uses 32-bit capabilities (legacy support
in use)
> > [    6.337111] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> 
> disable (all of) netfilter if you don't need it. DEFINATELY do 
> disable nf_conntrack as it's known problematic for routing performance.
> 
> Auke
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

