From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel Panic - 3.4.86 - during modprobe of mellanox driver
Date: Fri, 18 Apr 2014 10:23:50 -0700
Message-ID: <CAM_iQpVn=fgw7+Cio_SzkQR1OCzbtZzVvae-WpMKbJ63fqvM5A@mail.gmail.com>
References: <636295BFF4A001418A00F46569A2CD2B28B41A77@US-PLNO-EXM01-P.global.tektronix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Rich, Jason" <jason.rich@tekcomms.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <636295BFF4A001418A00F46569A2CD2B28B41A77@US-PLNO-EXM01-P.global.tektronix.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Please Cc netdev@ for networking bugs...)

On Thu, Apr 17, 2014 at 3:05 PM, Rich, Jason <jason.rich@tekcomms.com> wrote:
> Greetings,
> Before we begin, please CC me directly when responding, thanks.
>
> I've recently upgraded my distribution to build the latest mellanox ConnectX(r)-3 EN Single/Dual-Port 10/40/56GbE driver.  Specifically, driver 2.1 (mlnx-en-2.1-1.0.0.tgz).
> I have it building the module just fine, but anytime the system attempts to auto load the driver (via udev detection, adding to /etc/modules explictly, a sysV5 startup script, or an explicit modprobe within my initramfs), the kernel always panics.  It is of note that if I blacklist the driver from udev and then manually execute a 'modprobe mlx4_core' no crash occurs.
> Before getting into more depth, I would also mention that Mellanox has explicitly told me they will not support 3.4.  While I don't expect you guys to debug their driver, I'd love some insight into this for I've been trouble shooting this for a few weeks now and have run out of ideas.
>
> Key things to note:
> 1) I'm running a debian 6 distribution with an upgraded kernel @ 3.4.26 (although I have just upgraded it to 3.4.86 in attempts to solve this issue).
> 2) The Mellanox linux driver consists of three separate kernel modules.  Compat.ko, mlx4_core and mlx4_en.  All of these modules are built from source directly from their driver tarball.
> 3) It looks like if I load the mlx4_core manually it sucks in mlx4_en automatically even though modinfo shows the dependency is the other way around (mlx4_en requires mlx4_core).
> 4) I keep seeing module unload right after init....this seems strange....race condition of some kind?
> 4) As I was writing this email, I discovered if I load up 'core' first and then the 'en' after - I no longer had a kernel panic.   I have always felt there was a deadlock going on, but I also noticed it looked like memory was getting stepped on during my debugging efforts.
>
> I feel pretty confident my issue is with this driver now that I know key point number 4 (above), but a little insight as what you guys suggest I do next would be greatly appreciated.
> Lsmod, cpuinfo, kernel dump are all below:
>
> First the panic (the "JRich" printks are mine.  All other source is untouched):
> [    9.748063] Compat-mlnx-ofed backport release: feee0c2
> [    9.754083] Backport based on /mswg/git/mlnx_ofed/mlnx-ofed-2.x-kernel.git feee0c2
> [    9.761703] compat.git: /mswg/git/mlnx_ofed/mlnx-ofed-2.x-kernel.git
> [    9.771301] JRich - __init mlx4_init - mlx4_verify_params
> [    9.776752] JRich - __init mlx4_init - mlx4_catas_init
> [    9.781982] JRich - __init mlx4_init - WQ address is: ffff881ffc73ecc0
> [    9.788574] mlx4_core: Mellanox ConnectX core driver v1.1 (Apr 17 2014)
> [    9.795234] mlx4_core: Initializing 0000:04:00.0
> [   15.517225] mlx4_core 0000:04:00.0: irq 158 for MSI/MSI-X
> [   15.522669] mlx4_core 0000:04:00.0: irq 159 for MSI/MSI-X
> [   15.528109] mlx4_core 0000:04:00.0: irq 160 for MSI/MSI-X
> [   15.533546] mlx4_core 0000:04:00.0: irq 161 for MSI/MSI-X
> [   15.538990] mlx4_core 0000:04:00.0: irq 162 for MSI/MSI-X
> [   15.544434] mlx4_core 0000:04:00.0: irq 163 for MSI/MSI-X
> [   15.549874] mlx4_core 0000:04:00.0: irq 164 for MSI/MSI-X
> [   15.555310] mlx4_core 0000:04:00.0: irq 165 for MSI/MSI-X
> [   15.560753] mlx4_core 0000:04:00.0: irq 166 for MSI/MSI-X
> [   15.566196] mlx4_core 0000:04:00.0: irq 167 for MSI/MSI-X
> [   15.571633] mlx4_core 0000:04:00.0: irq 168 for MSI/MSI-X
> [   15.577071] mlx4_core 0000:04:00.0: irq 169 for MSI/MSI-X
> [   15.582509] mlx4_core 0000:04:00.0: irq 170 for MSI/MSI-X
> [   15.587955] mlx4_core 0000:04:00.0: irq 171 for MSI/MSI-X
> [   15.593396] mlx4_core 0000:04:00.0: irq 172 for MSI/MSI-X
> [   15.598840] mlx4_core 0000:04:00.0: irq 173 for MSI/MSI-X
> [   15.604281] mlx4_core 0000:04:00.0: irq 174 for MSI/MSI-X
> [   15.609723] mlx4_core 0000:04:00.0: irq 175 for MSI/MSI-X
> [   15.615166] mlx4_core 0000:04:00.0: irq 176 for MSI/MSI-X
> [   15.620610] mlx4_core 0000:04:00.0: irq 177 for MSI/MSI-X
> [   15.626050] mlx4_core 0000:04:00.0: irq 178 for MSI/MSI-X
> [   15.631495] mlx4_core 0000:04:00.0: irq 179 for MSI/MSI-X
> [   15.636944] mlx4_core 0000:04:00.0: irq 180 for MSI/MSI-X
> [   15.642386] mlx4_core 0000:04:00.0: irq 181 for MSI/MSI-X
> [   15.647828] mlx4_core 0000:04:00.0: irq 182 for MSI/MSI-X
> [   15.653267] mlx4_core 0000:04:00.0: irq 183 for MSI/MSI-X
> [   15.658708] mlx4_core 0000:04:00.0: irq 184 for MSI/MSI-X
> [   15.664151] mlx4_core 0000:04:00.0: irq 185 for MSI/MSI-X
> [   15.669591] mlx4_core 0000:04:00.0: irq 186 for MSI/MSI-X
> [   15.675031] mlx4_core 0000:04:00.0: irq 187 for MSI/MSI-X
> [   15.680475] mlx4_core 0000:04:00.0: irq 188 for MSI/MSI-X
> [   15.685914] mlx4_core 0000:04:00.0: irq 189 for MSI/MSI-X
> [   15.691355] mlx4_core 0000:04:00.0: irq 190 for MSI/MSI-X
> [   15.696800] mlx4_core 0000:04:00.0: irq 191 for MSI/MSI-X
> [   15.702241] mlx4_core 0000:04:00.0: irq 192 for MSI/MSI-X
> [   15.707680] mlx4_core 0000:04:00.0: irq 193 for MSI/MSI-X
> [   15.713124] mlx4_core 0000:04:00.0: irq 194 for MSI/MSI-X
> [   15.718567] mlx4_core 0000:04:00.0: irq 195 for MSI/MSI-X
> [   15.855949] JRich - __init mlx4_init - mlx4_en_verify_params
> [   15.861667] JRich - __init mlx4_init - mlx4_en_register_debugfs
> [   15.867644] JRich - __init mlx4_init - mlx4_register_interface.   mlx4_en_interface address: (ffffffffa0157410)
> [   15.868599] BUG: unable to handle kernel paging request at ffffb20000a00050
> [   15.868603] IP: [<ffffffff810e40d4>] vmalloc_to_page+0x8c/0xb6
> [   15.868610] PGD 0
> [   15.868613] Oops: 0000 [#1] PREEMPT SMP
> [   15.868616] CPU 17
> [   15.868617] Modules linked in: mlx4_en(O+) mlx4_core(O) compat(O) mptctl ipmi_poweroff coretemp i2c_i801 ixgbe(O) igb(O) mpt2sas(O) ptp pps_core ioapic(P) usb_storage dm_mor
> [   15.868635]
> [   15.868637] Pid: 2329, comm: modprobe Tainted: P           O 3.4.86.TEK.V7.14.3.4.86 #1 Advantech IAP310/10CORE/128GB/IAP310/10CORE/128GB
> [   15.868641] RIP: 0010:[<ffffffff810e40d4>]  [<ffffffff810e40d4>] vmalloc_to_page+0x8c/0xb6
> [   15.868645] RSP: 0018:ffff881fef1b9e28  EFLAGS: 00010006
> [   15.868647] RAX: 00003ffffffff000 RBX: 0000000000000296 RCX: 00002a0000a00000
> [   15.868649] RDX: ffff880000000000 RSI: 0000002000000000 RDI: 00002a0000a00050
> [   15.868651] RBP: ffff881fef1b9e28 R08: dead000000200200 R09: ffffffffa01ce908
> [   15.868653] R10: ffff881fef1b9eb8 R11: ffff882072729f18 R12: ffff88207ffa2c40
> [   15.868654] R13: ffff88201f1ca640 R14: ffffffffa01ceaf0 R15: ffff881fef1b9eb8
> [   15.868657] FS:  00007fd4f4e4b700(0000) GS:ffff88207f440000(0000) knlGS:0000000000000000
> [   15.868659] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   15.868661] CR2: ffffb20000a00050 CR3: 0000001ffdbc9000 CR4: 00000000001407e0
> [   15.868663] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   15.868665] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   15.868667] Process modprobe (pid: 2329, threadinfo ffff881fef1b8000, task ffff8820720f6080)
> [   15.868669] Stack:
> [   15.868670]  ffff881fef1b9e58 ffffffff810d6862 ffff881fef1b9e68 ffffffffa01ceae0
> [   15.868674]  ffffffffa01ce8f0 ffffffffa01ceae0 ffff881fef1b9e88 ffffffff810755d3
> [   15.868678]  ffffffffa01ce8f0 ffff881fef1b9fd8 ffffffff8160b4e0 ffffffffa01ce908
> [   15.868682] Call Trace:
> [   15.868687]  [<ffffffff810d6862>] free_percpu+0xa9/0x117
> [   15.868694]  [<ffffffff810755d3>] module_unload_free+0xcf/0xd8
> [   15.868699]  [<ffffffff81076287>] load_module+0x48d/0x4fe
> [   15.868703]  [<ffffffff81076342>] sys_init_module+0x4a/0x1cb
> [   15.868708]  [<ffffffff814f88d2>] system_call_fastpath+0x16/0x1b
> [   15.868709] Code: 89 f9 48 c1 e9 12 48 21 c6 81 e1 f8 0f 00 00 48 01 f1 48 8b 0c 11 48 85 c9 74 36 48 c1 ef 09 48 21 c1 81 e7 f8 0f 00 00 48 01 cf <48> 8b 14 17 f7 c2 01 01
> [   15.868732] RIP  [<ffffffff810e40d4>] vmalloc_to_page+0x8c/0xb6
> [   15.868735]  RSP <ffff881fef1b9e28>
> [   15.868736] CR2: ffffb20000a00050
> [   15.868739] ---[ end trace 70967baecf84d58c ]---
> [   15.868994] note: modprobe[2329] exited with preempt_count 1
> [   16.133203] JRich - mlx4_register_interface - mutex_lock
> [   16.138553] JRich - mlx4_register_interface - list_add_tail
> [   16.144169] JRich - mlx4_add_device - kmalloc (32)
> [   16.148997] mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.1.11 (Apr 17 2014)
> [   16.156620] mlx4_en 0000:04:00.0: Activating port:1
> [   38.185257] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 0
> [   38.218144] ------------[ cut here ]------------
> [   38.222803] WARNING: at arch/x86/kernel/smp.c:120 native_smp_send_reschedule+0x2a/0x56()
> [   38.230937] Hardware name: IAP310/10CORE/128GB
> [   38.235414] Modules linked in: mlx4_en(O+) mlx4_core(O) compat(O) mptctl ipmi_poweroff coretemp i2c_i801 ixgbe(O) igb(O) mpt2sas(O) ptp pps_core ioapic(P) usb_storage dm_mor
> [   38.266169] Pid: 2327, comm: modprobe Tainted: P      D    O 3.4.86.TEK.V7.14.3.4.86 #1
> [   38.274221] Call Trace:
> [   38.276688]  <IRQ>  [<ffffffff8102ed09>] warn_slowpath_common+0x85/0x9d
> [   38.283381]  [<ffffffff8102ed3b>] warn_slowpath_null+0x1a/0x1c
> [   38.289255]  [<ffffffff8101b447>] native_smp_send_reschedule+0x2a/0x56
> [   38.295826]  [<ffffffff8105ddf8>] trigger_load_balance+0x1d3/0x204
> [   38.302047]  [<ffffffff810585c1>] scheduler_tick+0x118/0x120
> [   38.307750]  [<ffffffff8103bd4c>] update_process_times+0x67/0x77
> [   38.313801]  [<ffffffff8106b566>] tick_sched_timer+0x77/0xa1
> [   38.319507]  [<ffffffff8104f0b8>] __run_hrtimer+0xd0/0x16f
> [   38.325032]  [<ffffffff8106b4ef>] ? tick_nohz_handler+0xe0/0xe0
> [   38.330992]  [<ffffffff8104f399>] hrtimer_interrupt+0xdb/0x1dc
> [   38.336867]  [<ffffffff814fa3fa>] smp_apic_timer_interrupt+0x86/0x99
> [   38.343264]  [<ffffffff814f9347>] apic_timer_interrupt+0x67/0x70
> [   38.349310]  <EOI>  <NMI>  [<ffffffff8102fbfc>] ? console_unlock+0x1e0/0x21c
> [   38.356458]  [<ffffffff814f08ca>] ? panic+0x190/0x1d1
> [   38.361543]  [<ffffffff814f082a>] ? panic+0xf0/0x1d1
> [   38.366546]  [<ffffffff8108d47a>] watchdog_overflow_callback+0x81/0xa6
> [   38.373118]  [<ffffffff810b5e83>] __perf_event_overflow+0x137/0x1cb
> [   38.379423]  [<ffffffff810b78c6>] ? perf_event_update_userpage+0x115/0x124
> [   38.386343]  [<ffffffff810b6157>] perf_event_overflow+0x14/0x16
> [   38.392303]  [<ffffffff81013cc4>] intel_pmu_handle_irq+0x239/0x2af
> [   38.398529]  [<ffffffff812cbd63>] ? ghes_read_estatus+0x86/0x141
> [   38.404578]  [<ffffffff814f4210>] perf_event_nmi_handler+0x19/0x1b
> [   38.410797]  [<ffffffff814f3acc>] nmi_handle+0x50/0x79
> [   38.415968]  [<ffffffff814f3b43>] default_do_nmi+0x4e/0x213
> [   38.421575]  [<ffffffff814f3d78>] do_nmi+0x70/0xbb
> [   38.426399]  [<ffffffff814f32d2>] end_repeat_nmi+0x1a/0x1e
> [   38.431928]  [<ffffffff8125b0b5>] ? delay_tsc+0x4f/0xda
> [   38.437190]  [<ffffffff8125b0b5>] ? delay_tsc+0x4f/0xda
> [   38.442454]  [<ffffffff8125b0b5>] ? delay_tsc+0x4f/0xda
> [   38.447717]  <<EOE>>  [<ffffffff810f5995>] ? cache_grow+0x205/0x22f
> [   38.454061]  [<ffffffff8125b00f>] __delay+0xf/0x11
> [   38.458890]  [<ffffffff81260d23>] do_raw_spin_lock+0xb5/0xfe
> [   38.464596]  [<ffffffff8141d4b0>] ? alloc_etherdev_mqs+0x23/0x23
> [   38.470646]  [<ffffffff814f2923>] _raw_spin_lock_irqsave+0x25/0x2c
> [   38.476865]  [<ffffffff810d6ff9>] pcpu_alloc+0x73/0x34c
> [   38.482128]  [<ffffffff81403c1c>] ? alloc_netdev_mqs+0x86/0x297
> [   38.488087]  [<ffffffff8141d4b0>] ? alloc_etherdev_mqs+0x23/0x23
> [   38.494130]  [<ffffffff810d72f7>] __alloc_percpu+0x10/0x12
> [   38.499652]  [<ffffffff81403c56>] alloc_netdev_mqs+0xc0/0x297
> [   38.505441]  [<ffffffff8141d4ae>] alloc_etherdev_mqs+0x21/0x23
> [   38.511319]  [<ffffffffa0150a93>] mlx4_en_init_netdev+0x39/0xa40 [mlx4_en]
> [   38.518240]  [<ffffffff814f09bb>] ? printk+0x41/0x43
> [   38.523239]  [<ffffffffa01466e6>] mlx4_en_add+0x45d/0x4f7 [mlx4_en]
> [   38.529552]  [<ffffffffa019b471>] mlx4_add_device+0x5b/0xd7 [mlx4_core]
> [   38.536214]  [<ffffffffa019b5fe>] mlx4_register_interface+0x81/0xcb [mlx4_core]
> [   38.543571]  [<ffffffffa0078000>] ? 0xffffffffa0077fff
> [   38.548747]  [<ffffffffa0078062>] __init_backport+0x62/0x64 [mlx4_en]
> [   38.555228]  [<ffffffff8100020f>] do_one_initcall+0x7f/0x12e
> [   38.560921]  [<ffffffff8107637b>] sys_init_module+0x83/0x1cb
> [   38.566618]  [<ffffffff814f88d2>] system_call_fastpath+0x16/0x1b
> [   38.572661] ---[ end trace 70967baecf84d58d ]---
>
>
> lsmod
> Module                  Size  Used by
> nfsd                  229241  13
> bonding                83550  0
> mlx4_en                63641  0
> mlx4_core             118114  1 mlx4_en
> mptctl                 26459  0
> ipmi_poweroff           6858  0
> coretemp                5621  0
> ixgbe                 171462  0
> mpt2sas               195163  0
> igb                   139842  0
> ptp                     6788  1 ixgbe
> ioapic                  1560  0
> pps_core                6010  1 ptp
> usb_storage            33430  0
> vmw_pvscsi             13172  0
> megaraid_sas           61993  0
> mptsas                 43886  0
> scsi_transport_sas     22292  2 mpt2sas,mptsas
> mptspi                 13936  0
> mptscsih               25540  2 mptsas,mptspi
> mptbase                72593  4 mptctl,mptsas,mptspi,mptscsih
> gdth                   74620  0
> ata_piix               14381  0
> ahci                   19432  4
> libahci                17679  1 ahci
> edd                     7366  0
> i2c_dev                 4712  0
> ipmi_watchdog          13970  1
> ipmi_devintf            6759  0
> ipmi_si                36932  2
> ipmi_msghandler        31339  4 ipmi_poweroff,ipmi_watchdog,ipmi_devintf,ipmi_si
>
> and if manually loaded:
> mlx4_en                79880  1572815 [permanent]
> mlx4_core             175978  1572816 mlx4_en,[permanent]
> compat                  5437  24188691904257 mlx4_en,mlx4_core,[permanent]
>
>
> CPU-Info - (single proc - 10 cores + HT)
> processor       :(0- 19)
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 62
> model name      : Genuine Intel(R) CPU  @ 1.40GHz
> stepping        : 2
> microcode       : 0x20d
> cpu MHz         : 1400.410
> cache size      : 25600 KB
> physical id     : 0
> siblings        : 20
> core id         : 12
> cpu cores       : 10
> apicid          : 25
> initial apicid  : 25
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep erms
> bogomips        : 2800.82
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 46 bits physical, 48 bits virtual
> power management:
>
> /proc/meminfo
> MemTotal:       132209888 kB
> MemFree:        131717040 kB
>
> lspci
> 00:00.0 Host bridge: Intel Corporation Ivytown DMI2 (rev 04)
> 00:01.0 PCI bridge: Intel Corporation Device 0e02 (rev 04)
> 00:01.1 PCI bridge: Intel Corporation Device 0e03 (rev 04)
> 00:02.0 PCI bridge: Intel Corporation Ivytown PCI Express Root Port 2a (rev 04)
> 00:02.2 PCI bridge: Intel Corporation Ivytown PCI Express Root Port 2c (rev 04)
> 00:03.0 PCI bridge: Intel Corporation Ivytown PCI Express Root Port 3a (rev 04)
> 00:03.2 PCI bridge: Intel Corporation Ivytown PCI Express Root Port 3c (rev 04)
> 00:05.0 System peripheral: Intel Corporation Ivytown VTd/Memory Map/Misc (rev 04)
> 00:05.2 System peripheral: Intel Corporation Ivytown IIO RAS (rev 04)
> 00:05.4 PIC: Intel Corporation Ivytown IOAPIC (rev 04)
> 00:11.0 PCI bridge: Intel Corporation C600/X79 series chipset PCI Express Virtual Root Port (rev 06)
> 00:1a.0 USB controller: Intel Corporation C600/X79 series chipset USB2 Enhanced Host Controller #2 (rev 06)
> 00:1d.0 USB controller: Intel Corporation C600/X79 series chipset USB2 Enhanced Host Controller #1 (rev 06)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a6)
> 00:1f.0 ISA bridge: Intel Corporation C600/X79 series chipset LPC Controller (rev 06)
> 00:1f.2 SATA controller: Intel Corporation C600/X79 series chipset 6-Port SATA AHCI Controller (rev 06)
> 00:1f.3 SMBus: Intel Corporation C600/X79 series chipset SMBus Host Controller (rev 06)
> 00:1f.6 Signal processing controller: Intel Corporation C600/X79 series chipset Thermal Management Controller (rev 06)
> 01:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
> 01:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
> 01:00.2 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
> 01:00.3 Ethernet controller: Intel Corporation I350 Gigabit Fiber Network Connection (rev 01)
> 04:00.0 Ethernet controller: Mellanox Technologies MT27500 Family [ConnectX-3]
> 05:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
> 05:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
> 07:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
> 07:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
> 09:00.0 Serial Attached SCSI controller: LSI Logic / Symbios Logic SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon] (rev 03)
> ff:08.0 System peripheral: Intel Corporation Ivytown QPI Link 0 (rev 04)
> ff:09.0 System peripheral: Intel Corporation Ivytown QPI Link 1 (rev 04)
> ff:0a.0 System peripheral: Intel Corporation Ivytown Power Control Unit 0 (rev 04)
> ff:0a.1 System peripheral: Intel Corporation Ivytown Power Control Unit 1 (rev 04)
> ff:0a.2 System peripheral: Intel Corporation Ivytown Power Control Unit 2 (rev 04)
> ff:0a.3 System peripheral: Intel Corporation Ivytown Power Control Unit 3 (rev 04)
> ff:0b.0 System peripheral: Intel Corporation Ivytown Semaphore and Scratchpad Configuration Registers (rev 04)
> ff:0b.3 System peripheral: Intel Corporation Ivytown Semaphore and Scratchpad Configuration Registers (rev 04)
> ff:0c.0 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0c.1 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0c.2 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0c.3 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0c.4 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0d.0 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0d.1 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0d.2 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0d.3 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0d.4 System peripheral: Intel Corporation Ivytown Unicast Registers (rev 04)
> ff:0e.0 System peripheral: Intel Corporation Ivytown Home Agent 0 (rev 04)
> ff:0e.1 Performance counters: Intel Corporation Ivytown Home Agent 0 (rev 04)
> ff:0f.0 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 0 Target Address/Thermal Registers (rev 04)
> ff:0f.1 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 0 RAS Registers (rev 04)
> ff:0f.2 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 0 Channel Target Address Decoder Registers (rev 04)
> ff:0f.3 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 0 Channel Target Address Decoder Registers (rev 04)
> ff:0f.4 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 0 Channel Target Address Decoder Registers (rev 04)
> ff:0f.5 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 0 Channel Target Address Decoder Registers (rev 04)
> ff:10.0 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 Thermal Control 0 (rev 04)
> ff:10.1 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 Thermal Control 1 (rev 04)
> ff:10.2 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 ERROR Registers 0 (rev 04)
> ff:10.3 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 ERROR Registers 1 (rev 04)
> ff:10.4 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 Thermal Control 2 (rev 04)
> ff:10.5 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 Thermal Control 3 (rev 04)
> ff:10.6 System peripheral: Intel Corporation Device 0eb6 (rev 04)
> ff:10.7 System peripheral: Intel Corporation Ivytown Integrated Memory Controller 1 Channel 0-3 ERROR Registers 2 (rev 04)
> ff:13.0 System peripheral: Intel Corporation Ivytown R2PCIe (rev 04)
> ff:13.1 Performance counters: Intel Corporation Ivytown PCI Express Ring Performance Monitoring (rev 04)
> ff:13.4 System peripheral: Intel Corporation Ivytown QPI Ring Registers (rev 04)
> ff:13.5 Performance counters: Intel Corporation Ivytown QPI Ring Performance Ring Monitoring (rev 04)
> ff:16.0 System peripheral: Intel Corporation Ivytown System Address Decoder (rev 04)
> ff:16.1 System peripheral: Intel Corporation Ivytown Broadcast Registers (rev 04)
> ff:16.2 System peripheral: Intel Corporation Ivytown Broadcast Registers (rev 04)
>
>
> Jason Rich
> Platform Engineering
> E: Jason.Rich@tekcomms.com
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
