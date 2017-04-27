From: Sricharan R <sricharan@codeaurora.org>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Thu, 27 Apr 2017 19:05:09 +0530
Message-ID: <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
References: <20170426181508.687b52af@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Joerg Roedel <jroedel@suse.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Ralph Sennhauser <ralph.sennhauser@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170426181508.687b52af@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 4/26/2017 9:45 PM, Ralph Sennhauser wrote:
> Hi Sricharan R,
> 
> Commit 09515ef5ddad ("of/acpi: Configure dma operations at probe time
> for platform/amba/pci bus devices") causes a kernel panic as in the log
> below on an armada-385. Reverting the commit fixes the issue.
> 
> Regards
> Ralph

Somehow not getting a obvious clue on whats going wrong with the logs
below. From the log and looking in to dts, the drivers seems to the one for
"marvell,armada-370-neta". Issue looks the data from the dma has gone bad
and subsequently referring the wrong data has resulted in the crash.
Looks like the dma_masks is the one going wrong.
Can i get some logs from mvneta_probe, about dev->dma_mask,
dev->coherent_dma_mask and dev->dma_ops with and without the patch
to see whats the difference ?

Regards,
 Sricharan

> 
> ---
> 
> [   18.288244] [c06d8480] *pgd=0061941e(bad)
> [   18.292271] Internal error: Oops: 80d [#1] SMP ARM
> [   18.297080] Modules linked in:
> [   18.471175] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O    4.11.0-rc8-next-20170426 #3
> [   18.479909] Hardware name: Marvell Armada 380/385 (Device Tree)
> [   18.485850] task: c0a07000 task.stack: c0a00000
> [   18.490401] PC is at __memzero+0x40/0x80
> [   18.494336] LR is at 0x0
> [   18.496878] pc : [<c0317920>]    lr : [<00000000>]    psr: 00000113
> [   18.496878] sp : c0a01d0c  ip : 00000000  fp : c0a01d34
> [   18.508402] r10: df43f800  r9 : df43f800  r8 : 00000001
> [   18.513645] r7 : c06d7e40  r6 : 000007c0  r5 : c06d8480  r4 : de14aa80
> [   18.520196] r3 : 00000000  r2 : 00000000  r1 : ffffffe4  r0 : c06d8480
> [   18.526750] Flags: nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
> [   18.533912] Control: 10c5387d  Table: 16f0004a  DAC: 00000051
> [   18.539679] Process swapper/0 (pid: 0, stack limit = 0xc0a00210)
> [   18.545708] Stack: (0xc0a01d0c to 0xc0a02000)
> [   18.550082] 1d00:                            c04caef0 c06d7e40 00000700 0cc04000 00000001
> [   18.558292] 1d20: df691810 df43f800 c0a01d4c c0a01d38 c04caf20 c04cae7c e1b1d000 df5bd980
> [   18.566503] 1d40: c0a01dc4 c0a01d50 c043d3d8 c04caf14 df41e494 00000000 1e652500 c0601460
> [   18.574714] 1d60: dfbd8880 c0a04680 c06d7e40 00000000 dfbd8888 00000000 00000000 00000188
> [   18.582924] 1d80: 1e652500 dfbd8880 00000040 00000100 df43fc80 00000001 00000000 dfbd8888
> [   18.591134] 1da0: c043cfd4 00000040 0000012c ffff91f5 c0a02d00 c0a01de8 c0a01e24 c0a01dc8
> [   18.599345] 1dc0: c04db2d4 c043cfe0 c015d81c c06db4d4 c0a04990 c0a04990 c0a302b2 1f267000
> [   18.607555] 1de0: c096ab40 dfbd1b40 c0a01de8 c0a01de8 c0a01df0 c0a01df0 c0a01e1c 00000000
> [   18.615766] 1e00: c0a0208c c0a00000 00000100 00000003 c0a02080 40000003 c0a01e84 c0a01e28
> [   18.623977] 1e20: c0122e9c c04db0cc c0a01e54 00000101 c0a01e4c 00200102 c0a02d00 ffff91f5
> [   18.632187] 1e40: 0000000a c06025b4 c0a31740 c09632a8 c0a02080 c0a01e28 c0169788 c0968420
> [   18.640397] 1e60: 00000000 00000000 00000001 df408000 e0803100 c0a01f58 c0a01e94 c0a01e88
> [   18.648607] 1e80: c01232d0 c0122d84 c0a01ebc c0a01e98 c015d6e4 c012322c c0a169c0 c0a03fac
> [   18.656818] 1ea0: e080210c c0a01ee8 e0802100 e0803100 c0a01ee4 c0a01ec0 c01014a4 c015d688
> [   18.665029] 1ec0: c01085b0 60000013 ffffffff c0a01f1c 00000000 c0a00000 c0a01f44 c0a01ee8
> [   18.673240] 1ee0: c010c86c c0101460 00000001 00000000 00000000 c0118e40 c0a00000 c0a03cf8
> [   18.681451] 1f00: c0a03cac c09696f8 00000000 00000000 c0a01f58 c0a01f44 c0a01f48 c0a01f38
> [   18.689661] 1f20: c01085ac c01085b0 60000013 ffffffff 00000051 00000000 c0a01f54 c0a01f48
> [   18.697871] 1f40: c05e3634 c010857c c0a01f8c c0a01f58 c0153458 c05e3618 c0a03c80 c0a0f30a
> [   18.706082] 1f60: c0a30c00 000000bd c0a30c00 c0a03c80 ffffffff c0a30c00 c0833a28 dfffcb40
> [   18.714292] 1f80: c0a01f9c c0a01f90 c0153718 c01532c0 c0a01fac c0a01fa0 c05dd758 c0153704
> [   18.722503] 1fa0: c0a01ff4 c0a01fb0 c0800d68 c05dd6e8 ffffffff ffffffff 00000000 c08006f8
> [   18.730713] 1fc0: 00000000 c0833a28 00000000 c0a30e94 c0a03c9c c0833a24 c0a081e8 0000406a
> [   18.738923] 1fe0: 414fc091 00000000 00000000 c0a01ff8 0000807c c08009b4 00000000 00000000
> [   18.747132] Backtrace:
> [   18.749591] [<c04cae70>] (__build_skb) from [<c04caf20>] (build_skb+0x18/0x6c)
> [   18.756843]  r9:df43f800 r8:df691810 r7:00000001 r6:0cc04000 r5:00000700 r4:c06d7e40
> [   18.764618] [<c04caf08>] (build_skb) from [<c043d3d8>] (mvneta_poll+0x404/0xc18)
> [   18.772042]  r5:df5bd980 r4:e1b1d000
> [   18.775632] [<c043cfd4>] (mvneta_poll) from [<c04db2d4>] (net_rx_action+0x214/0x308)
> [   18.783406]  r10:c0a01de8 r9:c0a02d00 r8:ffff91f5 r7:0000012c r6:00000040 r5:c043cfd4
> [   18.791266]  r4:dfbd8888
> [   18.793810] [<c04db0c0>] (net_rx_action) from [<c0122e9c>] (__do_softirq+0x124/0x248)
> [   18.801672]  r10:40000003 r9:c0a02080 r8:00000003 r7:00000100 r6:c0a00000 r5:c0a0208c
> [   18.809531]  r4:00000000
> [   18.812074] [<c0122d78>] (__do_softirq) from [<c01232d0>] (irq_exit+0xb0/0xe4)
> [   18.819325]  r10:c0a01f58 r9:e0803100 r8:df408000 r7:00000001 r6:00000000 r5:00000000
> [   18.827184]  r4:c0968420
> [   18.829729] [<c0123220>] (irq_exit) from [<c015d6e4>] (__handle_domain_irq+0x68/0xbc)
> [   18.837591] [<c015d67c>] (__handle_domain_irq) from [<c01014a4>] (gic_handle_irq+0x50/0x94)
> [   18.845976]  r9:e0803100 r8:e0802100 r7:c0a01ee8 r6:e080210c r5:c0a03fac r4:c0a169c0
> [   18.853749] [<c0101454>] (gic_handle_irq) from [<c010c86c>] (__irq_svc+0x6c/0x90)
> [   18.861261] Exception stack(0xc0a01ee8 to 0xc0a01f30)
> [   18.866332] 1ee0:                   00000001 00000000 00000000 c0118e40 c0a00000 c0a03cf8
> [   18.874543] 1f00: c0a03cac c09696f8 00000000 00000000 c0a01f58 c0a01f44 c0a01f48 c0a01f38
> [   18.882753] 1f20: c01085ac c01085b0 60000013 ffffffff
> [   18.887823]  r9:c0a00000 r8:00000000 r7:c0a01f1c r6:ffffffff r5:60000013 r4:c01085b0
> [   18.895601] [<c0108570>] (arch_cpu_idle) from [<c05e3634>] (default_idle_call+0x28/0x34)
> [   18.903727] [<c05e360c>] (default_idle_call) from [<c0153458>] (do_idle+0x1a4/0x1d0)
> [   18.911503] [<c01532b4>] (do_idle) from [<c0153718>] (cpu_startup_entry+0x20/0x24)
> [   18.919103]  r10:dfffcb40 r9:c0833a28 r8:c0a30c00 r7:ffffffff r6:c0a03c80 r5:c0a30c00
> [   18.926962]  r4:000000bd
> [   18.929508] [<c01536f8>] (cpu_startup_entry) from [<c05dd758>] (rest_init+0x7c/0x80)
> [   18.937284] [<c05dd6dc>] (rest_init) from [<c0800d68>] (start_kernel+0x3c0/0x3cc)
> [   18.944796] [<c08009a8>] (start_kernel) from [<0000807c>] (0x807c)
> [   18.951001] Code: a8a0500c cafffff9 08bd8000 e3110020 (18a0500c)
> [   18.957119] ---[ end trace 4e5c1e66e49610b0 ]---
> [   18.961753] Kernel panic - not syncing: Fatal exception in interrupt
> [   18.968133] CPU1: stopping
> [   18.970852] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D    O    4.11.0-rc8-next-20170426 #3
> [   18.979585] Hardware name: Marvell Armada 380/385 (Device Tree)
> [   18.985527] Backtrace:
> [   18.987986] [<c010ba4c>] (dump_backtrace) from [<c010bd20>] (show_stack+0x18/0x1c)
> [   18.995586]  r7:df467f28 r6:60000193 r5:c0a165b0 r4:00000000
> [   19.001268] [<c010bd08>] (show_stack) from [<c031883c>] (dump_stack+0x94/0xa8)
> [   19.008520] [<c03187a8>] (dump_stack) from [<c010ecec>] (handle_IPI+0x178/0x198)
> [   19.015945]  r7:df467f28 r6:00000000 r5:00000001 r4:c0a30ef0
> [   19.021627] [<c010eb74>] (handle_IPI) from [<c01014e4>] (gic_handle_irq+0x90/0x94)
> [   19.029227]  r7:df467f28 r6:e080210c r5:c0a03fac r4:c0a169c0
> [   19.034908] [<c0101454>] (gic_handle_irq) from [<c010c86c>] (__irq_svc+0x6c/0x90)
> [   19.042419] Exception stack(0xdf467f28 to 0xdf467f70)
> [   19.047490] 7f20:                   00000001 00000000 00000000 c0118e40 df466000 c0a03cf8
> [   19.055701] 7f40: c0a03cac c09696f8 00000000 00000000 df467f98 df467f84 df467f88 df467f78
> [   19.063911] 7f60: c01085ac c01085b0 60000013 ffffffff
> [   19.068982]  r9:df466000 r8:00000000 r7:df467f5c r6:ffffffff r5:60000013 r4:c01085b0
> [   19.076758] [<c0108570>] (arch_cpu_idle) from [<c05e3634>] (default_idle_call+0x28/0x34)
> [   19.084882] [<c05e360c>] (default_idle_call) from [<c0153458>] (do_idle+0x1a4/0x1d0)
> [   19.092657] [<c01532b4>] (do_idle) from [<c0153718>] (cpu_startup_entry+0x20/0x24)
> [   19.100258]  r10:00000000 r9:414fc091 r8:0000406a r7:c0a30f00 r6:10c0387d r5:00000001
> [   19.108118]  r4:00000087
> [   19.110661] [<c01536f8>] (cpu_startup_entry) from [<c010e918>] (secondary_start_kernel+0x150/0x15c)
> [   19.119743] [<c010e7c8>] (secondary_start_kernel) from [<0010162c>] (0x10162c)
> [   19.126993]  r5:00000051 r4:1f45c06a
> [   19.130583] Rebooting in 3 seconds..
> 
> ---
> 
> git bisect start
> # bad: [e0a8aa40bd2c7d973b6520293f3fd86dcbca847b] Add linux-next specific files for 20170426
> git bisect bad e0a8aa40bd2c7d973b6520293f3fd86dcbca847b
> # good: [c1ae3cfa0e89fa1a7ecc4c99031f5e9ae99d9201] Linux 4.11-rc1
> git bisect good c1ae3cfa0e89fa1a7ecc4c99031f5e9ae99d9201
> # good: [221c3c382a529418d3a2acc58f53101103f6ff13] Merge remote-tracking branch 'l2-mtd/master'
> git bisect good 221c3c382a529418d3a2acc58f53101103f6ff13
> # bad: [ffcefbbe2f8c0af5f22af921afd2756baceddd74] Merge remote-tracking branch 'spi/for-next'
> git bisect bad ffcefbbe2f8c0af5f22af921afd2756baceddd74
> # good: [c2e7f82d336a451ebb904b8bf9a5a558cf16c39b] drm: mali-dp: Check the mclk rate and allow up/down scaling
> git bisect good c2e7f82d336a451ebb904b8bf9a5a558cf16c39b
> # good: [03b600f368cfa6f94e9622dda82e60f55b5e6224] Merge remote-tracking branch 'block/for-next'
> git bisect good 03b600f368cfa6f94e9622dda82e60f55b5e6224
> # good: [8b1e05cbcdfc59496eff5870cb6b6ab964ecc733] Merge remote-tracking branch 'battery/for-next'
> git bisect good 8b1e05cbcdfc59496eff5870cb6b6ab964ecc733
> # good: [e765d496d3adb3d69bd8c53df6fd3f3b77e5b1d2] Merge remote-tracking branch 'watchdog/master'
> git bisect good e765d496d3adb3d69bd8c53df6fd3f3b77e5b1d2
> # bad: [858eed97e369df7af0993463f355aa9755227136] Merge remote-tracking branch 'audit/next'
> git bisect bad 858eed97e369df7af0993463f355aa9755227136
> # bad: [efc2195bcc35eebf06805806eb525893f3b9ab5c] Merge branches 'arm/exynos', 'arm/omap', 'arm/rockchip', 'arm/mediatek', 'arm/smmu', 'arm/core', 'x86/vt-d', 'x86/amd' and 'core' into next
> git bisect bad efc2195bcc35eebf06805806eb525893f3b9ab5c
> # bad: [316ca8804ea84a782d5ba2163711ebb22116ff5a] ACPI/IORT: Remove linker section for IORT entries probing
> git bisect bad 316ca8804ea84a782d5ba2163711ebb22116ff5a
> # good: [d7b0558230e444f29488fcee0b0b561015d16f8a] iommu/of: Prepare for deferred IOMMU configuration
> git bisect good d7b0558230e444f29488fcee0b0b561015d16f8a
> # bad: [09515ef5ddad71c7820e5e428da418b709feeb26] of/acpi: Configure dma operations at probe time for platform/amba/pci bus devices
> git bisect bad 09515ef5ddad71c7820e5e428da418b709feeb26
> # good: [1d9029d440e40b276c0691caed1de10c42d96bef] ACPI/IORT: Add function to check SMMUs drivers presence
> git bisect good 1d9029d440e40b276c0691caed1de10c42d96bef
> # good: [efc8551a276faab19d85079da02c5fb602b0dcbe] of: device: Fix overflow of coherent_dma_mask
> git bisect good efc8551a276faab19d85079da02c5fb602b0dcbe
> # first bad commit: [09515ef5ddad71c7820e5e428da418b709feeb26] of/acpi:
> Configure dma operations at probe time for platform/amba/pci bus devices
> 

-- 
"QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation
