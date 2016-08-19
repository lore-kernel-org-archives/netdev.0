From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: Kernel NFS boot failure
Date: Fri, 19 Aug 2016 14:14:27 +0300
Message-ID: <478afde3-32ce-27e6-e865-9fbb893c2836@ti.com>
References: <674e6841-d2c5-ccae-6633-a699e848e6d2@ti.com>
 <57A1DE28.7020604@arm.com> <c234fc25-ef5b-eecc-450f-34d01410f9de@ti.com>
 <a094b3c3-0441-4e7f-7e51-f6ee5d6bb2f1@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vladimir Murzin <vladimir.murzin@arm.com>, Neil Brown <neilb@suse.de>,
 Sekhar Nori <nsekhar@ti.com>, open list <linux-kernel@vger.kernel.org>,
 "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
 linux-arm <linux-arm-kernel@lists.infradead.org>
To: netdev <netdev@vger.kernel.org>, Trond Myklebust
 <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>, Anna
 Schumaker <anna.schumaker@netapp.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <a094b3c3-0441-4e7f-7e51-f6ee5d6bb2f1@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi All,
On 08/11/2016 07:25 PM, Grygorii Strashko wrote:
> On 08/03/2016 06:04 PM, Grygorii Strashko wrote:
>> Hi Vladimir,
>>
>> On 08/03/2016 03:06 PM, Vladimir Murzin wrote:
>>> On 03/08/16 12:41, Grygorii Strashko wrote:
>>>> We observe Kernel boot failure while running NFS boot stress test (1000 iterations):
>>>> - Linux version 4.7.0 
>>
>> I'd like to pay your attention that this issue also reproducible with
>> Kernel 4.7.0!
>> The same can be seen from the log I've provided in first e-mail:
>> [    0.000000] Linux version 4.7.0 (lcpdbld@dflsdit-build06.dal.design.ti.com) (gcc version 4.9.3 20150413 (prerelease) (Linaro GCC 4.9-2015.05) ) #1 SMP Fri Jul 29 17:41:27 CDT 2016
>>
>>
>> I've not run the test with current master at it's not been tagged yet.
> 
> Still in progress. rc1 unstable on my platforms due to other issues :(
> 
>>
>>>> - am335x-evm (TI AM335x EVM)
>>>> - failure rate 10-20 times per test.
>>>> Originally this issue was reproduced using TI Kernel 4.4
>>>> ( git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git, branch: ti-linux-4.4.y)
>>>> on both am335x-evm and am57xx-beagle-x15(am57xx-evm) platforms.
>>>> This issues has not been reproduced with TI Kernel 4.1 before.
>>>>
>>>> The SysRq shows that system stuck in nfs_fs_mount()
>>>>
>>>> [  207.904632] [<c07ab34c>] (schedule) from [<c0783554>] (rpc_wait_bit_killable+0x2c/0xd8)
>>>> [  207.912996] [<c0783554>] (rpc_wait_bit_killable) from [<c07ab7f0>] (__wait_on_bit+0x84/0xc0)
>>>> [  207.921812] [<c07ab7f0>] (__wait_on_bit) from [<c07ab890>] (out_of_line_wait_on_bit+0x64/0x70)
>>>> [  207.930810] [<c07ab890>] (out_of_line_wait_on_bit) from [<c07843f4>] (__rpc_execute+0x18c/0x544)
>>>> [  207.939988] [<c07843f4>] (__rpc_execute) from [<c0779f24>] (rpc_run_task+0x13c/0x158)
>>>> [  207.948166] [<c0779f24>] (rpc_run_task) from [<c0779f84>] (rpc_call_sync+0x44/0xc4)
>>>> [  207.956163] [<c0779f84>] (rpc_call_sync) from [<c077a04c>] (rpc_ping+0x48/0x68)
>>>> [  207.963796] [<c077a04c>] (rpc_ping) from [<c077a158>] (rpc_create_xprt+0xec/0x164)
>>>> [  207.971702] [<c077a158>] (rpc_create_xprt) from [<c077a2c0>] (rpc_create+0xf0/0x1a0)
>>>> [  207.979794] [<c077a2c0>] (rpc_create) from [<c0393088>] (nfs_create_rpc_client+0xd4/0xec)
>>>> [  207.988338] [<c0393088>] (nfs_create_rpc_client) from [<c0394d10>] (nfs_init_client+0x20/0x78)
>>>> [  207.997332] [<c0394d10>] (nfs_init_client) from [<c03949d4>] (nfs_create_server+0xa0/0x3bc)
>>>> [  208.006057] [<c03949d4>] (nfs_create_server) from [<c03b197c>] (nfs3_create_server+0x8/0x20)
>>>> [  208.014879] [<c03b197c>] (nfs3_create_server) from [<c03a34c4>] (nfs_try_mount+0xc4/0x1f0)
>>>> [  208.023513] [<c03a34c4>] (nfs_try_mount) from [<c03a2c48>] (nfs_fs_mount+0x290/0x910)
>>>> [  208.031702] [<c03a2c48>] (nfs_fs_mount) from [<c0294d24>] (mount_fs+0x44/0x168)
>>>>

I was able to reproduce this issue with NFS/SUNRPC debug logs enabled using TI kernel 4.4.
I'd be appreciated for any help :( and be happy to run any kind of tests or check debug patches if needed.

>From the logs I found that problem happens when rpc_task 2 is freeing too late as in the below log.
(marked as [GS])


Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.4.18-32575-g5db1dce (lcpdbld@dflsdit-build06.dal.design.ti.com) (gcc version 4.9.3 20150413 (prerelease) (Linaro GCC 4.9-2015.05) ) #2 SMP PREEMPT Wed Aug 17 10:49:14 CDT 2016
[    0.000000] CPU: ARMv7 Processor [412fc0f2] revision 2 (ARMv7), cr=30c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, PIPT instruction cache
[    0.000000] Machine model: TI AM5728 EVM
[    0.000000] Reserved memory: created CMA memory pool at 0x0000000095800000, size 56 MiB
[    0.000000] Reserved memory: initialized node ipu2_cma@95800000, compatible id shared-dma-pool
[    0.000000] Reserved memory: created CMA memory pool at 0x0000000099000000, size 64 MiB
[    0.000000] Reserved memory: initialized node dsp1_cma@99000000, compatible id shared-dma-pool
[    0.000000] Reserved memory: created CMA memory pool at 0x000000009d000000, size 32 MiB
[    0.000000] Reserved memory: initialized node ipu1_cma@9d000000, compatible id shared-dma-pool
[    0.000000] Reserved memory: created CMA memory pool at 0x000000009f000000, size 8 MiB
[    0.000000] Reserved memory: initialized node dsp2_cma@9f000000, compatible id shared-dma-pool
[    0.000000] cma: Reserved 24 MiB at 0x00000000fe400000
[    0.000000] Forcing write-allocate cache policy for SMP
[    0.000000] Memory policy: Data cache writealloc
[    0.000000] OMAP4: Map 0x00000000ffd00000 to fe600000 for dram barrier
[    0.000000] DRA752 ES1.1
[    0.000000] PERCPU: Embedded 11 pages/cpu @eed31000 s14848 r8192 d22016 u45056
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 521792
[    0.000000] Kernel command line: console=ttyO2,115200n8  earlyprintk=serial,ttyO2,115200n8 rootwait  ip=:::::eth0:dhcp  root=/dev/nfs rw nfsroot=192.168.0.1:/home/tigtfarm10/NFS_exports/linux/am57xx-evm/autofs/f1a395609921e4cdad1b0bb2ec56f877,nolock,v3,tcp,rsize=4096,wsize=4096 
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Memory: 1875576K/2094080K available (6523K kernel code, 358K rwdata, 2408K rodata, 336K init, 289K bss, 30088K reserved, 188416K cma-reserved, 1283072K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
[    0.000000]     vmalloc : 0xf0800000 - 0xff800000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf0000000   ( 768 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc08c106c   (8933 kB)
[    0.000000]       .init : 0xc08c2000 - 0xc0916000   ( 336 kB)
[    0.000000]       .data : 0xc0916000 - 0xc096f9a0   ( 359 kB)
[    0.000000]        .bss : 0xc0972000 - 0xc09ba6b0   ( 290 kB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 32.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] OMAP clockevent source: timer1 at 32786 Hz
[    0.000000] Architected cp15 timer(s) running at 6.14MHz (virt).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x16af5adb9, max_idle_ns: 440795202250 ns
[    0.000004] sched_clock: 56 bits at 6MHz, resolution 162ns, wraps every 4398046511023ns
[    0.000015] Switching to timer-based delay loop, resolution 162ns
[    0.000328] clocksource: 32k_counter: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 58327039986419 ns
[    0.000337] OMAP clocksource: 32k_counter at 32768 Hz
[    0.000760] Console: colour dummy device 80x30
[    0.000776] WARNING: Your 'console=ttyO2' has been replaced by 'ttyS2'
[    0.000782] This ensures that you still see kernel messages. Please
[    0.000788] update your kernel commandline.
[    0.000801] Calibrating delay loop (skipped), value calculated using timer frequency.. 12.29 BogoMIPS (lpj=61475)
[    0.000814] pid_max: default: 32768 minimum: 301
[    0.000906] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000916] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.001461] Initializing cgroup subsys io
[    0.001478] Initializing cgroup subsys memory
[    0.001502] Initializing cgroup subsys devices
[    0.001514] Initializing cgroup subsys freezer
[    0.001525] Initializing cgroup subsys perf_event
[    0.001536] Initializing cgroup subsys pids
[    0.001562] CPU: Testing write buffer coherency: ok
[    0.001764] /cpus/cpu@0 missing clock-frequency property
[    0.001781] /cpus/cpu@1 missing clock-frequency property
[    0.001791] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
[    0.001827] Setting up static identity map for 0x800082c0 - 0x80008318
[    0.080183] CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
[    0.080250] Brought up 2 CPUs
[    0.080262] SMP: Total of 2 processors activated (24.59 BogoMIPS).
[    0.080269] CPU: All CPU(s) started in SVC mode.
[    0.080643] devtmpfs: initialized
[    0.106472] VFP support v0.3: implementor 41 architecture 4 part 30 variant f rev 0
[    0.107342] omap_hwmod: l3_main_2 using broken dt data from ocp
[    0.304568] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.308002] pinctrl core: initialized pinctrl subsystem
[    0.308848] NET: Registered protocol family 16
[    0.309801] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.340242] cpuidle: using governor ladder
[    0.370275] cpuidle: using governor menu
[    0.378776] OMAP GPIO hardware version 0.1
[    0.385225] irq: no irq domain found for /ocp/l4@4a000000/scm@2000/pinmux@1400 !
[    0.409647] hw-breakpoint: found 5 (+1 reserved) breakpoint and 4 watchpoint registers.
[    0.409657] hw-breakpoint: maximum watchpoint size is 8 bytes.
[    0.410122] omap4_sram_init:Unable to allocate sram needed to handle errata I688
[    0.410131] omap4_sram_init:Unable to get sram pool needed to handle errata I688
[    0.410723] OMAP DMA hardware revision 0.0
[    0.444520] omap-dma-engine 4a056000.dma-controller: OMAP DMA engine driver
[    0.445630] edma 43300000.edma: memcpy is disabled
[    0.450477] edma 43300000.edma: TI EDMA DMA engine driver
[    0.454327] omap-iommu 40d01000.mmu: 40d01000.mmu registered
[    0.454507] omap-iommu 40d02000.mmu: 40d02000.mmu registered
[    0.454658] omap-iommu 58882000.mmu: 58882000.mmu registered
[    0.454806] omap-iommu 55082000.mmu: 55082000.mmu registered
[    0.455061] omap-iommu 41501000.mmu: 41501000.mmu registered
[    0.455249] omap-iommu 41502000.mmu: 41502000.mmu registered
[    0.458152] palmas 0-0058: Irq flag is 0x00000008
[    0.472649] palmas 0-0058: Muxing GPIO 2f, PWM 0, LED 0
[    0.554028] omap_i2c 48070000.i2c: bus 0 rev0.12 at 400 kHz
[    0.554526] omap_i2c 48060000.i2c: bus 2 rev0.12 at 400 kHz
[    0.555103] omap_i2c 4807c000.i2c: bus 4 rev0.12 at 400 kHz
[    0.555313] media: Linux media interface: v0.10
[    0.555368] Linux video capture interface: v2.00
[    0.555410] pps_core: LinuxPPS API ver. 1 registered
[    0.555417] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.555443] PTP clock support registered
[    0.555490] EDAC MC: Ver: 3.0.0
[    0.556248] omap-mailbox 4883c000.mailbox: omap mailbox rev 0x400
[    0.556543] omap-mailbox 4883e000.mailbox: omap mailbox rev 0x400
[    0.556831] omap-mailbox 48840000.mailbox: omap mailbox rev 0x400
[    0.557123] omap-mailbox 48842000.mailbox: omap mailbox rev 0x400
[    0.557444] Advanced Linux Sound Architecture Driver Initialized.
[    0.558290] clocksource: Switched to clocksource arch_sys_counter
[    0.569416] NET: Registered protocol family 2
[    0.569913] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    0.569977] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
[    0.570101] TCP: Hash tables configured (established 8192 bind 8192)
[    0.570149] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.570180] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.570325] NET: Registered protocol family 1
[    0.570361] RPC:       creating workqueue rpciod
[    0.570524] RPC:       registering /proc/net/rpc
[    0.570662] svc: Adding svc transport class 'tcp'
[    0.570670] svc: Adding svc transport class 'udp'
[    0.570687] RPC: Registered named UNIX socket transport module.
[    0.570694] RPC: Registered udp transport module.
[    0.570699] RPC: Registered tcp transport module.
[    0.570705] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.571727] hw perfevents: enabled with armv7_cortex_a15 PMU driver, 7 counters available
[    0.574145] futex hash table entries: 512 (order: 3, 32768 bytes)
[    0.582005] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.582247] RPC:       creating workqueue nfsiod
[    0.582620] RPC:       registering /proc/net/rpc/nfs
[    0.582669] NFS: Registering the id_resolver key type
[    0.582700] Key type id_resolver registered
[    0.582707] Key type id_legacy registered
[    0.582770] ntfs: driver 2.1.32 [Flags: R/O].
[    0.584763] bounce: pool size: 64 pages
[    0.584920] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
[    0.584936] io scheduler noop registered
[    0.584949] io scheduler deadline registered
[    0.584984] io scheduler cfq registered (default)
[    0.589950] pinctrl-single 4a003400.pinmux: 282 pins at pa fc003400 size 1128
[    0.593494] PCI host bridge /ocp/axi@0/pcie@51000000 ranges:
[    0.593505]   No bus range found for /ocp/axi@0/pcie@51000000, using [bus 00-ff]
[    0.593536]    IO 0x20003000..0x20012fff -> 0x00000000
[    0.593556]   MEM 0x20013000..0x2fffffff -> 0x20013000
[    0.623979] dra7-pcie 51000000.pcie: link is not up
[    0.624163] dra7-pcie 51000000.pcie: PCI host bridge to bus 0000:00
[    0.624175] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.624185] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.624195] pci_bus 0000:00: root bus resource [mem 0x20013000-0x2fffffff]
[    0.624598] PCI: bus0: Fast back to back transfers disabled
[    0.638362] PCI: bus1: Fast back to back transfers disabled
[    0.638409] irq: no irq domain found for /ocp/axi@0/pcie@51000000/interrupt-controller !
[    0.638449] irq: no irq domain found for /ocp/axi@0/pcie@51000000/interrupt-controller !
[    0.638487] pci 0000:00:00.0: BAR 0: assigned [mem 0x20100000-0x201fffff]
[    0.638502] pci 0000:00:00.0: BAR 8: assigned [mem 0x20200000-0x202fffff]
[    0.638514] pci 0000:00:00.0: BAR 9: assigned [mem 0x20300000-0x203fffff pref]
[    0.638525] pci 0000:00:00.0: BAR 1: assigned [mem 0x20020000-0x2002ffff]
[    0.638538] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
[    0.638553] pci 0000:01:00.0: BAR 6: assigned [mem 0x20300000-0x2030ffff pref]
[    0.638564] pci 0000:01:00.0: BAR 5: assigned [mem 0x20200000-0x202001ff]
[    0.638584] pci 0000:01:00.0: BAR 4: assigned [io  0x1000-0x101f]
[    0.638603] pci 0000:01:00.0: BAR 0: assigned [io  0x1020-0x1027]
[    0.638621] pci 0000:01:00.0: BAR 2: assigned [io  0x1028-0x102f]
[    0.638639] pci 0000:01:00.0: BAR 1: assigned [io  0x1030-0x1033]
[    0.638658] pci 0000:01:00.0: BAR 3: assigned [io  0x1034-0x1037]
[    0.638676] pci 0000:00:00.0: PCI bridge to [bus 01]
[    0.638686] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
[    0.638698] pci 0000:00:00.0:   bridge window [mem 0x20200000-0x202fffff]
[    0.638708] pci 0000:00:00.0:   bridge window [mem 0x20300000-0x203fffff pref]
[    0.638936] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
[    0.638947] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    0.640117] backlight supply power not found, using dummy regulator
[    0.701389] Serial: 8250/16550 driver, 10 ports, IRQ sharing disabled
[    0.704755] 48020000.serial: ttyS2 at MMIO 0x48020000 (irq = 301, base_baud = 3000000) is a 8250
[    1.803275] console [ttyS2] enabled
[    1.807606] 48422000.serial: ttyS7 at MMIO 0x48422000 (irq = 302, base_baud = 3000000) is a 8250
[    1.817676] [drm] Initialized drm 1.1.0 20060810
[    1.824304] OMAP DSS rev 6.1
[    1.828074] omapdss_dss 58000000.dss: bound 58001000.dispc (ops dispc_component_ops)
[    1.836561] omapdss_dss 58000000.dss: bound 58040000.encoder (ops hdmi5_component_ops)
[    1.852730] loop: module loaded
[    1.858711] libphy: Fixed MDIO Bus: probed
[    1.908322] davinci_mdio 48485000.mdio: davinci mdio revision 1.6
[    1.914447] davinci_mdio 48485000.mdio: detected phy mask fffffff9
[    1.924982] libphy: 48485000.mdio: probed
[    1.929054] davinci_mdio 48485000.mdio: phy[1]: device 48485000.mdio:01, driver Micrel KSZ9031 Gigabit PHY
[    1.938788] davinci_mdio 48485000.mdio: phy[2]: device 48485000.mdio:02, driver Micrel KSZ9031 Gigabit PHY
[    1.949155] cpsw 48484000.ethernet: Detected MACID = 74:da:ea:47:8b:26
[    1.956425] cpsw 48484000.ethernet: cpsw: Detected MACID = 74:da:ea:47:8b:27
[    1.964968] mousedev: PS/2 mouse device common for all mice
[    1.971072] i2c /dev entries driver
[    1.977349] gpio-fan gpio_fan: GPIO fan initialized
[    1.983301] tmp102 0-0048: initialized
[    1.989999] omap_hsmmc 4809c000.mmc: Got CD GPIO
[    2.038843] omap_hsmmc 480b4000.mmc: no pinctrl state for sdr25 mode
[    2.045225] omap_hsmmc 480b4000.mmc: no pinctrl state for sdr12 mode
[    2.068430] vdd_3v3: supplied by regen1
[    2.149616] ledtrig-cpu: registered to indicate activity on CPUs
[    2.159632] davinci-mcasp 48468000.mcasp: ERRATA i868 workaround is enabled
[    2.167775] NET: Registered protocol family 10
[    2.183098] sit: IPv6 over IPv4 tunneling driver
[    2.188303] NET: Registered protocol family 17
[    2.192973] Key type dns_resolver registered
[    2.197370] omap_voltage_late_init: Voltage driver support not added
[    2.204273] Adding alias for supply vdd,cpu0 -> vdd,4a003b20.oppdm
[    2.210499] Adding alias for supply vbb,cpu0 -> vbb,4a003b20.oppdm
[    2.217194] Adding alias for supply vdd,cpu0 -> vdd,4a003b20.oppdm
[    2.223424] Adding alias for supply vbb,cpu0 -> vbb,4a003b20.oppdm
[    2.231589] Power Management for TI OMAP4+ devices.
[    2.236687] Registering SWP/SWPB emulation handler
[    2.243623] dmm 4e000000.dmm: initialized all PAT entries
[    2.271099] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    2.277741] [drm] No driver support for vblank timestamp query.
[    2.337700] mmc0: host does not support reading read-only switch, assuming write-enable
[    2.349180] mmc0: new high speed SDHC card at address aaaa
[    2.355029] mmcblk0: mmc0:aaaa SL08G 7.40 GiB 
[    2.360674]  mmcblk0: p1 p2 p3
[    2.422915] mmc1: MAN_BKOPS_EN bit is not set
[    2.435914] mmc1: new DDR MMC card at address 0001
[    2.451053] mmcblk1: mmc1:0001 S10004 3.56 GiB 
[    2.465778] mmcblk1boot0: mmc1:0001 S10004 partition 1 4.00 MiB
[    2.471891] mmcblk1boot1: mmc1:0001 S10004 partition 2 4.00 MiB
[    2.478728]  mmcblk1: p1 p2 p3
[    2.562262] [drm] Enabling DMM ywrap scrolling
[    2.600301] Console: switching to colour frame buffer device 100x30
[    2.608627] omapdrm omapdrm.0: fb0: omapdrm frame buffer device
[    2.638571] [drm] Initialized omapdrm 1.0.0 20110917 on minor 0
[    2.645862] input: gpio_keys as /devices/platform/gpio_keys/input/input0
[    2.652827] hctosys: unable to open rtc device (rtc0)
[    2.668349] net eth0: initializing cpsw version 1.15 (0)
[    2.673702] net eth0: initialized cpsw ale version 1.4
[    2.678878] net eth0: ALE Table size 1024
[    2.770336] net eth0: phy found : id is : 0x221622
[    2.781714] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    6.776920] cpsw 48484000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[    6.784829] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    6.798309] Sending DHCP requests ., OK
[    6.848304] IP-Config: Got DHCP answer from 192.168.0.1, my address is 192.168.0.97
[    6.856129] IP-Config: Complete:
[    6.859400]      device=eth0, hwaddr=74:da:ea:47:8b:26, ipaddr=192.168.0.97, mask=255.255.255.0, gw=192.168.0.1
[    6.870013]      host=192.168.0.97, domain=ti.com, nis-domain=(none)
[    6.876395]      bootserver=0.0.0.0, rootserver=192.168.0.1, rootpath=
[    6.882795]      nameserver0=192.0.2.2, nameserver1=192.0.2.3
[    6.888933] aic_dvdd_fixed: disabling
[    6.892611] vmmcwl_fixed: disabling
[    6.896293] ldousb: disabling
[    6.899787] ALSA device list:
[    6.902765]   No soundcards found.
[    6.907052] Root-NFS: nfsroot=/home/tigtfarm10/NFS_exports/linux/am57xx-evm/autofs/f1a395609921e4cdad1b0bb2ec56f877,nolock,v3,tcp,rsize=4096,wsize=4096
[    6.920854] NFS: nfs mount opts='vers=2,udp,rsize=4096,wsize=4096,nolock,v3,tcp,rsize=4096,wsize=4096,nolock,addr=192.168.0.1'
[    6.932330] NFS:   parsing nfs mount option 'vers=2'
[    6.937399] NFS:   parsing nfs mount option 'udp'
[    6.942194] NFS:   parsing nfs mount option 'rsize=4096'
[    6.947561] NFS:   parsing nfs mount option 'wsize=4096'
[    6.952967] NFS:   parsing nfs mount option 'nolock'
[    6.957980] NFS:   parsing nfs mount option 'v3'
[    6.962725] NFS:   parsing nfs mount option 'tcp'
[    6.967607] NFS:   parsing nfs mount option 'rsize=4096'
[    6.972959] NFS:   parsing nfs mount option 'wsize=4096'
[    6.978359] NFS:   parsing nfs mount option 'nolock'
[    6.983345] NFS:   parsing nfs mount option 'addr=192.168.0.1'
[    6.989222] NFS: MNTPATH: '/home/tigtfarm10/NFS_exports/linux/am57xx-evm/autofs/f1a395609921e4cdad1b0bb2ec56f877'
[    6.999540] NFS: sending MNT request for 192.168.0.1:/home/tigtfarm10/NFS_exports/linux/am57xx-evm/autofs/f1a395609921e4cdad1b0bb2ec56f877
[    7.012046] RPC:       set up xprt to 192.168.0.1 (autobind) via tcp
[    7.018454] RPC:       created transport eddc9000 with 65536 slots
[    7.024659] RPC:       creating mount client for 192.168.0.1 (xprt eddc9000)
[    7.031785] RPC:       creating UNIX authenticator for client ee8ead00
[    7.038376] RPC:       new task initialized, procpid 1
[    7.043532] RPC:       allocated task edd8cc00
[    7.047993] RPC:     1 __rpc_execute flags=0x680
[    7.052636] RPC:     1 call_start mount3 proc NULL (sync)
[    7.058055] RPC:     1 call_reserve (status 0)
[    7.062524] RPC:     1 reserved req ee8eac00 xid 57c6e885
[    7.067944] RPC:       wake_up_first(eddc9100 "xprt_sending")
[    7.073725] RPC:     1 call_reserveresult (status 0)
[    7.078720] RPC:     1 call_refresh (status 0)
[    7.083180] RPC:     1 holding NULL cred c096c2f0
[    7.087901] RPC:     1 refreshing NULL cred c096c2f0
[    7.092894] RPC:     1 call_refreshresult (status 0)
[    7.097877] RPC:     1 call_allocate (status 0)
[    7.102432] RPC:     1 allocated buffer of size 92 at eddc9800
[    7.108302] RPC:     1 call_bind (status 0)
[    7.112502] RPC:     1 rpcb_getport_async(192.168.0.1, 100005, 3, 6)
[    7.118913] RPC:     1 sleep_on(queue "xprt_binding" time 4294938008)
[    7.125380] RPC:     1 added to queue eddc90a4 "xprt_binding"
[    7.131159] RPC:     1 setting alarm for 60000 ms
[    7.135884] RPC:     1 rpcb_getport_async: trying rpcbind version 2
[    7.142197] RPC:       set up xprt to 192.168.0.1 (port 111) via tcp
[    7.148601] RPC:       created transport eddca800 with 65536 slots
[    7.154805] RPC:       creating rpcbind client for 192.168.0.1 (xprt eddca800)
[    7.162115] RPC:       creating UNIX authenticator for client edd8f200
[    7.168679] RPC:       new task initialized, procpid 1
[    7.173835] RPC:       allocated task edd8cd00
[    7.178367] RPC:       rpc_release_client(edd8f200)
[    7.183285] RPC:     2 __rpc_execute flags=0x681
[    7.187919] RPC:     2 call_start rpcbind2 proc GETPORT (async)
[    7.193875] RPC:     2 call_reserve (status 0)
[    7.193893] RPC:     1 sync task going to sleep
[    7.202894] RPC:     2 reserved req edd8f100 xid 926299b2
[    7.208328] RPC:       wake_up_first(eddca900 "xprt_sending")
[    7.214096] RPC:     2 call_reserveresult (status 0)
[    7.219089] RPC:     2 call_refresh (status 0)
[    7.223549] RPC:     2 looking up UNIX cred
[    7.227745] RPC:       looking up UNIX cred
[    7.231958] RPC:       allocating UNIX cred for uid 0 gid 0
[    7.237553] RPC:     2 refreshing UNIX cred edd8cf00
[    7.242799] RPC:     2 call_refreshresult (status 0)
[    7.247782] RPC:     2 call_allocate (status 0)
[    7.252340] RPC:     2 allocated buffer of size 508 at eddcb000
[    7.258296] RPC:     2 call_bind (status 0)
[    7.262494] RPC:     2 call_connect xprt eddca800 is not connected
[    7.268713] RPC:     2 xprt_connect xprt eddca800 is not connected
[    7.274917] RPC:     2 sleep_on(queue "xprt_pending" time 4294938023)
[    7.281392] RPC:     2 added to queue eddca95c "xprt_pending"
[    7.287159] RPC:     2 setting alarm for 60000 ms
[    7.291939] RPC:       xs_connect scheduled xprt eddca800
[    7.297405] RPC:       worker connecting xprt eddca800 via tcp to 192.168.0.1 (port 111)
[    7.305897] RPC:       eddca800 connect status 115 connected 0 sock state 2
[    7.306109] RPC:       xs_tcp_state_change client eddca800...
[    7.306114] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
[    7.306118] RPC:     2 __rpc_wake_up_task (now 4294938026)
[    7.306120] RPC:     2 disabling timer
[    7.306124] RPC:     2 removed from queue eddca95c "xprt_pending"
[    7.306134] RPC:       __rpc_wake_up_task done
[    7.316303] RPC:     2 __rpc_execute flags=0x681
[    7.316306] RPC:     2 xprt_connect_status: retrying
[    7.316310] RPC:     2 call_connect_status (status -11)
[    7.316313] RPC:     2 call_timeout (minor)
[    7.316315] RPC:     2 call_bind (status 0)
[    7.316319] RPC:     2 call_connect xprt eddca800 is connected
[    7.316322] RPC:     2 call_transmit (status 0)
[    7.316324] RPC:     2 xprt_prepare_transmit
[    7.316328] RPC:     2 failed to lock transport eddca800
[    7.316331] RPC:     2 sleep_on(queue "xprt_sending" time 4294938027)
[    7.316334] RPC:     2 added to queue eddca900 "xprt_sending"
[    7.400396] RPC:       wake_up_first(eddca900 "xprt_sending")
[    7.406168] RPC:     2 __rpc_wake_up_task (now 4294938036)
[    7.411684] RPC:     2 removed from queue eddca900 "xprt_sending"
[    7.417800] RPC:       __rpc_wake_up_task done
[    7.422290] RPC:     2 __rpc_execute flags=0x681
[    7.426965] RPC:     2 call_status (status -11)
[    7.431657] RPC:     2 call_transmit (status 0)
[    7.436202] RPC:     2 xprt_prepare_transmit
[    7.440498] RPC:     2 rpc_xdr_encode (status 0)
[    7.445129] RPC:     2 marshaling UNIX cred edd8cf00
[    7.450122] RPC:     2 using AUTH_UNIX cred edd8cf00 to wrap rpc data
[    7.456587] RPC:     2 encoding PMAP_GETPORT call (100005, 3, 6, 0)
[    7.462885] RPC:     2 xprt_transmit(92)
[    7.466841] RPC:       xs_tcp_send_request(92) = 0
[    7.467095] RPC:       xs_tcp_data_ready...
[    7.467130] RPC:       xs_tcp_data_recv started
[    7.467134] RPC:       reading TCP record fragment of length 28
[    7.467136] RPC:       reading XID (4 bytes)
[    7.467138] RPC:       reading request with XID 926299b2
[    7.467140] RPC:       reading CALL/REPLY flag (4 bytes)
[    7.467142] RPC:       read reply XID 926299b2
[    7.467145] RPC:       XID 926299b2 read 20 bytes
[    7.467148] RPC:       xprt = eddca800, tcp_copied = 28, tcp_offset = 28, tcp_reclen = 28
[    7.467151] RPC:     2 xid 926299b2 complete (28 bytes received)
[    7.467154] RPC:       xs_tcp_data_recv done
[    7.528985] RPC:     2 xmit complete
[    7.532571] RPC:       wake_up_first(eddca900 "xprt_sending")
[    7.538348] RPC:     2 call_status (status 28)
[    7.542806] RPC:     2 call_decode (status 28)
[    7.547263] RPC:     2 validating UNIX cred edd8cf00
[    7.552255] RPC:     2 using AUTH_UNIX cred edd8cf00 to unwrap rpc data
[    7.558920] RPC:     2 PMAP_GETPORT result: 41203
[    7.563638] RPC:     2 call_decode result 0
[    7.567834] RPC:       setting port for xprt eddc9000 to 41203
[    7.573698] RPC:     2 rpcb_getport_done(status 0, port 41203)
[    7.579561] RPC:     2 return 0, status 0
[    7.583582] RPC:     2 release task
[    7.587081] RPC:       freeing buffer of size 508 at eddcb000
[    7.592856] RPC:     2 release request edd8f100
[    7.597401] RPC:       wake_up_first(eddca9b8 "xprt_backlog")
[    7.603177] RPC:       rpc_release_client(edd8f200)
[    7.608072] RPC:       destroying rpcbind client for 192.168.0.1
[    7.614135] RPC:       destroying transport eddca800
[    7.619150] RPC:       xs_destroy xprt eddca800
[    7.623695] RPC:       xs_close xprt eddca800
[    7.628078] RPC:       xs_tcp_state_change client eddca800...
[    7.633856] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
[    7.640180] RPC:       xs_tcp_state_change client eddca800...
[    7.645947] RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
[    7.652265] RPC:       xs_tcp_state_change client eddca800...
[    7.658031] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[    7.664329] RPC:       disconnected transport eddca800
[    7.669493] RPC:       xs_tcp_state_change client eddca800...
[    7.675259] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[    7.681556] RPC:       disconnected transport eddca800
[    7.686711] RPC:       xs_tcp_data_ready...
[    7.690938] RPC:       disconnected transport eddca800
[    7.696099] RPC:     1 __rpc_wake_up_task (now 4294938065)
[    7.701613] RPC:     1 disabling timer
[    7.705374] RPC:     1 removed from queue eddc90a4 "xprt_binding"
[    7.711499] RPC:       __rpc_wake_up_task done

[GS] In good case "RPC:     2 freeing task" can be seen here

[    7.711506] RPC:     1 sync task resuming
[    7.711510] RPC:     1 call_bind_status (status 0)
[    7.711512] RPC:     1 call_connect xprt eddc9000 is not connected
[    7.711515] RPC:     1 xprt_connect xprt eddc9000 is not connected
[    7.711519] RPC:     1 sleep_on(queue "xprt_pending" time 4294938067)
[    7.711521] RPC:     1 added to queue eddc915c "xprt_pending"
[    7.711523] RPC:     1 setting alarm for 60000 ms
[    7.711527] RPC:       xs_connect scheduled xprt eddc9000
[    7.711534] RPC:     1 sync task going to sleep
[    7.711557] RPC:       xs_bind 0.0.0.0:872: ok (0)
[    7.711560] RPC:       worker connecting xprt eddc9000 via tcp to 192.168.0.1 (port 41203)
[    7.711604] RPC:       eddc9000 connect status 115 connected 0 sock state 2
[    7.711607] RPC:       wake_up_first(eddc9100 "xprt_sending")
[    7.711733] RPC:       xs_tcp_state_change client eddc9000...
[    7.711737] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
[    7.711740] RPC:     1 __rpc_wake_up_task (now 4294938067)
[    7.711741] RPC:     1 disabling timer
[    7.711744] RPC:     1 removed from queue eddc915c "xprt_pending"
[    7.711750] RPC:       __rpc_wake_up_task done
[    7.711790] RPC:     1 sync task resuming
[    7.711793] RPC:     1 xprt_connect_status: retrying
[    7.711796] RPC:     1 call_connect_status (status -11)
[    7.711797] RPC:     1 call_timeout (minor)
[    7.711799] RPC:     1 call_bind (status 0)
[    7.711802] RPC:     1 call_connect xprt eddc9000 is connected
[    7.711803] RPC:     1 call_transmit (status 0)
[    7.711805] RPC:     1 xprt_prepare_transmit
[    7.711808] RPC:     1 rpc_xdr_encode (status 0)

[GS] =OR= In good case "RPC:     2 freeing task" can be seen here

[    7.711809] RPC:     1 marshaling NULL cred c096c2f0
[    7.711812] RPC:     1 using AUTH_NULL cred c096c2f0 to wrap rpc data
[    7.711814] RPC:     1 xprt_transmit(44)
[    7.711839] RPC:       xs_tcp_send_request(44) = 0
[    7.711841] RPC:     1 xmit complete
[    7.711844] RPC:     1 sleep_on(queue "xprt_pending" time 4294938067)
[    7.711846] RPC:     1 added to queue eddc915c "xprt_pending"
[    7.711848] RPC:     1 setting alarm for 60000 ms
[    7.711852] RPC:       wake_up_first(eddc9100 "xprt_sending")
[    7.711855] RPC:     1 sync task going to sleep
[    7.712063] RPC:       xs_tcp_data_ready...
[    7.712091] RPC:       xs_tcp_data_recv started
[    7.712094] RPC:       reading TCP record fragment of length 24
[    7.712096] RPC:       reading XID (4 bytes)
[    7.712098] RPC:       reading request with XID 57c6e885
[    7.712101] RPC:       reading CALL/REPLY flag (4 bytes)
[    7.712102] RPC:       read reply XID 57c6e885
[    7.712105] RPC:       XID 57c6e885 read 16 bytes
[    7.712107] RPC:       xprt = eddc9000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
[    7.712110] RPC:     1 xid 57c6e885 complete (24 bytes received)
[    7.712113] RPC:     1 __rpc_wake_up_task (now 4294938067)
[    7.712114] RPC:     1 disabling timer
[    7.712117] RPC:     1 removed from queue eddc915c "xprt_pending"
[    7.712123] RPC:       __rpc_wake_up_task done
[    7.712129] RPC:     1 sync task resuming
[    7.712131] RPC:     1 call_status (status 24)
[    7.712134] RPC:     1 call_decode (status 24)
[    7.712136] RPC:     1 validating NULL cred c096c2f0
[    7.712140] RPC:     1 using AUTH_NULL cred c096c2f0 to unwrap rpc data
[    7.712141] RPC:     1 call_decode result 0
[    7.712144] RPC:     1 return 0, status 0
[    7.712145] RPC:     1 release task
[    7.712150] RPC:       freeing buffer of size 92 at eddc9800
[    7.712153] RPC:     1 release request ee8eac00
[    7.712154] RPC:       wake_up_first(eddc91b8 "xprt_backlog")
[    7.712157] RPC:       rpc_release_client(ee8ead00)
[    7.712160] RPC:     1 freeing task
[    7.712164] RPC:       new task initialized, procpid 1
[    7.712166] RPC:       allocated task ee257300
[    7.712169] RPC:     3 __rpc_execute flags=0x1280
[    7.712171] RPC:     3 call_start mount3 proc MOUNT (sync)
[    7.712173] RPC:     3 call_reserve (status 0)
[    7.712176] RPC:     3 reserved req ee8eac00 xid 58c6e885
[    7.712179] RPC:       wake_up_first(eddc9100 "xprt_sending")
[    7.712182] RPC:     3 call_reserveresult (status 0)
[    7.712184] RPC:     3 call_refresh (status 0)
[    7.712186] RPC:     3 looking up UNIX cred
[    7.712188] RPC:       looking up UNIX cred
[    7.712191] RPC:     3 refreshing UNIX cred edd8cf00
[    7.712193] RPC:     3 call_refreshresult (status 0)
[    7.712195] RPC:     3 call_allocate (status 0)
[    7.712198] RPC:     3 allocated buffer of size 1604 at eeb5f000
[    7.712200] RPC:     3 call_bind (status 0)
[    7.712202] RPC:     3 call_connect xprt eddc9000 is connected
[    7.712204] RPC:     3 call_transmit (status 0)
[    7.712205] RPC:     3 xprt_prepare_transmit
[    7.712208] RPC:     3 rpc_xdr_encode (status 0)
[    7.712209] RPC:     3 marshaling UNIX cred edd8cf00
[    7.712212] RPC:     3 using AUTH_UNIX cred edd8cf00 to wrap rpc data
[    7.712215] RPC:     3 xprt_transmit(168)
[    7.712222] RPC:       xs_tcp_data_recv done
[    7.712257] RPC:       xs_tcp_send_request(168) = 0
[    7.712259] RPC:     3 xmit complete
[    7.712262] RPC:     3 sleep_on(queue "xprt_pending" time 4294938067)
[    7.712264] RPC:     3 added to queue eddc915c "xprt_pending"
[    7.712266] RPC:     3 setting alarm for 60000 ms
[    7.712269] RPC:       wake_up_first(eddc9100 "xprt_sending")
[    7.712273] RPC:     3 sync task going to sleep
[    7.721103] RPC:       xs_tcp_data_ready...
[    7.721123] RPC:       xs_tcp_data_recv started
[    7.721126] RPC:       reading TCP record fragment of length 76
[    7.721127] RPC:       reading XID (4 bytes)
[    7.721129] RPC:       reading reply for XID 58c6e885
[    7.721131] RPC:       reading CALL/REPLY flag (4 bytes)
[    7.721133] RPC:       read reply XID 58c6e885
[    7.721136] RPC:       XID 58c6e885 read 68 bytes
[    7.721139] RPC:       xprt = eddc9000, tcp_copied = 76, tcp_offset = 76, tcp_reclen = 76
[    7.721141] RPC:     3 xid 58c6e885 complete (76 bytes received)
[    7.721144] RPC:     3 __rpc_wake_up_task (now 4294938068)
[    7.721145] RPC:     3 disabling timer
[    7.721147] RPC:     3 removed from queue eddc915c "xprt_pending"
[    7.721154] RPC:       __rpc_wake_up_task done
[    7.721159] RPC:     3 sync task resuming
[    7.721162] RPC:     3 call_status (status 76)
[    7.721164] RPC:     3 call_decode (status 76)
[    7.721166] RPC:     3 validating UNIX cred edd8cf00
[    7.721169] RPC:     3 using AUTH_UNIX cred edd8cf00 to unwrap rpc data
[    7.721171] NFS: received 1 auth flavors
[    7.721173] NFS:   auth flavor[0]: 1
[    7.721175] RPC:     3 call_decode result 0
[    7.721177] RPC:     3 return 0, status 0
[    7.721178] RPC:     3 release task
[    7.721182] RPC:       freeing buffer of size 1604 at eeb5f000
[    7.721186] RPC:     3 release request ee8eac00
[    7.721188] RPC:       wake_up_first(eddc91b8 "xprt_backlog")
[    7.721191] RPC:       rpc_release_client(ee8ead00)
[    7.721194] RPC:     3 freeing task
[    7.721197] RPC:       shutting down mount client for 192.168.0.1
[    7.721198] RPC:       rpc_release_client(ee8ead00)
[    7.721200] RPC:       destroying UNIX authenticator c096c324
[    7.721205] RPC:       destroying mount client for 192.168.0.1
[    7.721238] NFS: MNT request succeeded
[    7.721241] NFS: attempting to use auth flavor 1
[    7.721257] --> nfs_init_server()
[    7.721260] --> nfs_get_client(192.168.0.1,v3)
[    7.721264] RPC:       looking up machine cred for service *
[    7.721269] RPC:       allocated machine cred ee257300 for uid 0 gid 0
[    7.721279] RPC:       set up xprt to 192.168.0.1 (autobind) via tcp
[    7.721296] RPC:       created transport eeb5f800 with 65536 slots
[    7.721299] RPC:       creating nfs client for 192.168.0.1 (xprt eeb5f800)
[    7.721333] RPC:       creating UNIX authenticator for client ee24f600
[    7.721336] RPC:       new task initialized, procpid 1
[    7.721338] RPC:       allocated task ee257380
[    7.721341] RPC:     4 __rpc_execute flags=0x680
[    7.721344] RPC:     4 call_start nfs3 proc NULL (sync)
[    7.721347] RPC:     4 call_reserve (status 0)
[    7.721350] RPC:     4 reserved req ee24f500 xid 799833c3
[    7.721353] RPC:       wake_up_first(eeb5f900 "xprt_sending")
[    7.721356] RPC:     4 call_reserveresult (status 0)
[    7.721357] RPC:     4 call_refresh (status 0)
[    7.721360] RPC:     4 holding NULL cred c096c2f0
[    7.721362] RPC:     4 refreshing NULL cred c096c2f0
[    7.721364] RPC:     4 call_refreshresult (status 0)
[    7.721367] RPC:     4 call_allocate (status 0)
[    7.721369] RPC:     4 allocated buffer of size 92 at ee2ac800
[    7.721371] RPC:     4 call_bind (status 0)
[    7.721374] RPC:     4 rpcb_getport_async(192.168.0.1, 100003, 3, 6)
[    7.721376] RPC:     4 sleep_on(queue "xprt_binding" time 4294938068)
[    7.721378] RPC:     4 added to queue eeb5f8a4 "xprt_binding"
[    7.721380] RPC:     4 setting alarm for 60000 ms
[    7.721385] RPC:     4 rpcb_getport_async: trying rpcbind version 2
[    7.721393] RPC:       set up xprt to 192.168.0.1 (port 111) via tcp
[    7.721407] RPC:       created transport ee2ac000 with 65536 slots
[    7.721409] RPC:       creating rpcbind client for 192.168.0.1 (xprt ee2ac000)
[    7.721432] RPC:       creating UNIX authenticator for client ee24f900
[    7.721435] RPC:       new task initialized, procpid 1
[    7.721437] RPC:       allocated task ee257480
[    7.721440] RPC:       rpc_release_client(ee24f900)
[    7.721442] RPC:     4 sync task going to sleep
[    7.721450] RPC:       xs_tcp_data_recv done
[    7.721458] RPC:     5 __rpc_execute flags=0x681
[    7.721460] RPC:     5 call_start rpcbind2 proc GETPORT (async)
[    7.721462] RPC:     5 call_reserve (status 0)
[    7.721465] RPC:     5 reserved req ee24f800 xid 9916d160
[    7.721468] RPC:       wake_up_first(ee2ac100 "xprt_sending")
[    7.721471] RPC:     5 call_reserveresult (status 0)
[    7.721473] RPC:     5 call_refresh (status 0)
[    7.721474] RPC:     5 looking up UNIX cred
[    7.721476] RPC:       looking up UNIX cred
[    7.721478] RPC:       allocating UNIX cred for uid 0 gid 0
[    7.721480] RPC:     5 refreshing UNIX cred ee257500
[    7.721482] RPC:     5 call_refreshresult (status 0)
[    7.721485] RPC:     5 call_allocate (status 0)
[    7.721487] RPC:     5 allocated buffer of size 508 at ee2ad800
[    7.721489] RPC:     5 call_bind (status 0)
[    7.721491] RPC:     5 call_connect xprt ee2ac000 is not connected
[    7.721493] RPC:     5 xprt_connect xprt ee2ac000 is not connected
[    7.721497] RPC:     5 sleep_on(queue "xprt_pending" time 4294938068)
[    7.721498] RPC:     5 added to queue ee2ac15c "xprt_pending"
[    7.721500] RPC:     5 setting alarm for 60000 ms
[    7.721504] RPC:       xs_connect scheduled xprt ee2ac000
[    7.721514] RPC:       worker connecting xprt ee2ac000 via tcp to 192.168.0.1 (port 111)
[    7.721555] RPC:       ee2ac000 connect status 115 connected 0 sock state 2
[    7.721558] RPC:       wake_up_first(ee2ac100 "xprt_sending")
[    7.721687] RPC:       xs_tcp_state_change client ee2ac000...
[    7.721690] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
[    7.721693] RPC:     5 __rpc_wake_up_task (now 4294938068)
[    7.721695] RPC:     5 disabling timer
[    7.721697] RPC:     5 removed from queue ee2ac15c "xprt_pending"
[    7.721703] RPC:       __rpc_wake_up_task done
[    7.721744] RPC:     5 __rpc_execute flags=0x681
[    7.721746] RPC:     5 xprt_connect_status: retrying
[    7.721748] RPC:     5 call_connect_status (status -11)
[    7.721750] RPC:     5 call_timeout (minor)
[    7.721752] RPC:     5 call_bind (status 0)
[    7.721755] RPC:     5 call_connect xprt ee2ac000 is connected
[    7.721756] RPC:     5 call_transmit (status 0)
[    7.721758] RPC:     5 xprt_prepare_transmit
[    7.721760] RPC:     5 rpc_xdr_encode (status 0)
[    7.721762] RPC:     5 marshaling UNIX cred ee257500
[    7.721765] RPC:     5 using AUTH_UNIX cred ee257500 to wrap rpc data
[    7.721768] RPC:     5 encoding PMAP_GETPORT call (100003, 3, 6, 0)
[    7.721769] RPC:     5 xprt_transmit(92)
[    7.721796] RPC:       xs_tcp_send_request(92) = 0
[    7.721798] RPC:     5 xmit complete
[    7.721800] RPC:     5 sleep_on(queue "xprt_pending" time 4294938068)
[    7.721803] RPC:     5 added to queue ee2ac15c "xprt_pending"
[    7.721805] RPC:     5 setting alarm for 60000 ms
[    7.721808] RPC:       wake_up_first(ee2ac100 "xprt_sending")
[    7.722037] RPC:       xs_tcp_data_ready...
[    7.722066] RPC:       xs_tcp_data_recv started
[    7.722069] RPC:       reading TCP record fragment of length 28
[    7.722071] RPC:       reading XID (4 bytes)
[    7.722073] RPC:       reading request with XID 9916d160
[    7.722075] RPC:       reading CALL/REPLY flag (4 bytes)
[    7.722076] RPC:       read reply XID 9916d160
[    7.722079] RPC:       XID 9916d160 read 20 bytes
[    7.722082] RPC:       xprt = ee2ac000, tcp_copied = 28, tcp_offset = 28, tcp_reclen = 28
[    7.722084] RPC:     5 xid 9916d160 complete (28 bytes received)
[    7.722087] RPC:     5 __rpc_wake_up_task (now 4294938068)
[    7.722088] RPC:     5 disabling timer
[    7.722091] RPC:     5 removed from queue ee2ac15c "xprt_pending"
[    7.722093] RPC:       __rpc_wake_up_task done
[    7.722095] RPC:       xs_tcp_data_recv done
[    7.722101] RPC:     5 __rpc_execute flags=0xe81
[    7.722103] RPC:     5 call_status (status 28)
[    7.722105] RPC:     5 call_decode (status 28)
[    7.722108] RPC:     5 validating UNIX cred ee257500
[    7.722110] RPC:     5 using AUTH_UNIX cred ee257500 to unwrap rpc data
[    7.722112] RPC:     5 PMAP_GETPORT result: 2049
[    7.722114] RPC:     5 call_decode result 0
[    7.722116] RPC:       setting port for xprt eeb5f800 to 2049
[    7.722120] RPC:     5 rpcb_getport_done(status 0, port 2049)
[    7.722122] RPC:     5 return 0, status 0
[    7.722123] RPC:     5 release task
[    7.722128] RPC:       freeing buffer of size 508 at ee2ad800
[    7.722131] RPC:     5 release request ee24f800
[    7.722132] RPC:       wake_up_first(ee2ac1b8 "xprt_backlog")
[    7.722135] RPC:       rpc_release_client(ee24f900)
[    7.722138] RPC:       destroying rpcbind client for 192.168.0.1
[    7.722165] RPC:       destroying transport ee2ac000
[    7.722185] RPC:       xs_destroy xprt ee2ac000
[    7.722188] RPC:       xs_close xprt ee2ac000
[    7.722212] RPC:       xs_tcp_state_change client ee2ac000...
[    7.722215] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
[    7.722225] RPC:       disconnected transport ee2ac000
[    7.722232] RPC:     4 __rpc_wake_up_task (now 4294938068)
[    7.722234] RPC:     4 disabling timer
[    7.722236] RPC:     4 removed from queue eeb5f8a4 "xprt_binding"
[    7.722243] RPC:       __rpc_wake_up_task done
[    7.722249] RPC:     4 sync task resuming
[    7.722251] RPC:     4 call_bind_status (status 0)
[    7.722253] RPC:     4 call_connect xprt eeb5f800 is not connected
[    7.722255] RPC:     4 xprt_connect xprt eeb5f800 is not connected
[    7.722258] RPC:     4 sleep_on(queue "xprt_pending" time 4294938068)
[    7.722261] RPC:     4 added to queue eeb5f95c "xprt_pending"
[    7.722263] RPC:     4 setting alarm for 60000 ms
[    7.722266] RPC:       xs_connect scheduled xprt eeb5f800
[    7.722270] RPC:     4 sync task going to sleep
[    7.722276] RPC:     5 freeing task
[    7.722289] RPC:       xs_bind 0.0.0.0:936: ok (0)
[    7.722292] RPC:       worker connecting xprt eeb5f800 via tcp to 192.168.0.1 (port 2049)
[    7.722371] RPC:       eeb5f800 connect status 115 connected 0 sock state 2
[    7.722379] RPC:       wake_up_first(eeb5f900 "xprt_sending")
[    8.988298] omap_i2c 48070000.i2c: controller timed out
[    9.128222] RPC:       destroying transport eddc9000
[    9.133237] RPC:       xs_destroy xprt eddc9000
[    9.137782] RPC:       xs_close xprt eddc9000
[    9.142179] RPC:       xs_tcp_state_change client eddc9000...
[    9.147945] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
[    9.148286] RPC:       unx_free_cred edd8cf00
[    9.158642] RPC:       xs_tcp_state_change client eddc9000...
[    9.164411] RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
[    9.170724] RPC:       xs_tcp_state_change client eddc9000...
[    9.176489] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[    9.182789] RPC:       disconnected transport eddc9000
[    9.187944] RPC:       xs_tcp_state_change client eddc9000...
[    9.193719] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[    9.200016] RPC:       disconnected transport eddc9000
[    9.205170] RPC:       xs_tcp_data_ready...
[    9.209402] RPC:       disconnected transport eddc9000
[    9.214586] RPC:     2 freeing task

[GS] This is failed sequence ^^^^^


[   62.749957] random: nonblocking pool is initialized
[   67.838287] RPC:     4 timeout
[   67.841361] RPC:     4 __rpc_wake_up_task (now 4294944080)
[   67.846868] RPC:     4 disabling timer
[   67.850647] RPC:     4 removed from queue eeb5f95c "xprt_pending"
[   67.856775] RPC:       __rpc_wake_up_task done
[   67.861262] RPC:     4 sync task resuming
[   67.865286] RPC:     4 xprt_connect_status: connect attempt timed out
[   67.871787] RPC:     4 call_connect_status (status -110)
[   67.877124] RPC:     4 call_timeout (minor)
[   67.881339] RPC:     4 call_bind (status 0)
[   67.885543] RPC:     4 call_connect xprt eeb5f800 is not connected
[   67.891766] RPC:     4 xprt_connect xprt eeb5f800 is not connected
[   67.897973] RPC:     4 sleep_on(queue "xprt_pending" time 4294944085)
[   67.904456] RPC:     4 added to queue eeb5f95c "xprt_pending"
[   67.910241] RPC:     4 setting alarm for 120000 ms
[   67.915055] RPC:     4 sync task going to sleep
[  135.038293] RPC:       xs_error_report client eeb5f800, error=110...
[  135.044676] RPC:     4 __rpc_wake_up_task (now 4294950800)
[  135.050188] RPC:     4 disabling timer
[  135.053957] RPC:     4 removed from queue eeb5f95c "xprt_pending"
[  135.060079] RPC:       __rpc_wake_up_task done
[  135.064542] RPC:       xs_tcp_state_change client eeb5f800...
[  135.070317] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[  135.076609] RPC:       disconnected transport eeb5f800
[  135.081790] RPC:     4 sync task resuming
[  135.085819] RPC:     4 xprt_connect_status: connect attempt timed out
[  135.092334] RPC:     4 call_connect_status (status -110)
[  135.097667] RPC:     4 call_timeout (minor)
[  135.101888] RPC:     4 call_bind (status 0)
[  135.106087] RPC:     4 call_connect xprt eeb5f800 is not connected
[  135.112305] RPC:     4 xprt_connect xprt eeb5f800 is not connected
[  135.118531] RPC:     4 sleep_on(queue "xprt_pending" time 4294950808)
[  135.125002] RPC:     4 added to queue eeb5f95c "xprt_pending"
[  135.130786] RPC:     4 setting alarm for 180000 ms
[  135.135604] RPC:       xs_connect delayed xprt eeb5f800 for 3 seconds
[  135.142083] RPC:       xs_tcp_state_change client eeb5f800...
[  135.147852] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[  135.154159] RPC:       disconnected transport eeb5f800
[  135.159328] RPC:     4 __rpc_wake_up_task (now 4294950812)
[  135.164833] RPC:     4 disabling timer
[  135.168614] RPC:     4 removed from queue eeb5f95c "xprt_pending"
[  135.174730] RPC:       __rpc_wake_up_task done
[  135.179231] RPC:     4 xprt_connect_status: retrying
[  135.184221] RPC:     4 call_connect_status (status -11)
[  135.189510] RPC:     4 call_timeout (minor)
[  135.193709] RPC:     4 call_bind (status 0)
[  135.197908] RPC:     4 call_connect xprt eeb5f800 is not connected
[  135.204158] RPC:     4 xprt_connect xprt eeb5f800 is not connected
[  135.210443] RPC:     4 failed to lock transport eeb5f800
[  135.215785] RPC:     4 sleep_on(queue "xprt_sending" time 4294950817)
[  135.222280] RPC:     4 added to queue eeb5f900 "xprt_sending"
[  135.228065] RPC:     4 sync task going to sleep
[  138.188320] RPC:       xs_bind 0.0.0.0:936: ok (0)
[  138.193139] RPC:       worker connecting xprt eeb5f800 via tcp to 192.168.0.1 (port 2049)
[  138.201418] RPC:       eeb5f800 connect status 115 connected 0 sock state 2
[  138.208433] RPC:       wake_up_first(eeb5f900 "xprt_sending")
[  138.214202] RPC:     4 __rpc_wake_up_task (now 4294951117)
[  138.219723] RPC:     4 removed from queue eeb5f900 "xprt_sending"
[  138.225851] RPC:       __rpc_wake_up_task done
[  138.230344] RPC:     4 sync task resuming
[  138.234369] RPC:     4 call_connect_status (status -11)
[  138.239664] RPC:     4 call_timeout (minor)
[  138.243870] RPC:     4 call_bind (status 0)
[  138.248070] RPC:     4 call_connect xprt eeb5f800 is not connected
[  138.254295] RPC:     4 xprt_connect xprt eeb5f800 is not connected
[  138.260520] RPC:     4 sleep_on(queue "xprt_pending" time 4294951122)
[  138.266987] RPC:     4 added to queue eeb5f95c "xprt_pending"
[  138.272772] RPC:     4 setting alarm for 180000 ms
[  138.277588] RPC:     4 sync task going to sleep

- 12:26:16 [INFO] Boot attempt 1/1 failed
- 12:26:16 [INFO] Collecting kernel traces via sysrq...
- 12:26:27 [INFO] [  208.203437] sysrq: SysRq : Show State
[  208.207123]   task                PC stack   pid father
[  208.212370] swapper/0       D c0660fe0     0     1      0 0x00000000
[  208.218765] Backtrace: 
[  208.221239] [<c0660cfc>] (__schedule) from [<c06613c0>] (schedule+0x54/0xc4)
[  208.228316]  r10:ee318e00 r9:fffffe00 r8:c063b54c r7:eeda1db4 r6:ee88da34 r5:00000082
[  208.236216]  r4:ee88c000
[  208.238772] [<c066136c>] (schedule) from [<c063b57c>] (rpc_wait_bit_killable+0x30/0xe4)
[  208.246808]  r5:00000082 r4:00000082
[  208.250416] [<c063b54c>] (rpc_wait_bit_killable) from [<c066195c>] (__wait_on_bit+0x8c/0xcc)
[  208.258886]  r5:00000082 r4:ee88da28
[  208.262492] [<c06618d0>] (__wait_on_bit) from [<c0661a10>] (out_of_line_wait_on_bit+0x74/0x7c)
[  208.271137]  r9:fffffe00 r8:00000000 r7:ee2573b8 r6:00000001 r5:ee890000 r4:00000000
[  208.278952] [<c066199c>] (out_of_line_wait_on_bit) from [<c063c4a0>] (__rpc_execute+0x20c/0x394)
[  208.287772]  r7:ee2573b8 r6:c096c8f4 r5:eeb5f95c r4:ee257380
[  208.293487] [<c063c294>] (__rpc_execute) from [<c063c950>] (rpc_execute+0x6c/0x70)
[  208.301085]  r9:c067b694 r8:ee2a0910 r7:c0965a40 r6:c0965a40 r5:00000000 r4:ee257380
[  208.308902] [<c063c8e4>] (rpc_execute) from [<c0634bb0>] (rpc_run_task+0xac/0xb4)
[  208.316413]  r5:ee88dad4 r4:ee257380
[  208.320017] [<c0634b04>] (rpc_run_task) from [<c0634c00>] (rpc_call_sync+0x48/0xc4)
[  208.327702]  r5:ee88dbc4 r4:ee24f600
[  208.331307] [<c0634bb8>] (rpc_call_sync) from [<c0634cd8>] (rpc_ping+0x5c/0x78)
[  208.338644]  r4:ee24f600
[  208.341194] [<c0634c7c>] (rpc_ping) from [<c0634dac>] (rpc_create_xprt+0xb8/0xd0)
[  208.348705]  r4:ee24f600
[  208.351254] [<c0634cf4>] (rpc_create_xprt) from [<c0634e78>] (rpc_create+0xb4/0x1c4)
[  208.359028]  r7:c0965a40 r6:c0965a40 r5:00000000 r4:ee88dbc4
[  208.364743] [<c0634dc4>] (rpc_create) from [<c01e1abc>] (nfs_create_rpc_client+0xdc/0x12c)
[  208.373039]  r6:ee88dc94 r5:00000001 r4:ee318e00
[  208.377698] [<c01e19e0>] (nfs_create_rpc_client) from [<c01e2778>] (nfs_init_client+0x3c/0xd8)
[  208.386343]  r6:eeafefec r5:ee88dca8 r4:ee318e00
[  208.391002] [<c01e273c>] (nfs_init_client) from [<c01e1840>] (nfs_get_client+0x254/0x3c4)
[  208.399209]  r5:ee88dca8 r4:eeafef18
[  208.402813] [<c01e15ec>] (nfs_get_client) from [<c01e2994>] (nfs_create_server+0xbc/0x4cc)
[  208.411109]  r10:c09313d4 r9:ee88ddc4 r8:ee24dcc0 r7:ee88dca8 r6:c096c8f0 r5:eeb5f000
[  208.419006]  r4:ee2a0800
[  208.421559] [<c01e28d8>] (nfs_create_server) from [<c01fa574>] (nfs3_create_server+0x10/0x28)
[  208.430117]  r10:00000001 r9:edd8ca80 r8:c09313d4 r7:c096c8f0 r6:ee88ddc4 r5:00000000
[  208.438016]  r4:ee2a0800
[  208.440568] [<c01fa564>] (nfs3_create_server) from [<c01ee8a8>] (nfs_try_mount+0xe4/0x340)
[  208.448865]  r5:00000000 r4:ee2a0800
[  208.452474] [<c01ee7c4>] (nfs_try_mount) from [<c01ee14c>] (nfs_fs_mount+0x624/0xb78)
[  208.460333]  r10:00000400 r9:00008000 r8:edd8ca8c r7:edd8ca80 r6:c096c8f0 r5:c01ee7c4
[  208.468232]  r4:c09313d4
[  208.470787] [<c01edb28>] (nfs_fs_mount) from [<c0120a90>] (mount_fs+0x1c/0xac)
[  208.478037]  r10:c0930e40 r9:c0928c94 r8:c0930e40 r7:c0930e40 r6:00008000 r5:edd8ca80
[  208.485936]  r4:c01edb28
[  208.488490] [<c0120a74>] (mount_fs) from [<c0139acc>] (vfs_kern_mount+0x50/0xf8)
[  208.495914]  r8:edd8e000 r7:c0930e40 r6:00008000 r5:edd8ca80 r4:edd71900
[  208.502681] [<c0139a7c>] (vfs_kern_mount) from [<c013cbb4>] (do_mount+0x1a8/0xc20)
[  208.510278]  r9:c0928c94 r8:edd68c40 r7:edd8ca80 r6:00008000 r5:00000020 r4:edd8e000
[  208.518094] [<c013ca0c>] (do_mount) from [<c013d9a0>] (SyS_mount+0x7c/0xa8)
[  208.525081]  r10:c090283c r9:c08c25ec r8:00008000 r7:c07eff78 r6:00000000 r5:edd8ca80
[  208.532979]  r4:edd68c40
[  208.535532] [<c013d924>] (SyS_mount) from [<c08c3494>] (mount_root+0x70/0x12c)
[  208.542781]  r8:c091071c r7:00000006 r6:00000005 r5:c091b888 r4:c0972024
[  208.549549] [<c08c3424>] (mount_root) from [<c08c36b0>] (prepare_namespace+0x160/0x1a4)
[  208.557584]  r7:c0972000 r6:c0972000 r5:c0902871 r4:c0972024
[  208.563297] [<c08c3550>] (prepare_namespace) from [<c08c2fdc>] (kernel_init_freeable+0x274/0x284)
[  208.572203]  r5:c0902838 r4:00000008
[  208.575811] [<c08c2d68>] (kernel_init_freeable) from [<c0660444>] (kernel_init+0x18/0xf0)
[  208.584019]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c066042c
[  208.591918]  r4:c0972000
[  208.594472] [<c066042c>] (kernel_init) from [<c000fa88>] (ret_from_fork+0x14/0x2c)
[  208.602070]  r5:c066042c r4:00000000

-- 
regards,
-grygorii
