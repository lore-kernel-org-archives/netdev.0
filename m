From: Satyam Sharma <satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 6 Sep 2007 10:32:33 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709060923340.26804@enigma.security.iitk.ac.in>
References: <20070902184439.GA14306@paradigm.rfc822.org>
 <6bffcb0e0709021659o3856cd06gabc054c949a84397@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Florian Lohoff <flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6bffcb0e0709021659o3856cd06gabc054c949a84397-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,


> On 02/09/07, Florian Lohoff <flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org> wrote:
> >
> > Hi,
> > with current git i got this when "ifconfig eth1" down. eth1 had a mac
> > address which looked really like an eth1394 ethernet although the module
> > was not loaded. Something is really broken in 2.6.23-currentgit. I always get the

-currentgit would be -rc5 right?


> > sysfs rename issues which are discussed to be an udev issue. Then i see
> > a eth1394 mac address on an interface which typically shouldn exist
> > (udev should rename the wireless to eth1) and when issueing an
> > ifconfig eth1 down i get a
> >
> >         BUG: scheduling while atomic: ifconfig/0x00000002/4170

Is this reproducible? Also, please send your .config.

BTW the calltrace below shows that eth1 was the wireless interface when
you tried to "down" it.


> > On the next boot i see the eth1394 mac address on the wireless interface
> > wmaster0_rename whereas eth1 is active (the wireless) and has the correct
> > ip address.

I don't think the "scheduling while atomic" bug you saw is related to
the other problem you're seeing ... these are probably a bunch of all
different issues, but I'm not sure if eth1394 is involved at all.


> > I dont get it - this all looks really messed up. udev is
> > debian sid 114-2.

True, messed up it indeed is.


> > eth0      Link encap:Ethernet  HWaddr 00:17:42:13:45:8C
> >           UP BROADCAST MULTICAST  MTU:1500  Metric:1
> >           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
> >           Interrupt:19
> >
> > eth1      Link encap:Ethernet  HWaddr 00:18:DE:63:F0:B3
> >           inet addr:195.71.97.208  Bcast:195.71.97.223  Mask:255.255.255.224
> >           inet6 addr: fe80::218:deff:fe63:f0b3/64 Scope:Link
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:2079 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:2220 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:508959 (497.0 KiB)  TX bytes:261123 (255.0 KiB)
> >
> > wmaster0_ Link encap:UNSPEC  HWaddr 00-18-DE-63-F0-B3-30-3A-00-00-00-00-00-00-00-00
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
> >
> >
> > [   14.300736] VFS: Mounted root (ext3 filesystem) readonly.
> > [   14.300902] Freeing unused kernel memory: 216k freed
> > [   17.618804] irda_init()
> > [   17.618817] NET: Registered protocol family 23
> > [   17.636399] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 19
> > [   17.636588] PCI: Setting latency timer of device 0000:02:00.0 to 64
> > [   17.636619] sky2 0000:02:00.0: v1.17 addr 0xf0000000 irq 19 Yukon-EC Ultra (0xb4) rev 2
> > [   17.648081] parport_pc 00:0c: reported by Plug and Play ACPI
> > [   17.648206] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
> > [   17.653652] sky2 eth0: addr 00:17:42:13:45:8c
> > [   17.680848] input: Video Bus as /class/input/input6
> > [   17.680961] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
> > [   17.757019] usbcore: registered new interface driver usbfs
> > [   17.757139] usbcore: registered new interface driver hub
> > [   17.757264] usbcore: registered new device driver usb
> > [   17.824819] Yenta: CardBus bridge found at 0000:08:03.0 [10cf:131e]
> > [   17.824941] Yenta O2: res at 0x94/0xD4: 00/ea
> > [   17.825034] Yenta O2: enabling read prefetch/write burst
> > [   17.828363] hda: ATAPI 24X DVD-ROM DVD-R CD-R/RW drive, 2048kB Cache, UDMA(33)
> > [   17.828838] Uniform CD-ROM driver Revision: 3.20
> > [   17.891481] USB Universal Host Controller Interface driver v3.0
> > [   17.891650] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 22
> > [   17.891840] PCI: Setting latency timer of device 0000:00:1d.0 to 64
> > [   17.891844] uhci_hcd 0000:00:1d.0: UHCI Host Controller
> > [   17.892155] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
> > [   17.892327] uhci_hcd 0000:00:1d.0: irq 22, io base 0x00001820
> > [   17.892571] usb usb1: configuration #1 chosen from 1 choice
> > [   17.892689] hub 1-0:1.0: USB hub found
> > [   17.892784] hub 1-0:1.0: 2 ports detected
> > [   17.924265] found SMC SuperIO Chip (devid=0x7a rev=00 base=0x002e): LPC47N227
> > [   17.924390] smsc_superio_flat(): fir: 0x6e8, sir: 0x2e8, dma: 03, irq: 3, mode: 0x0e
> > [   17.924526] smsc_ircc_present: can't get sir_base of 0x2e8
> > [   17.954918] Yenta: ISA IRQ mask 0x0c38, PCI irq 19
> > [   17.955009] Socket status: 30000006
> > [   17.955094] Yenta: Raising subordinate bus# of parent bus (#08) from #09 to #0c
> > [   17.955225] pcmcia: parent PCI bridge I/O window: 0x3000 - 0x3fff
> > [   17.955315] cs: IO port probe 0x3000-0x3fff: clean.
> > [   17.955773] pcmcia: parent PCI bridge Memory window: 0xf0200000 - 0xf02fffff
> > [   17.955864] pcmcia: parent PCI bridge Memory window: 0x30000000 - 0x37ffffff
> > [   17.956497] Yenta: CardBus bridge found at 0000:08:03.1 [10cf:131e]
> > [   17.981605] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, 0.1.14
> > [   17.981752] iwl3945: Copyright(c) 2003-2007 Intel Corporation

Cc'ing ipw3945 ...


> > [   17.983847] sdhci: Secure Digital Host Controller Interface driver
> > [   17.983940] sdhci: Copyright(c) Pierre Ossman
> > [   17.998087] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 20 (level, low) -> IRQ 18
> > [   17.998299] PCI: Setting latency timer of device 0000:00:1d.1 to 64
> > [   17.998303] uhci_hcd 0000:00:1d.1: UHCI Host Controller
> > [   17.998428] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
> > [   17.998601] uhci_hcd 0000:00:1d.1: irq 18, io base 0x00001840
> > [   17.998811] usb usb2: configuration #1 chosen from 1 choice
> > [   17.998933] hub 2-0:1.0: USB hub found
> > [   17.999023] hub 2-0:1.0: 2 ports detected
> > [   18.082862] Yenta: ISA IRQ mask 0x0438, PCI irq 19
> > [   18.082956] Socket status: 30000410
> > [   18.083041] Yenta: Raising subordinate bus# of parent bus (#08) from #0c to #10
> > [   18.083169] pcmcia: parent PCI bridge I/O window: 0x3000 - 0x3fff
> > [   18.083255] cs: IO port probe 0x3000-0x3fff: clean.
> > [   18.083710] pcmcia: parent PCI bridge Memory window: 0xf0200000 - 0xf02fffff
> > [   18.083798] pcmcia: parent PCI bridge Memory window: 0x30000000 - 0x37ffffff
> > [   18.105897] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 20
> > [   18.106097] PCI: Setting latency timer of device 0000:00:1d.2 to 64
> > [   18.106101] uhci_hcd 0000:00:1d.2: UHCI Host Controller
> > [   18.106218] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
> > [   18.106385] uhci_hcd 0000:00:1d.2: irq 20, io base 0x00001860
> > [   18.106594] usb usb3: configuration #1 chosen from 1 choice
> > [   18.106709] hub 3-0:1.0: USB hub found
> > [   18.106799] hub 3-0:1.0: 2 ports detected
> > [   18.213730] ACPI: PCI Interrupt 0000:00:1d.3[D] -> GSI 16 (level, low) -> IRQ 19
> > [   18.213932] PCI: Setting latency timer of device 0000:00:1d.3 to 64
> > [   18.213938] uhci_hcd 0000:00:1d.3: UHCI Host Controller
> > [   18.214052] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
> > [   18.214210] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001880
> > [   18.214414] usb usb4: configuration #1 chosen from 1 choice
> > [   18.214529] hub 4-0:1.0: USB hub found
> > [   18.214620] hub 4-0:1.0: 2 ports detected
> > [   18.318020] ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 22
> > [   18.324538] PCI: Setting latency timer of device 0000:00:1d.7 to 64
> > [   18.324544] ehci_hcd 0000:00:1d.7: EHCI Host Controller
> > [   18.324687] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 5
> > [   18.324857] ehci_hcd 0000:00:1d.7: debug port 1
> > [   18.324951] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
> > [   18.324959] ehci_hcd 0000:00:1d.7: irq 22, io mem 0xf0644000
> > [   18.328914] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
> > [   18.329163] usb usb5: configuration #1 chosen from 1 choice
> > [   18.329282] hub 5-0:1.0: USB hub found
> > [   18.329374] hub 5-0:1.0: 8 ports detected
> > [   18.429643] ACPI: PCI Interrupt 0000:08:03.4[A] -> GSI 16 (level, low) -> IRQ 19
> > [   18.480534] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[19]  MMIO=[f0201000-f02017ff]  Max Packet=[2048]  IR/IT contexts=[8/8]
> > [   18.483902] ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 18 (level, low) -> IRQ 20
> > [   18.484135] PCI: Setting latency timer of device 0000:05:00.0 to 64
> > [   18.484153] iwl3945: Detected Intel PRO/Wireless 3945ABG Network Connection

> > [   18.595000] sdhci: SDHCI controller found at 0000:08:03.2 [1217:7120] (rev 1)
> > [   18.595114] ACPI: PCI Interrupt 0000:08:03.2[A] -> GSI 16 (level, low) -> IRQ 19
> > [   18.595299] sdhci:slot0: Unknown controller version (16). You may experience problems.
> > [   18.595581] mmc0: SDHCI at 0xf0202800 irq 19 PIO
> > [   18.614800] ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 17 (level, low) -> IRQ 23
> > [   18.614990] PCI: Setting latency timer of device 0000:00:1b.0 to 64
> > [   18.700659] iwl3945: Tunable channels: 13 802.11bg, 23 802.11a channels
> > [   18.701906] wmaster0: Selected rate control algorithm 'iwl-3945-rs'

iwl3945 is wmaster0


> > [   18.721016] pccard: PCMCIA card inserted into slot 1
> > [   18.721131] cs: memory probe 0xf0200000-0xf02fffff: excluding 0xf0200000-0xf020ffff
> > [   18.739151] pcmcia: registering new device pcmcia1.0

> > [   18.740929] net eth1: device_rename: sysfs_create_symlink failed (-17)

> > [   18.741075] net wlan0_rename: device_rename: sysfs_create_symlink failed (-17)

These look like interesting bits here ... sysfs_create_symlink() failed
with the infamous -EEXIST. Those were actually two different calls to
dev_change_name()->device_rename()->sysfs_create_symlink() it appears.

If this is reproducible, please rebuild with a kernel with debugging
config options enabled and reproduce.


> > [   18.741625] udev: renamed network interface wmaster0 to eth1

But did this wmaster0 -> eth1 actually succeed, is the question.


> > [   18.779425] cs: IO port probe 0x100-0x3af:<3>si3054: cannot initialize. EXT MID = 0000
> > [   18.783468]  clean.
> > [   18.783592] cs: IO port probe 0x3e0-0x4ff: excluding 0x4d0-0x4d7
> > [   18.784668] cs: IO port probe 0x820-0x8ff: clean.
> > [   18.785521] cs: IO port probe 0xc00-0xcf7: clean.
> > [   18.786456] cs: IO port probe 0xa00-0xaff: clean.
> > [   18.837550] cs: IO port probe 0x100-0x3af: clean.
> > [   18.839641] cs: IO port probe 0x3e0-0x4ff: excluding 0x4d0-0x4d7
> > [   18.840664] cs: IO port probe 0x820-0x8ff: clean.
> > [   18.841501] cs: IO port probe 0xc00-0xcf7: clean.
> > [   18.842426] cs: IO port probe 0xa00-0xaff: clean.
> > [   18.964571] usb 4-2: new full speed USB device using uhci_hcd and address 2
> > [   19.141976] usb 4-2: configuration #1 chosen from 1 choice
> > [   19.214394] Bluetooth: Core ver 2.11
> > [   19.214546] NET: Registered protocol family 31
> > [   19.214640] Bluetooth: HCI device and connection manager initialized
> > [   19.214737] Bluetooth: HCI socket layer initialized
> > [   19.257180] Bluetooth: HCI USB driver ver 2.9
> > [   19.257349] usbcore: registered new interface driver hci_usb
> > [   19.751313] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[00000e10036532e4]
> > [   50.113619] Adding 979924k swap on /dev/sda5.  Priority:-1 extents:1 across:979924k
> > [   50.163229] EXT3 FS on sda6, internal journal
> > [   64.870417] NET: Registered protocol family 10
> > [   64.870613] lo: Disabled Privacy Extensions
> > [   71.028607] Bluetooth: L2CAP ver 2.8
> > [   71.028615] Bluetooth: L2CAP socket layer initialized
> > [   71.168926] Bluetooth: RFCOMM socket layer initialized
> > [   71.169019] Bluetooth: RFCOMM TTY layer initialized
> > [   71.169054] Bluetooth: RFCOMM ver 1.8
> > [   71.539346] ADDRCONF(NETDEV_UP): wlan0_rename: link is not ready
> > [   71.737809] sky2 eth0: enabling interface
> > [   71.740794] sky2 eth0: ram buffer 0K
> > [   71.741733] ADDRCONF(NETDEV_UP): eth0: link is not ready

> > [  142.968449] wlan0_rename: Initial auth_alg=0
> > [  142.968461] wlan0_rename: authenticate with AP 00:0c:41:de:12:e1
> > [  142.976883] wlan0_rename: RX authentication from 00:0c:41:de:12:e1 (alg=0 transaction=2 status=0)
> > [  142.976891] wlan0_rename: authenticated
> > [  142.976895] wlan0_rename: associate with AP 00:0c:41:de:12:e1
> > [  142.979389] wlan0_rename: authentication frame received from 00:0c:41:de:12:e1, but not in authenticate state - ignored
> > [  142.980404] wlan0_rename: RX AssocResp from 00:0c:41:de:12:e1 (capab=0x401 status=0 aid=1)
> > [  142.980412] wlan0_rename: associated
> > [  142.982914] ADDRCONF(NETDEV_CHANGE): wlan0_rename: link becomes ready
> > [  148.291754] ICMPv6 NA: someone advertises our address on wlan0_rename!
> > [  151.386585] wlan0_rename: duplicate address detected!


> > [  382.517007] BUG: scheduling while atomic: ifconfig/0x00000002/4170
> > [  382.517029]  [<c032bf5c>] __sched_text_start+0x84/0x71c
> > [  382.517047]  [<c032c5da>] __sched_text_start+0x702/0x71c
> > [  382.517065]  [<c0174a6c>] link_path_walk+0xa9/0xb3
> > [  382.517079]  [<c032c6ad>] wait_for_completion+0x65/0x9b
> > [  382.517090]  [<c011f0a2>] default_wake_function+0x0/0xc
> > [  382.517103]  [<c01334cf>] synchronize_rcu+0x2a/0x2f
> > [  382.517115]  [<c0133091>] wakeme_after_rcu+0x0/0x8
> > [  382.517127]  [<c02d5f4f>] dev_deactivate+0x89/0x9c
> > [  382.517138]  [<c02c8abc>] dev_close+0x24/0x67
> > [  382.517150]  [<e01f402b>] ieee80211_master_stop+0x4a/0x6d [mac80211]
> > [  382.517176]  [<c02c8ae3>] dev_close+0x4b/0x67
> > [  382.517183]  [<c02c7f47>] dev_change_flags+0x9d/0x14e
> > [  382.517193]  [<c03058c8>] devinet_ioctl+0x224/0x532
> > [  382.517201]  [<c02c9589>] dev_ifsioc+0x113/0x396
> > [  382.517208]  [<c02c8d59>] dev_load+0x24/0x4b
> > [  382.517214]  [<c02be61d>] sock_ioctl+0x0/0x1be
> > [  382.517233]  [<c02be7bc>] sock_ioctl+0x19f/0x1be
> > [  382.517239]  [<c011a993>] do_page_fault+0x269/0x58e
> > [  382.517246]  [<c02be61d>] sock_ioctl+0x0/0x1be
> > [  382.517254]  [<c0176787>] do_ioctl+0x1f/0x62
> > [  382.517263]  [<c0176a01>] vfs_ioctl+0x237/0x249
> > [  382.517270]  [<c016b7d8>] do_sys_open+0xbb/0xc5
> > [  382.517280]  [<c0176a46>] sys_ioctl+0x33/0x4d
> > [  382.517288]  [<c0103e52>] sysenter_past_esp+0x5f/0x85
> > [  382.517303]  =======================


> > [  382.528958] BUG: scheduling while atomic: ifconfig/0x00000002/4170
> > [  382.528972]  [<c032bf5c>] __sched_text_start+0x84/0x71c
> > [  382.528996]  [<c032c6ad>] wait_for_completion+0x65/0x9b
> > [  382.529005]  [<c011f0a2>] default_wake_function+0x0/0xc
> > [  382.529014]  [<c01334cf>] synchronize_rcu+0x2a/0x2f
> > [  382.529021]  [<c0133091>] wakeme_after_rcu+0x0/0x8
> > [  382.529031]  [<c02d5f4f>] dev_deactivate+0x89/0x9c

Probably tangential, but Herbert, is the call to synchronize_rcu() in
dev_deactivate() really correct?

I saw that you put it in commit d4828d85d188dc70 about a year back
and it's supposed to ensure that all outstanding transmissions from
dev_queue_xmit() are over before proceeding. However, I think it may not
serve that purpose -- as the comment before synchronize_rcu() and its
use of call_rcu() [and not of call_rcu_bh()] indicate, synchronize_rcu()
is used to synchronize with all outstanding rcu_read_lock() uses. OTOH,
dev_queue_xmit() uses rcu_read_lock_*bh*() which isn't really the same --
bh / non-bh RCU callbacks have separate lists in the RCU implementation,
so I don't really see anything preventing old transmissions to remain
outstanding even after the synchronize_rcu() call in dev_deactivate (?)

Whether that has anything to do with this particular bug or not,
I have no idea ...


> > [  382.529041]  [<c02c8abc>] dev_close+0x24/0x67
> > [  382.529052]  [<e01f402b>] ieee80211_master_stop+0x4a/0x6d [mac80211]
> > [  382.529077]  [<c02c8ae3>] dev_close+0x4b/0x67
> > [  382.529088]  [<c02c7f47>] dev_change_flags+0x9d/0x14e
> > [  382.529101]  [<c03058c8>] devinet_ioctl+0x224/0x532
> > [  382.529111]  [<c02c9589>] dev_ifsioc+0x113/0x396
> > [  382.529122]  [<c02c8d59>] dev_load+0x24/0x4b
> > [  382.529132]  [<c02be61d>] sock_ioctl+0x0/0x1be
> > [  382.529153]  [<c02be7bc>] sock_ioctl+0x19f/0x1be
> > [  382.529164]  [<c011a993>] do_page_fault+0x269/0x58e
> > [  382.529174]  [<c02be61d>] sock_ioctl+0x0/0x1be
> > [  382.529187]  [<c0176787>] do_ioctl+0x1f/0x62
> > [  382.529201]  [<c0176a01>] vfs_ioctl+0x237/0x249
> > [  382.529211]  [<c016b7d8>] do_sys_open+0xbb/0xc5
> > [  382.529224]  [<c0176a46>] sys_ioctl+0x33/0x4d
> > [  382.529235]  [<c0103e52>] sysenter_past_esp+0x5f/0x85
> > [  382.529253]  =======================
> > [  382.530962] Freeing alive inet6 address cd98f600

Unrelated, but I also wish the "BUG: scheduling while atomic" was the more
instructive show_regs() trace and not a dump_stack() ... I'll make such a
patch today itself.
