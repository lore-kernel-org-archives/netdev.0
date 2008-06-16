From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:52:54 +0300
Message-ID: <20080616205254.M50992@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:56267 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbYFPUxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:53:15 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id EE961BC196
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 23:52:54 +0300 (EEST)
In-Reply-To: <4856CEDC.6010706@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 13:36:44 -0700, Kok, Auke wrote
> Denys Fedoryshchenko wrote:
> > Also if important
> > MegaRouter-KARAM ~ # dmesg|grep eth1
> > [    3.955620] eth1: (PCI Express:2.5GB/s:Width x1) 00:19:d1:71:5f:33
> > [    3.955622] eth1: Intel(R) PRO/1000 Network Connection
> > [    3.955642] eth1: MAC: 4, PHY: 6, PBA No: ffffff-0ff
> > [    5.358191] netconsole: interface eth1
> 
> please disable netconsole on this device. You should not run 
> netconsole over a critical (and busy) line like this.
> 
> > [    6.432345] eth1: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> > 
> > MegaRouter-KARAM ~ # ethtool eth1
> > Settings for eth1:
> >         Supported ports: [ TP ]
> >         Supported link modes:   10baseT/Half 10baseT/Full
> >                                 100baseT/Half 100baseT/Full
> >                                 1000baseT/Full
> >         Supports auto-negotiation: Yes
> >         Advertised link modes:  10baseT/Half 10baseT/Full
> >                                 100baseT/Half 100baseT/Full
> >                                 1000baseT/Full
> >         Advertised auto-negotiation: Yes
> >         Speed: 1000Mb/s
> >         Duplex: Full
> >         Port: Twisted Pair
> >         PHYAD: 1
> >         Transceiver: internal
> >         Auto-negotiation: on
> >         Supports Wake-on: pumbag
> >         Wake-on: g
> >         Current message level: 0x00000001 (1)
> >         Link detected: yes
> > 
> > 
> > MegaRouter-KARAM ~ # ethtool -c eth1
> > Coalesce parameters for eth1:
> > Adaptive RX: off  TX: off
> > stats-block-usecs: 0
> > sample-interval: 0
> > pkt-rate-low: 0
> > pkt-rate-high: 0
> > 
> > rx-usecs: 3
> > 
> > I tried to change Intel's "magic" rx-usecs to 0,1,3,10000,100000, it doesn't
> > help at all. Attempt to change offloading parameters (disabling) doesn't make
> > sense too.
> > 
> > 
> > On Mon, 16 Jun 2008 21:48:55 +0200, Eric Dumazet wrote
> >> Denys Fedoryshchenko a e'crit :
> >>> Hi again
> >>>
> >>> I moved from PCI Realtek 8169 to onboard PCI-Express e1000e, and situation
> >>> become worse. Strange? Yes.
> >>>
> >>> Here is info
> >>> Load and error rate: 
> >>>
> >>> MegaRouter-KARAM /sys # ifconfig eth1;sleep 10;ifconfig eth1
> >>> eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
> >>>           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
> >>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >>>           RX packets:91991642 errors:0 dropped:1803444 overruns:0 frame:0
> >>>           TX packets:91914611 errors:0 dropped:0 overruns:0 carrier:0
> >>>           collisions:0 txqueuelen:1000
> >>>           RX bytes:316112765 (301.4 MiB)  TX bytes:138303107 (131.8 MiB)
> >>>           Memory:90300000-90320000
> >>>
> >>> eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
> >>>           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
> >>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >>>           RX packets:92812514 errors:0 dropped:1815490 overruns:0 frame:0
> >>>           TX packets:92734865 errors:0 dropped:0 overruns:0 carrier:0
> >>>           collisions:0 txqueuelen:1000
> >>>           RX bytes:739941322 (705.6 MiB)  TX bytes:560547138 (534.5 MiB)
> >>>           Memory:90300000-90320000
> >>>
> >>> System load (there is no NAT, no shapers, just routing, around 600-700
> > routes):
> >>> MegaRouter-KARAM /sys # mpstat 1
> >>> Linux 2.6.26-rc6-git2-build-0029 (MegaRouter-KARAM)     06/16/08
> >>>
> >>> 22:36:36     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> >>> %idle    intr/s
> >>> 22:36:37     all    0.00    0.00    0.00    0.00    0.00    1.49    0.00  
> >>> 98.51  19764.00
> >>> 22:36:38     all    0.00    0.00    0.50    0.00    0.00    0.50    0.00  
> >>> 99.01  19888.00
> >>> 22:36:39     all    0.00    0.00    0.00    0.00    0.00    0.50    0.00  
> >>> 99.50  19642.00
> >>> 22:36:40     all    0.00    0.00    0.00    0.00    1.01    9.05    0.00  
> >>> 89.95  19543.00
> >>>
> >>> (system almost idle)
> >>>
> >>> MegaRouter-KARAM /sys # ethtool -S eth1
> >>> NIC statistics:
> >>>      rx_packets: 109977509
> >>>      tx_packets: 109887692
> >>>      rx_bytes: 57656749138
> >>>      tx_bytes: 57536071746
> >>>      rx_broadcast: 6497
> >>>      tx_broadcast: 92
> >>>      rx_multicast: 48995
> >>>      tx_multicast: 1960
> >>>      rx_errors: 0
> >>>      tx_errors: 0
> >>>      tx_dropped: 0
> >>>      multicast: 48995
> >>>      collisions: 0
> >>>      rx_length_errors: 0
> >>>      rx_over_errors: 0
> >>>      rx_crc_errors: 0
> >>>      rx_frame_errors: 0
> >>>      rx_no_buffer_count: 1796
> >>>      rx_missed_errors: 2182679
> >>>      tx_aborted_errors: 0
> >>>      tx_carrier_errors: 0
> >>>      tx_fifo_errors: 0
> >>>      tx_heartbeat_errors: 0
> >>>      tx_window_errors: 0
> >>>      tx_abort_late_coll: 0
> >>>      tx_deferred_ok: 55617
> >>>      tx_single_coll_ok: 0
> >>>      tx_multi_coll_ok: 0
> >>>      tx_timeout_count: 0
> >>>      tx_restart_queue: 1626
> >>>      rx_long_length_errors: 0
> >>>      rx_short_length_errors: 0
> >>>      rx_align_errors: 0
> >>>      tx_tcp_seg_good: 0
> >>>      tx_tcp_seg_failed: 0
> >>>      rx_flow_control_xon: 55461
> >>>      rx_flow_control_xoff: 57329
> >>>      tx_flow_control_xon: 39114
> >>>      tx_flow_control_xoff: 48341
> >>>      rx_long_byte_count: 57656749138
> >>>      rx_csum_offload_good: 104097306
> >>>      rx_csum_offload_errors: 2209
> >>>      rx_header_split: 0
> >>>      alloc_rx_buff_failed: 0
> >>>      tx_smbus: 22
> >>>      rx_smbus: 2201
> >>>      dropped_smbus: 0
> >>>      rx_dma_failed: 0
> >>>      tx_dma_failed: 0
> >>> MegaRouter-KARAM /sys # ethtool -S eth1
> >>> NIC statistics:
> >>>      rx_packets: 110154571
> >>>      tx_packets: 110064459
> >>>      rx_bytes: 57753358981
> >>>      tx_bytes: 57632419451
> >>>      rx_broadcast: 6501
> >>>      tx_broadcast: 92
> >>>      rx_multicast: 49155
> >>>      tx_multicast: 1960
> >>>      rx_errors: 0
> >>>      tx_errors: 0
> >>>      tx_dropped: 0
> >>>      multicast: 49155
> >>>      collisions: 0
> >>>      rx_length_errors: 0
> >>>      rx_over_errors: 0
> >>>      rx_crc_errors: 0
> >>>      rx_frame_errors: 0
> >>>      rx_no_buffer_count: 1796
> >>>      rx_missed_errors: 2187703
> >>>      tx_aborted_errors: 0
> >>>      tx_carrier_errors: 0
> >>>      tx_fifo_errors: 0
> >>>      tx_heartbeat_errors: 0
> >>>      tx_window_errors: 0
> >>>      tx_abort_late_coll: 0
> >>>      tx_deferred_ok: 55772
> >>>      tx_single_coll_ok: 0
> >>>      tx_multi_coll_ok: 0
> >>>      tx_timeout_count: 0
> >>>      tx_restart_queue: 1628
> >>>      rx_long_length_errors: 0
> >>>      rx_short_length_errors: 0
> >>>      rx_align_errors: 0
> >>>      tx_tcp_seg_good: 0
> >>>      tx_tcp_seg_failed: 0
> >>>      rx_flow_control_xon: 55615
> >>>      rx_flow_control_xoff: 57488
> >>>      tx_flow_control_xon: 39209
> >>>      tx_flow_control_xoff: 48448
> >>>      rx_long_byte_count: 57753358981
> >>>      rx_csum_offload_good: 104264656
> >>>      rx_csum_offload_errors: 2210
> >>>      rx_header_split: 0
> >>>      alloc_rx_buff_failed: 0
> >>>      tx_smbus: 23
> >>>      rx_smbus: 2207
> >>>      dropped_smbus: 0
> >>>      rx_dma_failed: 0
> >>>      tx_dma_failed: 0
> >>>
> >>>
> >>>
> >> What RX & TX rings look like on e1000e ?
> >>
> >> ethtool -g eth1
> >>
> >> Also, please post "cat /proc/interrupts"
> >>


Disabled and rebooted. It changes nothing. (By the way it is first thing i tried).

MegaRouter-KARAM ~ # ifconfig eth1;sleep 10;ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4507198 errors:0 dropped:12335 overruns:0 frame:0
          TX packets:4494262 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1431300040 (1.3 GiB)  TX bytes:1421772965 (1.3 GiB)
          Memory:90300000-90320000

eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5546385 errors:0 dropped:20298 overruns:0 frame:0
          TX packets:5531599 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1849199364 (1.7 GiB)  TX bytes:1837492827 (1.7 GiB)
          Memory:90300000-90320000

Here is full dmesg, as proof, that it is off
] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[    0.235558] ACPI: PCI Interrupt 0000:00:1c.1[B] -> GSI 16 (level, low) ->
IRQ 16
[    0.235562] PCI: Setting latency timer of device 0000:00:1c.1 to 64
[    0.235576] ACPI: PCI Interrupt 0000:00:1c.2[C] -> GSI 18 (level, low) ->
IRQ 18
[    0.235580] PCI: Setting latency timer of device 0000:00:1c.2 to 64
[    0.235593] ACPI: PCI Interrupt 0000:00:1c.3[D] -> GSI 19 (level, low) ->
IRQ 19
[    0.235597] PCI: Setting latency timer of device 0000:00:1c.3 to 64
[    0.235611] ACPI: PCI Interrupt 0000:00:1c.4[A] -> GSI 17 (level, low) ->
IRQ 17
[    0.235615] PCI: Setting latency timer of device 0000:00:1c.4 to 64
[    0.235623] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[    0.235631] NET: Registered protocol family 2
[    0.241017] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.241231] TCP established hash table entries: 131072 (order: 8, 1048576
bytes)
[    0.241532] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.241671] TCP: Hash tables configured (established 131072 bind 65536)
[    0.241673] TCP reno registered
[    0.242025] NET: Registered protocol family 1
[    0.323486] Machine check exception polling timer started.
[    0.323843] highmem bounce pool size: 64 pages
[    0.325672] JFFS2 version 2.2. (SUMMARY)   2001-2006 Red Hat, Inc.
[    0.325828] msgmni has been set to 1741
[    0.325962] Block layer SCSI generic (bsg) driver version 0.4 loaded (major
254)
[    0.325962] io scheduler noop registered
[    0.325962] io scheduler cfq registered (default)
[    0.325962] pci 0000:00:02.0: Boot video device
[    0.326137] PCI: Setting latency timer of device 0000:00:01.0 to 64
[    0.326161] assign_interrupt_mode Found MSI capability
[    0.326181] Allocate Port Service[0000:00:01.0:pcie00]
[    0.326212] Allocate Port Service[0000:00:01.0:pcie03]
[    0.326272] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[    0.326299] assign_interrupt_mode Found MSI capability
[    0.326325] Allocate Port Service[0000:00:1c.0:pcie00]
[    0.326354] Allocate Port Service[0000:00:1c.0:pcie02]
[    0.326381] Allocate Port Service[0000:00:1c.0:pcie03]
[    0.326447] PCI: Setting latency timer of device 0000:00:1c.1 to 64
[    0.326473] assign_interrupt_mode Found MSI capability
[    0.326499] Allocate Port Service[0000:00:1c.1:pcie00]
[    0.326528] Allocate Port Service[0000:00:1c.1:pcie02]
[    0.326558] Allocate Port Service[0000:00:1c.1:pcie03]
[    0.326624] PCI: Setting latency timer of device 0000:00:1c.2 to 64
[    0.326650] assign_interrupt_mode Found MSI capability
[    0.326676] Allocate Port Service[0000:00:1c.2:pcie00]
[    0.326705] Allocate Port Service[0000:00:1c.2:pcie02]
[    0.326734] Allocate Port Service[0000:00:1c.2:pcie03]
[    0.326801] PCI: Setting latency timer of device 0000:00:1c.3 to 64
[    0.326827] assign_interrupt_mode Found MSI capability
[    0.326852] Allocate Port Service[0000:00:1c.3:pcie00]
[    0.326881] Allocate Port Service[0000:00:1c.3:pcie02]
[    0.326908] Allocate Port Service[0000:00:1c.3:pcie03]
[    0.326963] PCI: Setting latency timer of device 0000:00:1c.4 to 64
[    0.326963] assign_interrupt_mode Found MSI capability
[    0.326992] Allocate Port Service[0000:00:1c.4:pcie00]
[    0.327021] Allocate Port Service[0000:00:1c.4:pcie02]
[    0.327048] Allocate Port Service[0000:00:1c.4:pcie03]
[    0.341961] hpet_resources: 0xfed00000 is busy
[    0.342028] Driver 'sd' needs updating - please use bus_type methods
[    0.342159] PNP: No PS/2 controller found. Probing ports directly.
[    0.345015] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.345019] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.345081] mice: PS/2 mouse device common for all mice
[    0.345164] input: PC Speaker as /class/input/input0
[    0.499965] Clockevents: could not switch to one-shot mode: lapic is not
functional.
[    0.499969] Could not switch to high resolution mode on CPU 1
[    0.500964] Clockevents: could not switch to one-shot mode: lapic is not
functional.
[    0.500968] Could not switch to high resolution mode on CPU 0
[    0.510859] device-mapper: uevent: version 1.0.3
[    0.510949] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initialised:
dm-devel@redhat.com
[    0.510949] cpuidle: using governor ladder
[    0.510949] cpuidle: using governor menu
[    0.511209] TCP cubic registered
[    0.511211] NET: Registered protocol family 17
[    0.511220] Using IPI Shortcut mode
[    0.513051] Freeing unused kernel memory: 5508k freed
[    0.860439] usbcore: registered new interface driver usbfs
[    0.860488] usbcore: registered new interface driver hub
[    0.860534] usbcore: registered new device driver usb
[    0.889476] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI)
Driver
[    0.918682] ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) ->
IRQ 18
[    0.918694] PCI: Setting latency timer of device 0000:00:1a.7 to 64
[    0.918697] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    0.918876] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus
number 1
[    0.922777] ehci_hcd 0000:00:1a.7: debug port 1
[    0.922783] PCI: cache line size of 32 is not supported by device 0000:00:1a.7
[    0.922792] ehci_hcd 0000:00:1a.7: irq 18, io mem 0x90326c00
[    0.931942] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10
Dec 2004
[    0.932035] usb usb1: configuration #1 chosen from 1 choice
[    0.932089] hub 1-0:1.0: USB hub found
[    0.932096] hub 1-0:1.0: 4 ports detected
[    1.033074] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.033078] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.033082] usb usb1: Product: EHCI Host Controller
[    1.033084] usb usb1: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 ehci_hcd
[    1.033086] usb usb1: SerialNumber: 0000:00:1a.7
[    1.033113] ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) ->
IRQ 23
[    1.033122] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[    1.033126] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.033177] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus
number 2
[    1.037079] ehci_hcd 0000:00:1d.7: debug port 1
[    1.037085] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
[    1.037091] ehci_hcd 0000:00:1d.7: irq 23, io mem 0x90326800
[    1.046922] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10
Dec 2004
[    1.047013] usb usb2: configuration #1 chosen from 1 choice
[    1.047064] hub 2-0:1.0: USB hub found
[    1.047071] hub 2-0:1.0: 6 ports detected
[    1.148018] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.148021] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.148025] usb usb2: Product: EHCI Host Controller
[    1.148028] usb usb2: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 ehci_hcd
[    1.148030] usb usb2: SerialNumber: 0000:00:1d.7
[    1.178131] USB Universal Host Controller Interface driver v3.0
[    1.178162] ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) ->
IRQ 16
[    1.178169] PCI: Setting latency timer of device 0000:00:1a.0 to 64
[    1.178172] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    1.178211] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus
number 3
[    1.178235] uhci_hcd 0000:00:1a.0: irq 16, io base 0x000030c0
[    1.178309] usb usb3: configuration #1 chosen from 1 choice
[    1.178347] hub 3-0:1.0: USB hub found
[    1.178353] hub 3-0:1.0: 2 ports detected
[    1.279009] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    1.279013] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.279017] usb usb3: Product: UHCI Host Controller
[    1.279020] usb usb3: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 uhci_hcd
[    1.279023] usb usb3: SerialNumber: 0000:00:1a.0
[    1.279042] ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 21 (level, low) ->
IRQ 21
[    1.279050] PCI: Setting latency timer of device 0000:00:1a.1 to 64
[    1.279054] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    1.279101] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus
number 4
[    1.279127] uhci_hcd 0000:00:1a.1: irq 21, io base 0x000030a0
[    1.279212] usb usb4: configuration #1 chosen from 1 choice
[    1.279253] hub 4-0:1.0: USB hub found
[    1.279257] hub 4-0:1.0: 2 ports detected
[    1.353906] usb 2-4: new high speed USB device using ehci_hcd and address 2
[    1.380002] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    1.380006] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.380010] usb usb4: Product: UHCI Host Controller
[    1.380013] usb usb4: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 uhci_hcd
[    1.380016] usb usb4: SerialNumber: 0000:00:1a.1
[    1.380039] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) ->
IRQ 23
[    1.380047] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[    1.380051] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.380099] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus
number 5
[    1.380121] uhci_hcd 0000:00:1d.0: irq 23, io base 0x00003080
[    1.380205] usb usb5: configuration #1 chosen from 1 choice
[    1.380244] hub 5-0:1.0: USB hub found
[    1.380249] hub 5-0:1.0: 2 ports detected
[    1.470314] usb 2-4: configuration #1 chosen from 1 choice
[    1.470643] usb 2-4: New USB device found, idVendor=0951, idProduct=1603
[    1.470645] usb 2-4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    1.470647] usb 2-4: Product: DataTraveler 2.0
[    1.470649] usb 2-4: Manufacturer: Kingston
[    1.470650] usb 2-4: SerialNumber: 8990000000000000000000FB
[    1.481001] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.481004] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.481008] usb usb5: Product: UHCI Host Controller
[    1.481011] usb usb5: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 uhci_hcd
[    1.481015] usb usb5: SerialNumber: 0000:00:1d.0
[    1.481033] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) ->
IRQ 19
[    1.481041] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[    1.481044] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.481094] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus
number 6
[    1.481120] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00003060
[    1.481204] usb usb6: configuration #1 chosen from 1 choice
[    1.481242] hub 6-0:1.0: USB hub found
[    1.481248] hub 6-0:1.0: 2 ports detected
[    1.581993] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.581996] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.582000] usb usb6: Product: UHCI Host Controller
[    1.582003] usb usb6: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 uhci_hcd
[    1.582007] usb usb6: SerialNumber: 0000:00:1d.1
[    1.582025] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) ->
IRQ 18
[    1.582033] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[    1.582037] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.582083] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus
number 7
[    1.582105] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00003040
[    1.582189] usb usb7: configuration #1 chosen from 1 choice
[    1.582226] hub 7-0:1.0: USB hub found
[    1.582231] hub 7-0:1.0: 2 ports detected
[    1.682982] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.682985] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.682989] usb usb7: Product: UHCI Host Controller
[    1.682992] usb usb7: Manufacturer: Linux 2.6.26-rc6-git2-build-0029 uhci_hcd
[    1.682996] usb usb7: SerialNumber: 0000:00:1d.2
[    1.712358] usbcore: registered new interface driver usbhid
[    1.712361] usbhid: v2.6:USB HID core driver
[    1.801687] Initializing USB Mass Storage driver...
[    1.801739] scsi0 : SCSI emulation for USB Mass Storage devices
[    1.801784] usb-storage: device found at 2
[    1.801852] usbcore: registered new interface driver usb-storage
[    1.801856] USB Mass Storage support registered.
[    1.802390] scsi 0:0:0:0: Direct-Access     Kingston DataTraveler 2.0 1.00
PQ: 0 ANSI: 2
[    1.830484] sd 0:0:0:0: [sda] 1965056 512-byte hardware sectors (1006 MB)
[    1.831109] sd 0:0:0:0: [sda] Write Protect is off
[    1.831111] sd 0:0:0:0: [sda] Mode Sense: 23 00 00 00
[    1.831113] sd 0:0:0:0: [sda] Assuming drive cache: write through
[    1.833734] sd 0:0:0:0: [sda] 1965056 512-byte hardware sectors (1006 MB)
[    1.834360] sd 0:0:0:0: [sda] Write Protect is off
[    1.834363] sd 0:0:0:0: [sda] Mode Sense: 23 00 00 00
[    1.834364] sd 0:0:0:0: [sda] Assuming drive cache: write through
[    1.834433]  sda: sda1 sda2
[    1.835240] sd 0:0:0:0: [sda] Attached SCSI removable disk
[    1.835440] usb-storage: device scan complete
[    2.912741] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[    2.912743] e100: Copyright(c) 1999-2006 Intel Corporation
[    2.942563] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
[    2.942566] Copyright (c) 1999-2006 Intel Corporation.
[    2.971978] 8139too Fast Ethernet driver 0.9.28
[    3.088025] ne2k-pci.c:v1.03 9/22/2003 D. Becker/P. Gortmaker
[    3.117402] sis900.c: v1.08.10 Apr. 2 2006
[    3.146609] via-rhine.c:v1.10-LK1.4.3 2007-03-06 Written by Donald Becker
[    3.235204] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[    3.235223] ACPI: PCI Interrupt 0000:07:00.0[A] -> GSI 21 (level, low) ->
IRQ 21
[    3.235828] eth0: RTL8110s at 0xf8894000, 00:18:f8:0b:46:a6, XID 04000000
IRQ 21
[    3.267764] Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
[    4.525631] kjournald starting.  Commit interval 5 seconds
[    4.525633] EXT3-fs warning: maximal mount count reached, running e2fsck is
recommended
[    4.674095] EXT3 FS on dm-0, internal journal
[    4.674098] EXT3-fs: recovery complete.
[    4.678221] EXT3-fs: mounted filesystem with ordered data mode.
[    5.064977] tun: Universal TUN/TAP device driver, 1.6
[    5.064979] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    5.095188] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[    5.095191] All bugs added by David S. Miller <davem@redhat.com>
[    5.156387] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.188039] IPv4 FIB: Using LC-trie version 0.408
[    5.227679] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[    5.227681] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[    5.227724] e1000e 0000:00:19.0: enabling device (0000 -> 0003)
[    5.227731] ACPI: PCI Interrupt 0000:00:19.0[A] -> GSI 20 (level, low) ->
IRQ 20
[    5.227742] PCI: Setting latency timer of device 0000:00:19.0 to 64
[    5.424362] eth1: (PCI Express:2.5GB/s:Width x1) 00:19:d1:71:5f:33
[    5.424364] eth1: Intel(R) PRO/1000 Network Connection
[    5.424385] eth1: MAC: 4, PHY: 6, PBA No: ffffff-0ff
[    5.985995] warning: `zebra' uses 32-bit capabilities (legacy support in use)
[    6.337111] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    6.580759] ACPI: PCI Interrupt 0000:00:1f.3[B] -> GSI 21 (level, low) ->
IRQ 21
[    6.613496] coretemp coretemp.0: Using relative temperature scale!
[    6.614373] coretemp coretemp.1: Using relative temperature scale!
[    6.793450] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.03 (30-Apr-2008)
[    6.794349] iTCO_wdt: Found a ICH8DO TCO device (Version=2, TCOBASE=0x0460)
[    6.794831] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    7.874067] eth1: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX




--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

