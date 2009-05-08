From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PowerPC] Next May 8 boot failure: OOPS during ibmveth module
	init
Date: Sat, 9 May 2009 00:33:33 +0200
Message-ID: <20090508223332.GA4881@psychotron.englab.brq.redhat.com>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au> <4A042B20.4090903@in.ibm.com> <20090508.125722.54378771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sachinp@in.ibm.com, linux-next@vger.kernel.org,
	linuxppc-dev@ozlabs.org, sfr@canb.auug.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090508.125722.54378771.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, May 08, 2009 at 09:57:22PM CEST, davem@davemloft.net wrote:
>From: Sachin Sant <sachinp@in.ibm.com>
>Date: Fri, 08 May 2009 18:22:48 +0530
>
>> Todays Next failed to boot on a Power6 JS22 blade with following oops.
>
>Jiri, I suspect this might be your address list changes.
>
>Although that's just a guess.  But please take a look.

Hmm, only thing I see might cause the problem would be if calling __hw_addr_add
in dev_addr_init fails, then dev->dev_addr would contain zeroes (which looks
this is not the case). But in this case the oops would appear earlier (in
ibmveth_probe dev_addr memcpy).

Will do the patch which checks the result to behave correctly in case of oom
but this imho this wouldn't help. Strange, I will dig into this more tomorrow.

>
>> Unable to handle kernel paging request for data at address
>> 0x654af306c04b990
>> Faulting instruction address: 0xc00000000003a740
>> Oops: Kernel access of bad area, sig: 11 [#1]
>> SMP NR_CPUS=1024 NUMA pSeries
>> Modules linked in: ibmveth(+) sg sd_mod crc_t10dif ibmvscsic
>> scsi_transport_srp scsi_tgt scsi_mod
>> NIP: c00000000003a740 LR: c000000000361e20 CTR: 0000000000000000
>> REGS: c000000042af6e80 TRAP: 0300 Not tainted
>> (2.6.30-rc4-next-20090508)
>> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28222286  XER: 20000001
>> DAR: 0654af306c04b990, DSISR: 0000000040000000
>> TASK = c0000000428084d0[590] 'modprobe' THREAD: c000000042af4000 CPU:
>> 0
>> GPR00: c000000000361e10 c000000042af7100 c000000000eb8190
>> c00000004427cc80
>> GPR04: 0654af306c04b990 0000000000000006 0000000000000000
>> 0000000000000002
>> GPR08: c00000004427cc00 0000000000000088 0000000000000280
>> 000000000000007c
>> GPR12: 0000000084222284 c000000000f92400 0000000000000000
>> 0000000000000000
>> GPR16: 0000000000000000 0000000000000000 d000000000ed4346
>> d000000000ed3aa0
>> GPR20: d000000000ed6358 c00000004427cc00 00000000ffffffff
>> 0000000000000000
>> GPR24: 0000000000000000 c0000000402d0000 0000000000000010
>> c00000004194b400
>> GPR28: 0000000000000006 0654af306c04b990 c000000000e44f18
>> 0000000000000000
>> NIP [c00000000003a740] .memcpy+0x240/0x278
>> LR [c000000000361e20] .__nla_put+0x30/0x4c
>> Call Trace:
>> [c000000042af7100] [c000000000361e10] .__nla_put+0x20/0x4c
>> (unreliable)
>> [c000000042af7190] [c000000000361e88] .nla_put+0x4c/0x60
>> [c000000042af7200] [c00000000053993c] .rtnl_fill_ifinfo+0x308/0x614
>> [c000000042af7300] [c00000000053a118] .rtmsg_ifinfo+0x104/0x198
>> [c000000042af73b0] [c00000000053a244] .rtnetlink_event+0x98/0xb0
>> [c000000042af7430] [c0000000005c8330] .notifier_call_chain+0x68/0xdc
>> [c000000042af74d0] [c000000000530488] .register_netdevice+0x390/0x418
>> [c000000042af75a0] [c000000000530568] .register_netdev+0x58/0x80
>> [c000000042af7630] [d000000000ed2da4] .ibmveth_probe+0x2c8/0x3a4
>> [ibmveth]
>> [c000000042af7730] [c000000000023208] .vio_bus_probe+0x2f0/0x358
>> [c000000042af77f0] [c000000000462be0] .driver_probe_device+0xd4/0x1bc
>> [c000000042af7890] [c000000000462d5c] .__driver_attach+0x94/0xd8
>> [c000000042af7920] [c000000000462164] .bus_for_each_dev+0x80/0xe8
>> [c000000042af79d0] [c0000000004629b0] .driver_attach+0x28/0x40
>> [c000000042af7a50] [c000000000461808] .bus_add_driver+0xdc/0x27c
>> [c000000042af7af0] [c0000000004631d0] .driver_register+0xf0/0x1b0
>> [c000000042af7b90] [c000000000025178] .vio_register_driver+0x44/0x60
>> [c000000042af7c20] [d000000000ed2ed4] .ibmveth_module_init+0x54/0xa60
>> [ibmveth]
>> [c000000042af7ca0] [c0000000000092c0] .do_one_initcall+0x80/0x19c
>> [c000000042af7d90] [c0000000000bf884] .SyS_init_module+0xe0/0x248
>> [c000000042af7e30] [c000000000008534] syscall_exit+0x0/0x40
>> Instruction dump:
>> 7cb01120 7c862214 7c661a14 4bfffe04 409c001c 80040000 81240004
>> 38840008
>> 90030000 91230004 38630008 409d0014 <80040000> 38840004 90030000
>> 38630004
>> ---[ end trace 695e9dc0c5a9da2f ]---
>> 
>> udevd-event[587]: '/sbin/modprobe' abnormal exit
>> 
>> Unable to handle kernel paging request for data at address
>> 0x654af306c04b990
>> Faulting instruction address: 0xc000000000543ce0
>> Oops: Kernel access of bad area, sig: 11 [#2]
>> SMP NR_CPUS=1024 NUMA pSeries
>> Modules linked in: ibmveth(+) sg sd_mod crc_t10dif ibmvscsic
>> scsi_transport_srp scsi_tgt scsi_mod
>> NIP: c000000000543ce0 LR: c000000000543dcc CTR: c00000000053dd98
>> REGS: c0000000408b3740 TRAP: 0300 Tainted: G D
>> (2.6.30-rc4-next-20090508)
>> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24042428  XER: 00000001
>> DAR: 0654af306c04b990, DSISR: 0000000040000000
>> TASK = c00000004053d880[752] 'udevd' THREAD: c0000000408b0000 CPU: 3
>> GPR00: c000000000543dcc c0000000408b39c0 c000000000eb8190
>> c0000000448e0000
>> GPR04: 0000000000010000 c000000000796dec 0000000000000006
>> 0000000000000000
>> GPR08: c00000004265cf34 c000000000ea7250 c00000004265cf34
>> 0000000000000000
>> GPR12: 0000000044042488 c000000000f92a00 0000000000000001
>> 0000000000000001
>> GPR16: 00000000100372dc 00000000100374e0 00000000100376f8
>> 0000000000000000
>> GPR20: 0000000010036ec8 0000000000000000 00000fffdb3a6618
>> 0000000000000200
>> GPR24: 0000000000000006 0000000000000005 c0000000448f0000
>> c0000000448e0000
>> GPR28: 0654af306c04b990 0000000000000000 c000000000e45318
>> c0000000448e0000
>> NIP [c000000000543ce0] ._format_mac_addr+0x54/0xd4
>> LR [c000000000543dcc] .sysfs_format_mac+0x30/0x6c
>> Call Trace:
>> [c0000000408b39c0] [c00000000010c9a4]
>> .__alloc_pages_internal+0x1b8/0x590 (unreliable)
>> [c0000000408b3a70] [c000000000543dcc] .sysfs_format_mac+0x30/0x6c
>> [c0000000408b3b00] [c00000000053dde8] .show_address+0x50/0x88
>> [c0000000408b3b90] [c00000000045ead4] .dev_attr_show+0x4c/0x94
>> [c0000000408b3c20] [c0000000001bce48] .sysfs_read_file+0x10c/0x1d0
>> [c0000000408b3ce0] [c00000000014c9a0] .vfs_read+0xd0/0x1bc
>> [c0000000408b3d80] [c00000000014cb94] .SyS_read+0x58/0xa0
>> [c0000000408b3e30] [c000000000008534] syscall_exit+0x0/0x40
>> Instruction dump:
>> f8010010 ebc2cc58 f821ff51 7c7b1b78 7cd83378 7cbc2b78 7f432214
>> 7c7f1b78
>> 3ba00000 3b26ffff 48000044 e8be8000 <88dc0000> 3b9c0001 4be0ff89
>> 60000000
>> ---[ end trace 695e9dc0c5a9da30 ]---
>> 
>> attempt to access beyond end of device
>> 
>> Next May 7 with same config boots fine.
>> 
>> Thanks
>> -Sachin
>> 
>> -- 
>> 
>> ---------------------------------
>> Sachin Sant
>> IBM Linux Technology Center
>> India Systems and Technology Labs
>> Bangalore, India
>> ---------------------------------
>> 
