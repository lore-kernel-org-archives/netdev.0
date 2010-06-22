From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16268] New: kernel oops when rmmod the
 tcp_diag modules
Date: Tue, 22 Jun 2010 14:12:32 -0700
Message-ID: <20100622141232.4b8f1d4a.akpm@linux-foundation.org>
References: <bug-16268-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lyw@cn.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44333 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753263Ab0FVVNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 17:13:13 -0400
In-Reply-To: <bug-16268-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 22 Jun 2010 00:43:37 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16268
> 
>            Summary: kernel oops when rmmod the tcp_diag modules
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.35-rc3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: lyw@cn.fujitsu.com
>         Regression: No
> 
> 
> I found a crash problem use following scripts and steps
> 
> #cat run_ss.sh
>  while [ 1 ]
>  do
>      ss -a
>  done
> 
> #cat rmmod.sh
>  while [ 1 ]
>  do 
>      rmmod -f tcp_diag >/dev/null 2>&1
>      rmmod -f inet_diag >/dev/null 2>&1
>  done
> 
> step1:
>   # sh run_sh.sh
> step2:
>   # sh rmmod.sh

I assume the rmmod script runs in pararallel with run_ss.sh.

What is "ss"?  Something which triggers a load of kernel modules,
presumably.  Which ones?

> After step2, the kernel oopsed.

yeah, that was a pretty nasty test ;)

> ========================================================
> Jun 22 08:44:33 RHEL6Beta kernel: Disabling lock debugging due to kernel taint
> Jun 22 08:44:33 RHEL6Beta kernel: BUG: unable to handle kernel NULL pointer
> dereference at (null)
> Jun 22 08:44:33 RHEL6Beta kernel: IP: [<f982d140>] 0xf982d140
> Jun 22 08:44:33 RHEL6Beta kernel: *pdpt = 0000000033af2001 *pde =
> 000000007d9cf067
> Jun 22 08:44:33 RHEL6Beta kernel: Oops: 0002 [#1] SMP
> Jun 22 08:44:33 RHEL6Beta kernel: last sysfs file:
> /sys/module/inet_diag/initstate
> Jun 22 08:44:33 RHEL6Beta kernel: Modules linked in: tcp_diag inet_diag
> p4_clockmod ipv6 dm_mirror dm_region_hash dm_log dm_mod snd_intel8x0
> snd_ac97_codec ac97_bus snd_seq snd_mpu401 snd_mpu401_uart snd_pcm snd_rawmidi
> snd_seq_device snd_timer snd r8169 8139too ppdev 8139cp soundcore mii
> parport_pc floppy sr_mod cdrom parport ns558 gameport sg iTCO_wdt
> iTCO_vendor_support snd_page_alloc pcspkr i2c_i801 ext3 jbd mbcache sd_mod
> crc_t10dif ata_generic pata_acpi ata_piix i915 drm_kms_helper drm i2c_algo_bit
> i2c_core video output [last unloaded: inet_diag]
> Jun 22 08:44:33 RHEL6Beta kernel:
> Jun 22 08:44:33 RHEL6Beta kernel: Pid: 27392, comm: ss Tainted: G  R        
> 2.6.35-rc3 #1 F61MV/AcerPower S100
> Jun 22 08:44:33 RHEL6Beta kernel: EIP: 0060:[<f982d140>] EFLAGS: 00010282 CPU:
> 0
> Jun 22 08:44:33 RHEL6Beta kernel: EIP is at 0xf982d140
> Jun 22 08:44:33 RHEL6Beta kernel: EAX: 00000000 EBX: 00000012 ECX: 00000001
> EDX: 00000000
> Jun 22 08:44:33 RHEL6Beta kernel: ESI: f4217b80 EDI: f4239f00 EBP: f4239f00
> ESP: f3b07bcc
> Jun 22 08:44:33 RHEL6Beta kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Jun 22 08:44:33 RHEL6Beta kernel: Process ss (pid: 27392, ti=f3b06000
> task=f4152a50 task.ti=f3b06000)
> Jun 22 08:44:33 RHEL6Beta kernel: Stack:
> Jun 22 08:44:33 RHEL6Beta kernel: 00000001 f982e6b0 00000010 00000004 00000012
> f5a74400 f982debb c064256f
> Jun 22 08:44:33 RHEL6Beta kernel: <0> 0196b67e 00000014 c09fb3e0 90e7b493
> f3b07c38 f3b07c38 f4217b80 00000344
> Jun 22 08:44:33 RHEL6Beta kernel: <0> f4239f00 00000246 f3b07d80 00000246
> 00021453 000000d0 000000d0 c0746d84
> Jun 22 08:44:33 RHEL6Beta kernel: Call Trace:
> Jun 22 08:44:33 RHEL6Beta kernel: [<c064256f>] ?
> mix_pool_bytes_extract+0x4f/0x150
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0746d84>] ? __alloc_skb+0x54/0x100
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0746d84>] ? __alloc_skb+0x54/0x100
> Jun 22 08:44:33 RHEL6Beta kernel: [<c074333c>] ? sock_rmalloc+0x4c/0x90
> Jun 22 08:44:33 RHEL6Beta kernel: [<c076d6e3>] ? netlink_dump+0x53/0x1b0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c04f529e>] ?
> kmem_cache_alloc_notrace+0x9e/0xb0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c076f2e0>] ? netlink_dump_start+0x130/0x1b0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c076f18e>] ? netlink_rcv_skb+0x7e/0xa0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c076eab0>] ? netlink_unicast+0x250/0x280
> Jun 22 08:44:33 RHEL6Beta kernel: [<c076f81c>] ? netlink_sendmsg+0x1bc/0x2a0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0740982>] ? sock_sendmsg+0xd2/0x110
> Jun 22 08:44:33 RHEL6Beta kernel: [<c04374bd>] ? kmap_atomic_prot+0x11d/0x150
> Jun 22 08:44:33 RHEL6Beta kernel: [<c043750c>] ? kmap_atomic+0x1c/0x30
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0437357>] ? kunmap_atomic+0x67/0x80
> Jun 22 08:44:33 RHEL6Beta kernel: [<c04ca242>] ?
> get_page_from_freelist+0x242/0x4d0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c05b8fa5>] ? _copy_from_user+0x35/0x120
> Jun 22 08:44:33 RHEL6Beta kernel: [<c05b8fa5>] ? _copy_from_user+0x35/0x120
> Jun 22 08:44:33 RHEL6Beta kernel: [<c07418e3>] ? sys_sendmsg+0x163/0x260
> Jun 22 08:44:33 RHEL6Beta kernel: [<c04f529e>] ?
> kmem_cache_alloc_notrace+0x9e/0xb0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c05787ed>] ?
> selinux_sk_alloc_security+0x6d/0xe0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c04f53ac>] ? kmem_cache_alloc+0xfc/0x120
> Jun 22 08:44:33 RHEL6Beta kernel: [<c074303e>] ? sock_init_data+0xae/0x1d0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c046df2d>] ? creds_are_invalid+0x1d/0x40
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0502ea3>] ? get_empty_filp+0x123/0x1c0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0502fc7>] ? alloc_file+0x87/0xb0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c073f6f6>] ? sock_alloc_file+0xa6/0x120
> Jun 22 08:44:33 RHEL6Beta kernel: [<c04ffeb6>] ? fd_install+0x26/0x50
> Jun 22 08:44:33 RHEL6Beta kernel: [<c073f78b>] ? sock_map_fd+0x1b/0x30
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0741fcd>] ? sys_socketcall+0xed/0x2c0
> Jun 22 08:44:33 RHEL6Beta kernel: [<c0409fdf>] ? sysenter_do_call+0x12/0x28
> Jun 22 08:44:33 RHEL6Beta kernel: Code: 00 00 00 00 00 00 00 00 00 00 00 00 00
> 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 00 00 00 00 <00> 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> Jun 22 08:44:33 RHEL6Beta kernel: EIP: [<f982d140>] 0xf982d140 SS:ESP
> 0068:f3b07bcc
> Jun 22 08:44:33 RHEL6Beta kernel: CR2: 0000000000000000
> Jun 22 08:44:33 RHEL6Beta kernel: ---[ end trace 443475da32e0e7d3 ]---
> Jun 22 08:44:34 RHEL6Beta kernel: BUG: unable to handle kernel paging request
> at 0135b004
> Jun 22 08:44:34 RHEL6Beta kernel: IP: [<c047e34e>] module_put+0x1e/0x90
> Jun 22 08:44:34 RHEL6Beta kernel: *pdpt = 0000000000ab8001 *pde =
> 0000000000000000
> Jun 22 08:44:34 RHEL6Beta kernel: Oops: 0002 [#2] SMP
> Jun 22 08:44:34 RHEL6Beta kernel: last sysfs file:
> /sys/module/inet_diag/initstate
> Jun 22 08:44:34 RHEL6Beta kernel: Modules linked in: p4_clockmod ipv6 dm_mirror
> dm_region_hash dm_log dm_mod snd_intel8x0 snd_ac97_codec ac97_bus snd_seq
> snd_mpu401 snd_mpu401_uart snd_pcm snd_rawmidi snd_seq_device snd_timer snd
> r8169 8139too ppdev 8139cp soundcore mii parport_pc floppy sr_mod cdrom parport
> ns558 gameport sg iTCO_wdt iTCO_vendor_support snd_page_alloc pcspkr i2c_i801
> ext3 jbd mbcache sd_mod crc_t10dif ata_generic pata_acpi ata_piix i915
> drm_kms_helper drm i2c_algo_bit i2c_core video output [last unloaded:
> inet_diag]
> Jun 22 08:44:34 RHEL6Beta kernel:
> Jun 22 08:44:34 RHEL6Beta kernel: Pid: 27392, comm: ss Tainted: G  R   D    
> 2.6.35-rc3 #1 F61MV/AcerPower S100
> Jun 22 08:44:34 RHEL6Beta kernel: EIP: 0060:[<c047e34e>] EFLAGS: 00010286 CPU:
> 0
> Jun 22 08:44:34 RHEL6Beta kernel: EIP is at module_put+0x1e/0x90
> Jun 22 08:44:34 RHEL6Beta kernel: EAX: 00000000 EBX: f982e7a0 ECX: f3b07a00
> EDX: 00000001
> Jun 22 08:44:34 RHEL6Beta kernel: ESI: f5486e00 EDI: f4095ee8 EBP: f5486e1c
> ESP: f3b079e8
> Jun 22 08:44:34 RHEL6Beta kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Jun 22 08:44:34 RHEL6Beta kernel: Process ss (pid: 27392, ti=f3b06000
> task=f4152a50 task.ti=f3b06000)
> Jun 22 08:44:34 RHEL6Beta kernel: Stack:
> Jun 22 08:44:34 RHEL6Beta kernel: f4095e00 f5486e00 f4095ee8 f5486e1c c076e568
> 00000000 c0b641a0 00006b00
> Jun 22 08:44:34 RHEL6Beta kernel: <0> 00000004 f5486e00 00000000 f57c8cf0
> c073f86a 00000000 f5ada600 00000008
> Jun 22 08:44:34 RHEL6Beta kernel: <0> c073f8df f5486e1c c05032ab 00000003
> 00000000 00000000 f7022580 f57c8cf0
> Jun 22 08:44:34 RHEL6Beta kernel: Call Trace:
> Jun 22 08:44:34 RHEL6Beta kernel: [<c076e568>] ? netlink_release+0xe8/0x210
> Jun 22 08:44:34 RHEL6Beta kernel: [<c073f86a>] ? sock_release+0x1a/0x80
> Jun 22 08:44:34 RHEL6Beta kernel: [<c073f8df>] ? sock_close+0xf/0x30
> Jun 22 08:44:34 RHEL6Beta kernel: [<c05032ab>] ? fput+0x10b/0x220
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04fff67>] ? filp_close+0x47/0x80
> Jun 22 08:44:34 RHEL6Beta kernel: [<c044efda>] ? put_files_struct+0x5a/0xb0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c044fbdf>] ? do_exit+0x13f/0x750
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0801d45>] ? apic_timer_interrupt+0x31/0x38
> Jun 22 08:44:34 RHEL6Beta kernel: [<c044e531>] ? kmsg_dump+0x71/0x120
> Jun 22 08:44:34 RHEL6Beta kernel: [<c07ff121>] ? printk+0x17/0x1e
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0802b5c>] ? oops_end+0x8c/0xd0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0431202>] ? no_context+0xc2/0x190
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04314bf>] ? bad_area+0xf/0x20
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0804d44>] ? do_page_fault+0x3c4/0x3f0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c046341a>] ? __request_module+0x12a/0x1c0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0804980>] ? do_page_fault+0x0/0x3f0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0801fb7>] ? error_code+0x73/0x78
> Jun 22 08:44:34 RHEL6Beta kernel: [<c064256f>] ?
> mix_pool_bytes_extract+0x4f/0x150
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0746d84>] ? __alloc_skb+0x54/0x100
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0746d84>] ? __alloc_skb+0x54/0x100
> Jun 22 08:44:34 RHEL6Beta kernel: [<c074333c>] ? sock_rmalloc+0x4c/0x90
> Jun 22 08:44:34 RHEL6Beta kernel: [<c076d6e3>] ? netlink_dump+0x53/0x1b0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04f529e>] ?
> kmem_cache_alloc_notrace+0x9e/0xb0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c076f2e0>] ? netlink_dump_start+0x130/0x1b0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c076f18e>] ? netlink_rcv_skb+0x7e/0xa0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c076eab0>] ? netlink_unicast+0x250/0x280
> Jun 22 08:44:34 RHEL6Beta kernel: [<c076f81c>] ? netlink_sendmsg+0x1bc/0x2a0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0740982>] ? sock_sendmsg+0xd2/0x110
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04374bd>] ? kmap_atomic_prot+0x11d/0x150
> Jun 22 08:44:34 RHEL6Beta kernel: [<c043750c>] ? kmap_atomic+0x1c/0x30
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0437357>] ? kunmap_atomic+0x67/0x80
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04ca242>] ?
> get_page_from_freelist+0x242/0x4d0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c05b8fa5>] ? _copy_from_user+0x35/0x120
> Jun 22 08:44:34 RHEL6Beta kernel: [<c05b8fa5>] ? _copy_from_user+0x35/0x120
> Jun 22 08:44:34 RHEL6Beta kernel: [<c07418e3>] ? sys_sendmsg+0x163/0x260
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04f529e>] ?
> kmem_cache_alloc_notrace+0x9e/0xb0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c05787ed>] ?
> selinux_sk_alloc_security+0x6d/0xe0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04f53ac>] ? kmem_cache_alloc+0xfc/0x120
> Jun 22 08:44:34 RHEL6Beta kernel: [<c074303e>] ? sock_init_data+0xae/0x1d0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c046df2d>] ? creds_are_invalid+0x1d/0x40
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0502ea3>] ? get_empty_filp+0x123/0x1c0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0502fc7>] ? alloc_file+0x87/0xb0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c073f6f6>] ? sock_alloc_file+0xa6/0x120
> Jun 22 08:44:34 RHEL6Beta kernel: [<c04ffeb6>] ? fd_install+0x26/0x50
> Jun 22 08:44:34 RHEL6Beta kernel: [<c073f78b>] ? sock_map_fd+0x1b/0x30
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0741fcd>] ? sys_socketcall+0xed/0x2c0
> Jun 22 08:44:34 RHEL6Beta kernel: [<c0409fdf>] ? sysenter_do_call+0x12/0x28
> Jun 22 08:44:34 RHEL6Beta kernel: Code: e8 b8 f5 13 00 31 c0 c3 90 8d 74 26 00
> 83 ec 10 85 c0 89 1c 24 89 c3 89 74 24 04 89 7c 24 08 89 6c 24 0c 74 1d 8b 80
> 60 01 00 00 <64> ff 40 04 8b 3d e4 4b a1 c0 8b 74 24 10 85 ff 75 18 83 3b 02
> Jun 22 08:44:34 RHEL6Beta kernel: EIP: [<c047e34e>] module_put+0x1e/0x90 SS:ESP
> 0068:f3b079e8
> Jun 22 08:44:34 RHEL6Beta kernel: CR2: 000000000135b004
> Jun 22 08:44:34 RHEL6Beta kernel: ---[ end trace 443475da32e0e7d4 ]---
> 

