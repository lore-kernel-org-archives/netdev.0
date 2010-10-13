From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 20292] New: unable to handle kernel NULL
 pointer dereference in skb_dequeue
Date: Wed, 13 Oct 2010 12:33:32 -0700
Message-ID: <20101013123332.72cf90f8.akpm@linux-foundation.org>
References: <bug-20292-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Michal Ostrowski <mostrows@earthlink.net>, gvs@zemos.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55736 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752252Ab0JMTeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 15:34:16 -0400
In-Reply-To: <bug-20292-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 13 Oct 2010 19:24:53 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=20292
> 
>            Summary: unable to handle kernel NULL pointer dereference in
>                     skb_dequeue
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.36-rc7

Thanks.  Do you know if this is a regression?  Did it work OK on 2.6.35?

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: gvs@zemos.net
>         Regression: No
> 
> 
> Created an attachment (id=33512)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=33512)
> Kernel config (gzipped)
> 
> I was trying to get pppoe working (the 'pon' command seemed to hang) and then
> this happened:
> 
> Oct 13 20:57:07 bes kernel: BUG: unable to handle kernel NULL pointer
> dereference at (null)
> Oct 13 20:57:07 bes kernel: IP: [<c1241674>] skb_dequeue+0x24/0x40
> Oct 13 20:57:07 bes kernel: *pde = 00000000
> Oct 13 20:57:07 bes kernel: Oops: 0002 [#1]
> Oct 13 20:57:07 bes kernel: last sysfs file:
> /sys/devices/virtual/net/ppp0/uevent
> Oct 13 20:57:07 bes kernel: Modules linked in: xt_TCPMSS xt_tcpmss xt_tcpudp
> iptable_mangle pppoe pppox ppp_generic slhc cpufreq_conservative
> cpufreq_userspace cpufreq_powersave fuse ipt_MASQUERADE iptable_nat nf_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables
> x_tables loop sd_mod usb_storage usblp i2c_viapro uhci_hcd fan ehci_hcd button
> i2c_core
> Oct 13 20:57:07 bes kernel:
> Oct 13 20:57:07 bes kernel: Pid: 5495, comm: pppd Not tainted 2.6.36-rc7 #12
> VX800 /VX800
> Oct 13 20:57:07 bes kernel: EIP: 0060:[<c1241674>] EFLAGS: 00010046 CPU: 0
> Oct 13 20:57:07 bes kernel: EIP is at skb_dequeue+0x24/0x40
> Oct 13 20:57:07 bes kernel: EAX: 00000000 EBX: 00000202 ECX: f6ba4cc0 EDX:
> 00000000
> Oct 13 20:57:07 bes kernel: ESI: f6c93bc0 EDI: f6adfee4 EBP: f6ade000 ESP:
> f6adfe68
> Oct 13 20:57:07 bes kernel: DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> Oct 13 20:57:07 bes kernel: Process pppd (pid: 5495, ti=f6ade000 task=f70f2200
> task.ti=f6ade000)
> Oct 13 20:57:07 bes kernel: Stack:
> Oct 13 20:57:07 bes kernel: f68836c4 c1243a94 f68836c0 f866825b 00000000
> f72e4a00 f72e4a00 f86761cb
> Oct 13 20:57:07 bes kernel: <0> f72e4a00 f8683c97 c143ea14 ffffffea c12ba92d
> 00000286 f68f7d7c f6adfee4
> Oct 13 20:57:07 bes kernel: <0> f68f7bfc 00000286 00000000 00000000 00000000
> f68f7b9c f6adff68 f6adff64
> Oct 13 20:57:07 bes kernel: Call Trace:
> Oct 13 20:57:07 bes kernel: [<c1243a94>] ? skb_queue_purge+0x14/0x30
> Oct 13 20:57:07 bes kernel: [<f866825b>] ? ppp_destroy_channel+0x1b/0x50
> [ppp_generic]
> Oct 13 20:57:07 bes kernel: [<f86761cb>] ? pppox_unbind_sock+0x1b/0x24 [pppox]
> Oct 13 20:57:07 bes kernel: [<f8683c97>] ? pppoe_connect+0x87/0x4b0 [pppoe]
> Oct 13 20:57:07 bes kernel: [<c12ba92d>] ? schedule_timeout+0xfd/0x150
> Oct 13 20:57:07 bes kernel: [<c123d4d4>] ? sys_connect+0x84/0xd0
> Oct 13 20:57:07 bes kernel: [<c10ba730>] ? do_lock_file_wait+0x30/0xf0
> Oct 13 20:57:07 bes kernel: [<c10ba9f9>] ? fcntl_setlk+0x59/0x1b0
> Oct 13 20:57:07 bes kernel: [<c123e5a4>] ? sys_socketcall+0x294/0x2c0
> Oct 13 20:57:07 bes kernel: [<c1002a10>] ? sysenter_do_call+0x12/0x26
> Oct 13 20:57:07 bes kernel: Code: 81 a8 00 00 00 5b c3 53 9c 5b fa 8b 08 39 c8
> 74 25 85 c9 74 1b 83 68 08 01 8b 11 8b 41 04 c7 01 00 00 00 00 c7 41 04 00 00
> 00 00 <89> 10 89 42 04 53 9d 89 c8 5b c3 31 c9 eb f6 8d b6 00 00 00 00
> Oct 13 20:57:07 bes kernel: EIP: [<c1241674>] skb_dequeue+0x24/0x40 SS:ESP
> 0068:f6adfe68
> Oct 13 20:57:07 bes kernel: CR2: 0000000000000000
> Oct 13 20:57:07 bes kernel: ---[ end trace 4914adf67d1ace25 ]---
> 
> Oct 13 20:57:30 bes kernel: BUG: unable to handle kernel NULL pointer
> dereference at (null)
> Oct 13 20:57:30 bes kernel: IP: [<c1241674>] skb_dequeue+0x24/0x40
> Oct 13 20:57:30 bes kernel: *pde = 00000000
> Oct 13 20:57:30 bes kernel: Oops: 0002 [#2]
> Oct 13 20:57:30 bes kernel: last sysfs file:
> /sys/devices/virtual/net/ppp0/uevent
> Oct 13 20:57:30 bes kernel: Modules linked in: xt_TCPMSS xt_tcpmss xt_tcpudp
> iptable_mangle pppoe pppox ppp_generic slhc cpufreq_conservative
> cpufreq_userspace cpufreq_powersave fuse ipt_MASQUERADE iptable_nat nf_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables
> x_tables loop sd_mod usb_storage usblp i2c_viapro uhci_hcd fan ehci_hcd button
> i2c_core
> Oct 13 20:57:30 bes kernel:
> Oct 13 20:57:30 bes kernel: Pid: 5445, comm: pppd Tainted: G      D    
> 2.6.36-rc7 #12 VX800 /VX800
> Oct 13 20:57:30 bes kernel: EIP: 0060:[<c1241674>] EFLAGS: 00010046 CPU: 0
> Oct 13 20:57:30 bes kernel: EIP is at skb_dequeue+0x24/0x40
> Oct 13 20:57:30 bes kernel: EAX: 00000000 EBX: 00000202 ECX: f6ae7200 EDX:
> 00000000
> Oct 13 20:57:30 bes kernel: ESI: f6c99080 EDI: f7161ee4 EBP: f7160000 ESP:
> f7161e68
> Oct 13 20:57:30 bes kernel: DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> Oct 13 20:57:30 bes kernel: Process pppd (pid: 5445, ti=f7160000 task=f7107280
> task.ti=f7160000)
> Oct 13 20:57:30 bes kernel: Stack:
> Oct 13 20:57:30 bes kernel: f6883344 c1243a94 f6883340 f866825b 00000000
> f72e4c00 f72e4c00 f86761cb
> Oct 13 20:57:30 bes kernel: <0> f72e4c00 f8683c97 c143ea14 ffffffea c12ba92d
> 00000286 f68f73bc f7161ee4
> Oct 13 20:57:30 bes kernel: <0> f68f753c 00000286 00000000 00000000 00000000
> f68f759c f7161f68 f7161f64
> Oct 13 20:57:30 bes kernel: [<c1243a94>] ? skb_queue_purge+0x14/0x30
> Oct 13 20:57:30 bes kernel: [<f866825b>] ? ppp_destroy_channel+0x1b/0x50
> [ppp_generic]
> Oct 13 20:57:30 bes kernel: [<f86761cb>] ? pppox_unbind_sock+0x1b/0x24 [pppox]
> Oct 13 20:57:30 bes kernel: [<f8683c97>] ? pppoe_connect+0x87/0x4b0 [pppoe]
> Oct 13 20:57:30 bes kernel: [<c12ba92d>] ? schedule_timeout+0xfd/0x150
> Oct 13 20:57:30 bes kernel: [<c123d4d4>] ? sys_connect+0x84/0xd0
> Oct 13 20:57:30 bes kernel: [<c10ba730>] ? do_lock_file_wait+0x30/0xf0
> Oct 13 20:57:30 bes kernel: [<c10ba9f9>] ? fcntl_setlk+0x59/0x1b0
> Oct 13 20:57:30 bes kernel: [<c123e5a4>] ? sys_socketcall+0x294/0x2c0
> Oct 13 20:57:30 bes kernel: [<c1002a10>] ? sysenter_do_call+0x12/0x26
> Oct 13 20:57:30 bes kernel: Code: 81 a8 00 00 00 5b c3 53 9c 5b fa 8b 08 39 c8
> 74 25 85 c9 74 1b 83 68 08 01 8b 11 8b 41 04 c7 01 00 00 00 00 c7 41 04 00 00
> 00 00 <89> 10 89 42 04 53 9d 89 c8 5b c3 31 c9 eb f6 8d b6 00 00 00 00
> Oct 13 20:57:30 bes kernel: EIP: [<c1241674>] skb_dequeue+0x24/0x40 SS:ESP
> 0068:f7161e68
> Oct 13 20:57:30 bes kernel: CR2: 0000000000000000
> Oct 13 20:57:30 bes kernel: ---[ end trace 4914adf67d1ace26 ]---
> Oct 13 20:57:30 bes kernel: ------------[ cut here ]------------
> Oct 13 20:57:30 bes kernel: WARNING: at kernel/softirq.c:143
> local_bh_enable+0x60/0x90()
> Oct 13 20:57:30 bes kernel: Hardware name: VX800
> Oct 13 20:57:30 bes kernel: Modules linked in: xt_TCPMSS xt_tcpmss xt_tcpudp
> iptable_mangle pppoe pppox ppp_generic slhc cpufreq_conservative
> cpufreq_userspace cpufreq_powersave fuse ipt_MASQUERADE iptable_nat nf_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables
> x_tables loop sd_mod usb_storage usblp i2c_viapro uhci_hcd fan ehci_hcd button
> i2c_core
> Oct 13 20:57:30 bes kernel: Pid: 5445, comm: pppd Tainted: G      D    
> 2.6.36-rc7 #12
> Oct 13 20:57:30 bes kernel: Call Trace:
> Oct 13 20:57:30 bes kernel: [<c1028640>] ? local_bh_enable+0x60/0x90
> Oct 13 20:57:30 bes kernel: [<c1028640>] ? local_bh_enable+0x60/0x90
> Oct 13 20:57:30 bes kernel: [<c1023a1e>] ? warn_slowpath_common+0x7e/0xc0
> Oct 13 20:57:30 bes kernel: [<c1028640>] ? local_bh_enable+0x60/0x90
> Oct 13 20:57:30 bes kernel: [<c1023a7b>] ? warn_slowpath_null+0x1b/0x20
> Oct 13 20:57:30 bes kernel: [<c1028640>] ? local_bh_enable+0x60/0x90
> Oct 13 20:57:30 bes kernel: [<c12a5bb5>] ? unix_release_sock+0x45/0x1f0
> Oct 13 20:57:30 bes kernel: [<c123dc4a>] ? sock_release+0x1a/0x80
> Oct 13 20:57:30 bes kernel: [<c123dcbf>] ? sock_close+0xf/0x30
> Oct 13 20:57:30 bes kernel: [<c1089cd9>] ? fput+0xb9/0x200
> Oct 13 20:57:30 bes kernel: [<c1086f7e>] ? filp_close+0x3e/0x70
> Oct 13 20:57:30 bes kernel: [<c10254b2>] ? put_files_struct+0x62/0xb0
> Oct 13 20:57:30 bes kernel: [<c1026c47>] ? do_exit+0x567/0x630
> Oct 13 20:57:30 bes kernel: [<c12ba037>] ? printk+0x17/0x20
> Oct 13 20:57:30 bes kernel: [<c1005477>] ? oops_end+0x87/0x90
> Oct 13 20:57:30 bes kernel: [<c12ba037>] ? printk+0x17/0x20
> Oct 13 20:57:30 bes kernel: [<c10194a2>] ? no_context+0xc2/0x160
> Oct 13 20:57:30 bes kernel: [<c10195a5>] ? __bad_area_nosemaphore+0x65/0x180
> Oct 13 20:57:30 bes kernel: [<c1249a3b>] ? dev_txq_stats_fold+0x8b/0xf0
> Oct 13 20:57:30 bes kernel: [<c117dc80>] ? __nla_reserve+0x40/0x60
> Oct 13 20:57:30 bes kernel: [<c1255c33>] ? rtnl_fill_ifinfo+0x413/0x8d0
> Oct 13 20:57:30 bes kernel: [<c101971a>] ? bad_area+0x3a/0x50
> Oct 13 20:57:30 bes kernel: [<c1019b8e>] ? do_page_fault+0x33e/0x390
> Oct 13 20:57:30 bes kernel: [<c101e6ab>] ? wakeup_preempt_entity+0x3b/0xa0
> Oct 13 20:57:30 bes kernel: [<c101e79a>] ? check_preempt_wakeup+0x8a/0xe0
> Oct 13 20:57:30 bes kernel: [<c1097675>] ? pollwake+0x65/0x80
> Oct 13 20:57:30 bes kernel: [<c1021170>] ? default_wake_function+0x0/0x10
> Oct 13 20:57:30 bes kernel: [<c1019850>] ? do_page_fault+0x0/0x390
> Oct 13 20:57:30 bes kernel: [<c12bbcf0>] ? error_code+0x58/0x60
> Oct 13 20:57:30 bes kernel: [<c1019850>] ? do_page_fault+0x0/0x390
> Oct 13 20:57:30 bes kernel: [<c1241674>] ? skb_dequeue+0x24/0x40
> Oct 13 20:57:30 bes kernel: [<c1243a94>] ? skb_queue_purge+0x14/0x30
> Oct 13 20:57:30 bes kernel: [<f866825b>] ? ppp_destroy_channel+0x1b/0x50
> [ppp_generic]
> Oct 13 20:57:30 bes kernel: [<f86761cb>] ? pppox_unbind_sock+0x1b/0x24 [pppox]
> Oct 13 20:57:30 bes kernel: [<f8683c97>] ? pppoe_connect+0x87/0x4b0 [pppoe]
> Oct 13 20:57:30 bes kernel: [<c12ba92d>] ? schedule_timeout+0xfd/0x150
> Oct 13 20:57:30 bes kernel: [<c123d4d4>] ? sys_connect+0x84/0xd0
> Oct 13 20:57:30 bes kernel: [<c10ba730>] ? do_lock_file_wait+0x30/0xf0
> Oct 13 20:57:30 bes kernel: [<c10ba9f9>] ? fcntl_setlk+0x59/0x1b0
> Oct 13 20:57:30 bes kernel: [<c123e5a4>] ? sys_socketcall+0x294/0x2c0
> Oct 13 20:57:30 bes kernel: [<c1002a10>] ? sysenter_do_call+0x12/0x26
> Oct 13 20:57:30 bes kernel: ---[ end trace 4914adf67d1ace27 ]---
> 
> Some other information:
> /proc/version:
> Linux version 2.6.36-rc7 (root@bes) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #12
> Sun Oct 10 21:12:58 CEST 2010
> 
> ver_linux:
> Linux bes 2.6.36-rc7 #12 Sun Oct 10 21:12:58 CEST 2010 i686 GNU/Linux
> 
> Gnu C                  4.4.5
> Gnu make               3.81
> binutils               2.20.1
> util-linux             2.17.2
> mount                  support
> module-init-tools      3.12
> e2fsprogs              1.41.12
> PPP                    2.4.5
> Linux C Library        2.11.2
> Dynamic linker (ldd)   2.11.2
> Procps                 3.2.8
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               8.5
> Modules Loaded         cpufreq_conservative cpufreq_userspace cpufreq_powersave
> fuse ppp_generic slhc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
> nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables x_tables loop
> sd_mod usb_storage usblp i2c_viapro uhci_hcd fan i2c_core ehci_hcd button
> 
> cpuinfo:
> processor       : 0
> vendor_id       : CentaurHauls
> cpu family      : 6
> model           : 13
> model name      : VIA Eden Processor 1600MHz
> stepping        : 0
> cpu MHz         : 800.000
> cache size      : 128 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 1
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge cmov pat
> clflush acpi mmx fxsr sse sse2 tm nx pni est tm2 xtpr rng rng_en ace ace_en
> ace2 ace2_en phe phe_en pmm pmm_en
> bogomips        : 1599.76
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 32 bits virtual
> power management:
> 
> If anything else is needed I'd be happy to assist.
> 

