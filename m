From: Adam Ford <aford173@gmail.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Tue, 29 Aug 2017 19:49:09 -0500
Message-ID: <CAHCN7xKfZeyTHZShWGYYen50NSzTErh8X8np3WJfrYTBrO_RPw@mail.gmail.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
 <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com> <CAHCN7xLHEjda9DcVw5iHA9RaJ7UnyMVxf7e4e8NTEj9Op1JaBw@mail.gmail.com>
 <20170828211217.GO6008@atomide.com> <94c4cbb0-1df3-2f2f-69f3-f9a788e610fa@ti.com>
 <CAHCN7x+-wymsqw96mt7Du=Huxh5rq=Rj9GidWPLXptJSW7taEA@mail.gmail.com>
 <f0f5e11f-cd7a-cb86-58b5-8ce44cdbc032@ti.com> <CAHCN7xK2=PN5MOr48HOkZnwKwkM4ypcvQct+Ko+ChNFG3Pv62w@mail.gmail.com>
 <955b0b1b-9bb7-ad25-4d6c-676be1efb943@ti.com> <CAHCN7x+paAdW7cXrALhtLZZiJbkE6v_8_qRXBec7hxLJPvSMbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tony Lindgren <tony@atomide.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:35112 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH3AtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 20:49:11 -0400
In-Reply-To: <CAHCN7x+paAdW7cXrALhtLZZiJbkE6v_8_qRXBec7hxLJPvSMbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 10:20 AM, Adam Ford <aford173@gmail.com> wrote:
> On Tue, Aug 29, 2017 at 10:16 AM, Sekhar Nori <nsekhar@ti.com> wrote:
>> On Tuesday 29 August 2017 05:32 PM, Adam Ford wrote:
>>> On Tue, Aug 29, 2017 at 6:42 AM, Sekhar Nori <nsekhar@ti.com> wrote:
>>>> On Tuesday 29 August 2017 03:53 PM, Adam Ford wrote:
>>>>> On Tue, Aug 29, 2017 at 3:23 AM, Sekhar Nori <nsekhar@ti.com> wrote:
>>>>>> On Tuesday 29 August 2017 02:42 AM, Tony Lindgren wrote:
>>>>>>> * Adam Ford <aford173@gmail.com> [170828 13:33]:
>>>>>>>> On Mon, Aug 28, 2017 at 1:54 PM, Grygorii Strashko
>>>>>>>> <grygorii.strashko@ti.com> wrote:
>>>>>>>>> Cc: Sekhar
>>>>>>>>>
>>>>>>>>> On 08/28/2017 10:32 AM, Adam Ford wrote:
>>>>>>>>>>
>>>>>>>>>> The davinvi_emac MAC address seems to attempt a call to
>>>>>>>>>> ti_cm_get_macid in cpsw-common.c but it returns the message
>>>>>>>>>> 'davinci_emac davinci_emac.1: incompatible machine/device type for
>>>>>>>>>> reading mac address ' and then generates a random MAC address.
>>>>>>>>>>
>>>>>>>>>> The function appears to lookup varions boards using
>>>>>>>>>> 'of_machine_is_compaible' and supports dm8148, am33xx, am3517, dm816,
>>>>>>>>>> am4372 and dra7.  I don't see the ti,davinci-dm6467-emac which is
>>>>>>>>>> what's shown in the da850 device tree.
>>>>>>>>>>
>>>>>>>>>> Is there a patch somewhere for supporting the da850-evm?
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> Not sure if MAC address can be read from Control module.
>>>>>>>>> May be Sekhar can say more?
>>>>>>>>
>>>>>>>> My understanding is that the MAC address is programmed by Logic PD
>>>>>>>> into the SPI flash.  The Bootloader reads this from either SPI or its
>>>>>>>> env variables.  Looking at the partition info listed in the
>>>>>>>> da850-evm.dts file, it appears as if they've reserved space for it.
>>>>>>>> Unfortunately, I don't see any code that reads it out.  I was hoping
>>>>>>
>>>>>> This code is present in U-Boot sources at
>>>>>> board/davinci/da8xxevm/da850evm.c. See the function get_mac_addr() and
>>>>>> its usage in misc_init_r().
>>>>>>
>>>>>>>> there might be a way to just pass cmdline parameter from the
>>>>>>>> bootloader to the kernel to accept the MAC address.
>>>>>>>>
>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> If not, is there a way to pass the MAC address from U-Boot to the
>>>>>>>>>> driver so it doesn't generate a random MAC?
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> "local-mac-address" dt porp
>>>>>>>>
>>>>>>>> The downside here, is that we'd have to have the Bootloader modify the
>>>>>>>> device tree.
>>>>>>>
>>>>>>> That piece of code exists somewhere in u-boot already. Note how
>>>>>>
>>>>>> Yes, it is fdt_fixup_ethernet() and its usage is in common/image-fdt.c.
>>>>>>
>>>>>>> we are populating the mac address for USB Ethernet drivers in
>>>>>>> u-boot and then the Ethernet driver code parses it. See commit
>>>>>>> 055d31de7158 ("ARM: omap3: beagleboard-xm: dt: Add ethernet to
>>>>>>> the device tree") for some more information.
>>>>>>>
>>>>>>> I think u-boot needs the ethernet alias for finding the interface.
>>>>>>
>>>>>> That's exactly what was missing. I have sent a patch for fixing that and
>>>>>> copied you there.
>>>>>
>>>>> Thanks for doing that.
>>>>>
>>>>>>
>>>>>> Adam, if I can get your Tested-by, I will make an attempt to send it for
>>>>>> v4.13 itself.
>>>>>
>>>>> I will test it.  Do need to run some instruction or do something
>>>>> special in U-Boot to pass this in the proper place for the kernel to
>>>>> pull it?  Tony's patch reference showed
>>>>> command for fdt set, but I am not sure I fully understand the
>>>>> parameters that went along with that.
>>>>
>>>> Nope, just applying the patch and booting the with the new dtb should
>>>> result in the random mac address going away.
>>>
>>> Unfortunately, I am not seeing any change with the patch (at least
>>> with Kernel 4.12.9 from stable).
>>>
>>> netconsole: network logging started
>>> davinci_emac davinci_emac.1: incompatible machine/device type for
>>> reading mac address
>>> davinci_emac davinci_emac.1: using random MAC addr: ee:74:c3:3a:15:be
>>>
>>> Looking at the source for cpsw-common.c function ti_cm_get_macid()
>>> doesn't have a case for the  ti,davinci-dm6467-emac so I wonder if
>>> there might be more to it.
>>
>> Hmm, it did solve the issue for me when I tried latest -next. And
>> reverting the patch brought back the random mac address usage. Could you
>> try latest mainline or -next?
>>
>> Meanwhile let me see whats going on with the observations you have.
>
> I will try again with -next this afternoon and see what I can find.
> Can you tell me which U-Boot version you're using? I want to match
> your setup. I want to see if something is missing during the hand-off
> between the Bootloader and Linux.
>

I wonder if U-Boot isn't pushing something to Linux because it doesn't
appear to be running some of the da850 specific code even when I run
linux-next.  Can you tell me what verision of U-Boot you're using?
Other than using davinci_all_defconfig, did you change the
configuration at all?

[    1.411107] netconsole: network logging started
[    1.416237] davinci_emac davinci_emac.1: incompatible machine/device type for
 reading mac address
[    1.424496] davinci_emac davinci_emac.1: using random MAC addr: be:e2:84:ed:3
c:87

I also confirmed the SPI-flash has the MAC programmed:

# hexdump /dev/mtd5ro
0000000 0800 04ee 8e32 ffff ffff ffff ffff ffff
0000010 ffff ffff ffff ffff ffff ffff ffff ffff



Here is my full log:

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.13.0-rc7-next-20170829 (aford@ubuntu16) (gcc vers
ion 4.8.3 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29)) #1 PREEMPT
 Tue Aug 29 19:11:06 CDT 2017
[    0.000000] CPU: ARM926EJ-S [41069265] revision 5 (ARMv5TEJ), cr=0005317f
[    0.000000] CPU: VIVT data cache, VIVT instruction cache
[    0.000000] OF: fdt: Machine model: DA850/AM1808/OMAP-L138 EVM
[    0.000000] Memory policy: Data cache writethrough
[    0.000000] DaVinci da850/omap-l138 variant 0x0
[    0.000000] On node 0 totalpages: 8192
[    0.000000] free_area_init_node: node 0, pgdat c05dfec8, node_mem_map c1fb900
0
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 8192 pages, LIFO batch:0
[    0.000000] random: fast init done
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 8128
[    0.000000] Kernel command line: mem=32M console=ttyS2,115200n8 root=/dev/mmc
blk0p2 rw wait noinitrd
[    0.000000] PID hash table entries: 128 (order: -3, 512 bytes)
[    0.000000] Dentry cache hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Inode-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Memory: 26196K/32768K available (4412K kernel code, 330K rwdata,
1012K rodata, 224K init, 146K bss, 6572K reserved, 0K cma-reserved)
[    0.000000] Virtual kernel memory layout:
                   vector  : 0xffff0000 - 0xffff1000   (   4 kB)
                   fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
                   vmalloc : 0xc2800000 - 0xff800000   ( 976 MB)
                   lowmem  : 0xc0000000 - 0xc2000000   (  32 MB)
                   modules : 0xbf000000 - 0xc0000000   (  16 MB)
                     .text : 0xc0008000 - 0xc04574e8   (4414 kB)
                     .init : 0xc0556000 - 0xc058e000   ( 224 kB)
                     .data : 0xc058e000 - 0xc05e09e0   ( 331 kB)
                      .bss : 0xc05e4ebc - 0xc06097b4   ( 147 kB)\x00c - 0xc06097
b4   ( 147 kB)
[    0.000000] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  Tasks RCU enabled.\x00d.
[    0.000000] NR_IRQS: 245
[    0.000000] clocksource: timer0_1: mask: 0xffffffff max_cycles: 0xffffffff, m
ax_idle_ns: 79635851949 ns
[    0.000000] sched_clock: 32 bits at 24MHz, resolution 41ns, wraps every 89478
484971ns
[    0.000480] Console: colour dummy device 80x30
[    0.000623] Calibrating delay loop... 148.88 BogoMIPS (lpj=744448)
[    0.070151] pid_max: default: 32768 minimum: 301
[    0.070730] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.070802] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.073212] CPU: Testing write buffer coherency: ok
[    0.076384] Setting up static identity map for 0xc0008400 - 0xc0008458
[    0.077078] Hierarchical SRCU implementation.
[    0.081656] devtmpfs: initialized
[    0.102577] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, ma
x_idle_ns: 19112604462750000 ns
[    0.102678] futex hash table entries: 256 (order: -1, 3072 bytes)
[    0.103368] pinctrl core: initialized pinctrl subsystem
[    0.107090] NET: Registered protocol family 16
[    0.108769] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.112006] cpuidle: using governor menu
[    0.142220] mux: initialized RTC_ALARM
[    0.142267] mux: Setting register RTC_ALARM
[    0.142313] mux:    PINMUX0 (0x00000000) = 0x44080000 -> 0x24080000
[    0.173799] edma 1c00000.edma: memcpy is disabled
[    0.187509] edma 1c00000.edma: TI EDMA DMA engine driver
[    0.188706] edma 1e30000.edma: memcpy is disabled
[    0.203238] edma 1e30000.edma: TI EDMA DMA engine driver
[    0.208604] i2c_davinci i2c_davinci.1: could not find pctldev for node /soc@1
c00000/pinmux@14120/pinmux_i2c0_pins, deferring probe
[    0.213319] clocksource: Switched to clocksource timer0_1
[    0.272942] NET: Registered protocol family 2
[    0.276271] TCP established hash table entries: 1024 (order: 0, 4096 bytes)
[    0.276399] TCP bind hash table entries: 1024 (order: 0, 4096 bytes)
[    0.276478] TCP: Hash tables configured (established 1024 bind 1024)
[    0.276920] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    0.277028] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    0.277860] NET: Registered protocol family 1
[    0.279709] RPC: Registered named UNIX socket transport module.
[    0.279757] RPC: Registered udp transport module.
[    0.279779] RPC: Registered tcp transport module.
[    0.279800] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.286296] workingset: timestamp_bits=30 max_order=13 bucket_order=0
[    0.334423] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 2
51)
[    0.334488] io scheduler noop registered (default)
[    0.334519] io scheduler mq-deadline registered
[    0.334544] io scheduler kyber registered
[    0.337441] pinctrl-single 1c14120.pinmux: 160 pins at pa fec14120 size 80
[    0.724136] Serial: 8250/16550 driver, 3 ports, IRQ sharing disabled
[    0.731781] serial8250.0: ttyS0 at MMIO 0x1c42000 (irq = 25, base_baud = 9375
000) is a TI DA8xx/66AK2x
[    0.736191] serial8250.1: ttyS1 at MMIO 0x1d0c000 (irq = 53, base_baud = 8250
000) is a TI DA8xx/66AK2x
[    0.740320] serial8250.2: ttyS2 at MMIO 0x1d0d000 (irq = 61, base_baud = 8250
000) is a TI DA8xx/66AK2x
[    1.104485] console [ttyS2] enabled
[    1.112179] brd: module loaded
[    1.115635] libphy: Fixed MDIO Bus: probed
[    1.173556] davinci_mdio davinci_mdio.0: davinci mdio revision 1.5, bus freq
2200000
[    1.180102] davinci_mdio davinci_mdio.0: detected phy mask fffffffe
[    1.188281] libphy: davinci_mdio.0: probed
[    1.191175] davinci_mdio davinci_mdio.0: phy[0]: device davinci_mdio.0:00, dr
iver SMSC LAN8710/LAN8720
[    1.200474] i2c /dev entries driver
[    1.203043] IR NEC protocol handler initialized
[    1.206722] IR RC5(x/sz) protocol handler initialized
[    1.210530] IR RC6 protocol handler initialized
[    1.214207] IR JVC protocol handler initialized
[    1.217493] IR Sony protocol handler initialized
[    1.220843] IR SANYO protocol handler initialized
[    1.224603] IR Sharp protocol handler initialized
[    1.228062] IR MCE Keyboard/mouse protocol handler initialized
[    1.232635] IR XMP protocol handler initialized
[    1.293829] davinci_mmc da830-mmc.0: Using DMA, 4-bit mode
[    1.307464] NET: Registered protocol family 10
[    1.317055] Segment Routing with IPv6
[    1.319797] sit: IPv6, IPv4 and MPLS over IPv4 tunneling driver
[    1.330958] NET: Registered protocol family 17
[    1.362382] mmc0: host does not support reading read-only switch, assuming wr
ite-enable
[    1.374564] pca953x 0-0020: 0-0020 supply vcc not found, using dummy regulato
r
[    1.381327] mmc0: new high speed SDHC card at address b368
[    1.387395] mmcblk0: mmc0:b368 00000 3.75 GiB
[    1.392025] pca953x 0-0020: failed reading register
[    1.398285]  mmcblk0: p1 p2
[    1.403791] pca953x: probe of 0-0020 failed with error -121
[    1.408691] console [netcon0] enabled
[    1.411107] netconsole: network logging started
[    1.416237] davinci_emac davinci_emac.1: incompatible machine/device type for
 reading mac address
[    1.424496] davinci_emac davinci_emac.1: using random MAC addr: be:e2:84:ed:3
c:87
[    1.435043] hctosys: unable to open rtc device (rtc0)
[    1.439533] vbat: disabling
[    1.455953] EXT4-fs (mmcblk0p2): couldn't mount as ext3 due to feature incomp
atibilities
[    1.495292] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. O
pts: (null)
[    1.502362] VFS: Mounted root (ext4 filesystem) on device 179:2.
[    1.509400] devtmpfs: mounted
[    1.512507] Freeing unused kernel memory: 224K
[    1.515909] This architecture does not have kernel memory protection.
[    1.942277] EXT4-fs (mmcblk0p2): re-mounted. Opts: (null)
[    2.381303] udevd[54]: starting version 3.2.2
[    2.611166] udevd[55]: starting eudev-3.2.2
[    4.393796] omap_rtc 1c23000.rtc: rtc core: registered 1c23000.rtc as rtc0
[    4.760433] davinci-wdt davinci-wdt: heartbeat 60 sec
[    5.631862] spi_davinci spi_davinci.1: Controller at 0xfef0e000
[    5.715839] vpif vpif: vpif probe success
[    5.805009] Linux video capture interface: v2.00
[    5.876891] asoc-simple-card sound: tlv320aic3x-hifi <-> davinci-mcasp.0 mapp
ing ok
[    6.281740] adv7343 0-002a: chip found @ 0x54 (DaVinci I2C adapter)
[    6.304545] adv7343 0-002a: Error initializing
[    6.307892] adv7343: probe of 0-002a failed with error -121
[    6.312763] vpif_display vpif_display: Error registering v4l2 subdevice
[    6.503036] tvp514x 0-005d: Write: retry ... 0
[    6.543977] tvp514x 0-005d: Write: retry ... 1
[    6.574113] tvp514x 0-005d: Write: retry ... 2
[    6.603935] tvp514x 0-005d: Write: retry ... 3
[    6.633983] tvp514x 0-005d: Write: retry ... 4
[    6.663965] tvp514x 0-005d: Write: retry ... 5
[    6.693978] tvp514x 0-005d: tvp514x 0-005d decoder driver registered !!
[    6.704907] vpif_capture vpif_capture: registered sub device tvp514x-0
[    6.813679] tvp514x 0-005c: Write: retry ... 0
[    6.844005] tvp514x 0-005c: Write: retry ... 1
[    6.874221] tvp514x 0-005c: Write: retry ... 2
[    6.903956] tvp514x 0-005c: Write: retry ... 3
[    6.934023] tvp514x 0-005c: Write: retry ... 4
[    6.963950] tvp514x 0-005c: Write: retry ... 5
[    6.993967] tvp514x 0-005c: tvp514x 0-005c decoder driver registered !!
[    7.013865] vpif_capture vpif_capture: registered sub device tvp514x-1
[    7.052179] tvp514x 0-005d: Write: retry ... 0
[    7.093976] tvp514x 0-005d: Write: retry ... 1
[    7.123965] tvp514x 0-005d: Write: retry ... 2
[    7.153916] tvp514x 0-005d: Write: retry ... 3
[    7.184160] tvp514x 0-005d: Write: retry ... 4
[    7.219318] tvp514x 0-005d: Write: retry ... 5
[    7.243986] vpif_capture vpif_capture: Failed to set input
[   12.944674] m25p80 spi0.0: m25p64 (8192 Kbytes)
[   12.973994] nand: No NAND device found
[   13.062551] 6 ofpart partitions found on MTD device spi0.0
[   13.067365] Creating 6 MTD partitions on "spi0.0":
[   13.070964] 0x000000000000-0x000000010000 : "U-Boot-SPL"
[   13.084491] 0x000000010000-0x000000090000 : "U-Boot"
[   13.095174] 0x000000090000-0x0000000a0000 : "U-Boot-Env"
[   13.106238] 0x0000000a0000-0x000000320000 : "Kernel"
[   13.116910] 0x000000320000-0x000000720000 : "Filesystem"
[   13.127963] 0x0000007f0000-0x000000800000 : "MAC-Address"

>
>>
>> Thanks,
>> Sekhar
