From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink
 code
Date: Thu, 30 Aug 2007 18:08:42 -0700
Message-ID: <20070830180842.7c8414fe.akpm@linux-foundation.org>
References: <bug-8961-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, link@miggy.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33706 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757966AbXHaBIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 21:08:51 -0400
In-Reply-To: <bug-8961-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Aug 2007 07:41:31 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8961

This looks serious.

>            Summary: BUG triggered by oidentd in netlink code
>            Product: Other
>            Version: 2.5
>      KernelVersion: 2.6.22.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: other_other@kernel-bugs.osdl.org
>         ReportedBy: link@miggy.org
> 
> 
> Most recent kernel where this bug did not occur: 2.6.21.2
> Distribution: Debian/Etch
> Hardware Environment: uk2.net host server
> lspci says->
> 00:00.0 Host bridge: Intel Corporation 82845G/GL[Brookdale-G]/GE/PE DRAM
> Controller/Host-Hub Interface (rev 03)
> 00:02.0 VGA compatible controller: Intel Corporation 82845G/GL[Brookdale-G]/GE
> Chipset Integrated Graphics Device (rev 03)
> 00:1d.0 USB Controller: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
> USB UHCI Controller #1 (rev 02)
> 00:1d.1 USB Controller: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
> USB UHCI Controller #2 (rev 02)
> 00:1d.2 USB Controller: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
> USB UHCI Controller #3 (rev 02)
> 00:1d.7 USB Controller: Intel Corporation 82801DB/DBM (ICH4/ICH4-M) USB2 EHCI
> Controller (rev 02)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 82)
> 00:1f.0 ISA bridge: Intel Corporation 82801DB/DBL (ICH4/ICH4-L) LPC Interface
> Bridge (rev 02)
> 00:1f.1 IDE interface: Intel Corporation 82801DB (ICH4) IDE Controller (rev 02)
> 00:1f.5 Multimedia audio controller: Intel Corporation 82801DB/DBL/DBM
> (ICH4/ICH4-L/ICH4-M) AC'97 Audio Controller (rev 02)
> 03:06.0 RAID bus controller: 3ware Inc 7xxx/8xxx-series PATA/SATA-RAID (rev 01)
> 03:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> Software Environment: oidentd
> Problem Description:
> Something in oidentd's use of netlink is triggering a BUG
> Steps to reproduce:
> Setup a Debian/Etch box, install oidentd, run a 2.6.22.3 kernel, ensure there
> are sufficient connections to the oidentd service and wait.
> 
> 'Oops' output:
> 
> Aug 29 23:28:44 bowl kernel: [349587.500440] BUG: unable to handle kernel NULL
> pointer dereference<1>BUG: unable to handle kernel NULL pointer dereference at
> virtual address 00000054
> Aug 29 23:28:44 bowl kernel: [349587.500454]  printing eip:
> Aug 29 23:28:45 bowl kernel: [349587.500457] c03318ae
> Aug 29 23:28:45 bowl kernel: [349587.500459] *pde = 00000000
> Aug 29 23:28:45 bowl kernel: [349587.500464] Oops: 0000 [#1]
> Aug 29 23:28:45 bowl kernel: [349587.500466] PREEMPT SMP
> Aug 29 23:28:46 bowl kernel: [349587.500474] Modules linked in: w83627hf
> hwmon_vid i2c_isa
> Aug 29 23:28:46 bowl kernel: [349587.500483] CPU:    0
> Aug 29 23:28:47 bowl kernel: [349587.500485] EIP:    0060:[<c03318ae>]    Not
> tainted VLI
> Aug 29 23:28:47 bowl kernel: [349587.500487] EFLAGS: 00010246   (2.6.22.3 #1)
> Aug 29 23:28:47 bowl kernel: [349587.500499] EIP is at netlink_rcv_skb+0xa/0x7e
> Aug 29 23:28:48 bowl kernel: [349587.500506] eax: 00000000   ebx: 00000000  
> ecx: c148d2a0   edx: c0398819
> Aug 29 23:28:48 bowl kernel: [349587.500510] esi: 00000000   edi: c0398819  
> ebp: c7a21c8c   esp: c7a21c80
> Aug 29 23:28:48 bowl kernel: [349587.500517] ds: 007b   es: 007b   fs: 00d8 
> gs: 0033  ss: 0068
> Aug 29 23:28:50 bowl kernel: [349587.500521] Process oidentd (pid: 17943,
> ti=c7a20000 task=cee231c0 task.ti=c7a20000)
> Aug 29 23:28:51 bowl kernel: [349587.500527] Stack: 00000000 c7a21cac f7c8ba78
> c7a21ca4 c0331962 c0398819 f7c8ba00 0000004c
> Aug 29 23:28:52 bowl kernel: [349587.500542]        f736f000 c7a21cb4 c03988e3
> 00000001 f7c8ba00 c7a21cc4 c03312a5 0000004c
> Aug 29 23:28:54 bowl kernel: [349587.500558]        f7c8ba00 c7a21cd4 c0330681
> f7c8ba00 e4695280 c7a21d00 c03307c6 7fffffff
> Aug 29 23:28:54 bowl kernel: [349587.500578] Call Trace:
> Aug 29 23:28:54 bowl kernel: [349587.500581]  [<c010361a>]
> show_trace_log_lvl+0x1c/0x33
> Aug 29 23:28:55 bowl kernel: [349587.500591]  [<c01036d4>]
> show_stack_log_lvl+0x8d/0xaa
> Aug 29 23:28:57 bowl kernel: [349587.500595]  [<c010390e>]
> show_registers+0x1cb/0x321
> Aug 29 23:28:59 bowl kernel: [349587.500604]  [<c0103bff>] die+0x112/0x1e1
> Aug 29 23:29:00 bowl kernel: [349587.500607]  [<c01132d2>]
> do_page_fault+0x229/0x565
> Aug 29 23:29:05 bowl kernel: [349587.500618]  [<c03c8d3a>] error_code+0x72/0x78
> Aug 29 23:29:07 bowl kernel: [349587.500625]  [<c0331962>]
> netlink_run_queue+0x40/0x76
> Aug 29 23:29:07 bowl kernel: [349587.500632]  [<c03988e3>]
> inet_diag_rcv+0x1f/0x2c
> Aug 29 23:29:07 bowl kernel: [349587.500639]  [<c03312a5>]
> netlink_data_ready+0x57/0x59
> Aug 29 23:29:08 bowl kernel: [349587.500643]  [<c0330681>]
> netlink_sendskb+0x24/0x45
> Aug 29 23:29:08 bowl kernel: [349587.500651]  [<c03307c6>]
> netlink_unicast+0x100/0x116
> Aug 29 23:29:08 bowl kernel: [349587.500656]  [<c0330f83>]
> netlink_sendmsg+0x1c2/0x280
> Aug 29 23:29:09 bowl kernel: [349587.500664]  [<c02fcce9>]
> sock_sendmsg+0xba/0xd5
> Aug 29 23:29:12 bowl kernel: [349587.500671]  [<c02fe4d1>]
> sys_sendmsg+0x17b/0x1e8
> Aug 29 23:29:12 bowl kernel: [349587.500676]  [<c02fe92d>]
> sys_socketcall+0x230/0x24d
> Aug 29 23:29:13 bowl kernel: [349587.500684]  [<c01028d2>] syscall_call+0x7/0xb
> Aug 29 23:29:13 bowl kernel: [349587.500691]  =======================
> Aug 29 23:29:13 bowl kernel: [349587.500693] Code: f0 ff 4e 18 0f 94 c0 84 c0
> 0f 84 66 ff ff ff 89 f0 e8 86 e2 fc ff e9 5a ff ff ff f0 ff 40 10 eb be 55 89
> e5 57 89 d7 56 89 c6 53 <8b> 50 54 83 fa 10 72 55 8b 9e 9c 00 00 00 31 c9 8b 03
> 83 f8 0f
> Aug 29 23:29:13 bowl kernel: [349587.500770] EIP: [<c03318ae>]
> netlink_rcv_skb+0xa/0x7e SS:ESP 0068:c7a21c80
> Aug 29 23:29:13 bowl kernel: [349587.501851]  at virtual address 00000054
> Aug 29 23:29:13 bowl kernel: [349587.501913]  printing eip:
> Aug 29 23:29:14 bowl kernel: [349587.501963] c03318ae
> Aug 29 23:29:14 bowl kernel: [349587.502022] *pde = 00000000
> Aug 29 23:29:15 bowl kernel: [349587.502079] Oops: 0000 [#2]
> Aug 29 23:29:15 bowl kernel: [349587.502136] PREEMPT SMP
> Aug 29 23:29:15 bowl kernel: [349587.502271] Modules linked in: w83627hf
> hwmon_vid i2c_isa
> Aug 29 23:29:16 bowl kernel: [349587.502489] CPU:    1
> Aug 29 23:29:16 bowl kernel: [349587.502490] EIP:    0060:[<c03318ae>]    Not
> tainted VLI
> Aug 29 23:29:17 bowl kernel: [349587.502491] EFLAGS: 00010246   (2.6.22.3 #1)
> Aug 29 23:29:17 bowl kernel: [349587.502647] EIP is at netlink_rcv_skb+0xa/0x7e
> Aug 29 23:29:17 bowl kernel: [349587.502691] eax: 00000000   ebx: 00000000  
> ecx: c14346a0   edx: c0398819
> Aug 29 23:29:17 bowl kernel: [349587.502737] esi: 00000000   edi: c0398819  
> ebp: e37f3c8c   esp: e37f3c80
> Aug 29 23:29:17 bowl kernel: [349587.502783] ds: 007b   es: 007b   fs: 00d8 
> gs: 0033  ss: 0068
> Aug 29 23:29:17 bowl kernel: [349587.502828] Process oidentd (pid: 17945,
> ti=e37f2000 task=dc69e6e0 task.ti=e37f2000)
> Aug 29 23:29:18 bowl kernel: [349587.502875] Stack: 00000000 e37f3cac f7c8ba78
> e37f3ca4 c0331962 c0398819 f7c8ba00 0000004c
> Aug 29 23:29:18 bowl kernel: [349587.503198]        f736f000 e37f3cb4 c03988e3
> 00000001 f7c8ba00 e37f3cc4 c03312a5 0000004c
> Aug 29 23:29:18 bowl kernel: [349587.503519]        f7c8ba00 e37f3cd4 c0330681
> f7c8ba00 e1a35a80 e37f3d00 c03307c6 7fffffff
> Aug 29 23:29:18 bowl kernel: [349587.503839] Call Trace:
> Aug 29 23:29:18 bowl kernel: [349587.503917]  [<c010361a>]
> show_trace_log_lvl+0x1c/0x33
> Aug 29 23:29:18 bowl kernel: [349587.503994]  [<c01036d4>]
> show_stack_log_lvl+0x8d/0xaa
> Aug 29 23:29:18 bowl kernel: [349587.504067]  [<c010390e>]
> show_registers+0x1cb/0x321
> Aug 29 23:29:18 bowl kernel: [349587.504142]  [<c0103bff>] die+0x112/0x1e1
> Aug 29 23:29:18 bowl kernel: [349587.504215]  [<c01132d2>]
> do_page_fault+0x229/0x565
> Aug 29 23:29:18 bowl kernel: [349587.504290]  [<c03c8d3a>] error_code+0x72/0x78
> Aug 29 23:29:18 bowl kernel: [349587.504366]  [<c0331962>]
> netlink_run_queue+0x40/0x76
> Aug 29 23:29:18 bowl kernel: [349587.504440]  [<c03988e3>]
> inet_diag_rcv+0x1f/0x2c
> Aug 29 23:29:18 bowl kernel: [349587.504514]  [<c03312a5>]
> netlink_data_ready+0x57/0x59
> Aug 29 23:29:18 bowl kernel: [349587.504589]  [<c0330681>]
> netlink_sendskb+0x24/0x45
> Aug 29 23:29:18 bowl kernel: [349587.504662]  [<c03307c6>]
> netlink_unicast+0x100/0x116
> Aug 29 23:29:19 bowl kernel: [349587.504736]  [<c0330f83>]
> netlink_sendmsg+0x1c2/0x280
> Aug 29 23:29:19 bowl kernel: [349587.504809]  [<c02fcce9>]
> sock_sendmsg+0xba/0xd5
> Aug 29 23:29:19 bowl kernel: [349587.504885]  [<c02fe4d1>]
> sys_sendmsg+0x17b/0x1e8
> Aug 29 23:29:19 bowl kernel: [349587.504958]  [<c02fe92d>]
> sys_socketcall+0x230/0x24d
> Aug 29 23:29:19 bowl kernel: [349587.505032]  [<c01028d2>] syscall_call+0x7/0xb
> Aug 29 23:29:19 bowl kernel: [349587.505105]  =======================
> Aug 29 23:29:19 bowl kernel: [349587.505146] Code: f0 ff 4e 18 0f 94 c0 84 c0
> 0f 84 66 ff ff ff 89 f0 e8 86 e2 fc ff e9 5a ff ff ff f0 ff 40 10 eb be 55 89
> e5 57 89 d7 56 89 c6 53 <8b> 50 54 83 fa 10 72 55 8b 9e 9c 00 00 00 31 c9 8b 03
> 83 f8 0f
> Aug 29 23:29:19 bowl kernel: [349587.507160] EIP: [<c03318ae>]
> netlink_rcv_skb+0xa/0x7e SS:ESP 0068:e37f3c80
> Aug 29 23:43:48 bowl kernel: [350485.786725] BUG: unable to handle kernel NULL
> pointer dereference<1>BUG: unable to handle kernel NULL pointer dereference at
> virtual address 00000054
> Aug 29 23:43:48 bowl kernel: [350485.786739]  printing eip:
> Aug 29 23:43:48 bowl kernel: [350485.786743] c03318ae
> Aug 29 23:43:48 bowl kernel: [350485.786745] *pde = 00000000
> Aug 29 23:43:48 bowl kernel: [350485.786750] Oops: 0000 [#3]
> Aug 29 23:43:49 bowl kernel: [350485.786751] PREEMPT SMP
> Aug 29 23:43:49 bowl kernel: [350485.786755] Modules linked in: w83627hf
> hwmon_vid i2c_isa
> Aug 29 23:43:49 bowl kernel: [350485.786763] CPU:    0
> Aug 29 23:43:49 bowl kernel: [350485.786765] EIP:    0060:[<c03318ae>]    Not
> tainted VLI
> Aug 29 23:43:49 bowl kernel: [350485.786766] EFLAGS: 00010246   (2.6.22.3 #1)
> Aug 29 23:43:49 bowl kernel: [350485.786781] EIP is at netlink_rcv_skb+0xa/0x7e
> Aug 29 23:43:49 bowl kernel: [350485.786785] eax: 00000000   ebx: 00000000  
> ecx: c148d2a0   edx: c0398819
> Aug 29 23:43:49 bowl kernel: [350485.786789] esi: 00000000   edi: c0398819  
> ebp: dee05c8c   esp: dee05c80
> Aug 29 23:43:50 bowl kernel: [350485.786792] ds: 007b   es: 007b   fs: 00d8 
> gs: 0033  ss: 0068
> Aug 29 23:43:50 bowl kernel: [350485.786795] Process oidentd (pid: 21495,
> ti=dee04000 task=dc69e6e0 task.ti=dee04000)
> Aug 29 23:43:50 bowl kernel: [350485.786798] Stack: 00000000 dee05cac f7c8ba78
> dee05ca4 c0331962 c0398819 f7c8ba00 0000004c
> Aug 29 23:43:50 bowl kernel: [350485.786807]        f736f000 dee05cb4 c03988e3
> 00000001 f7c8ba00 dee05cc4 c03312a5 0000004c
> Aug 29 23:43:51 bowl kernel: [350485.786816]        f7c8ba00 dee05cd4 c0330681
> f7c8ba00 e4695980 dee05d00 c03307c6 7fffffff
> Aug 29 23:43:51 bowl kernel: [350485.786829] Call Trace:
> Aug 29 23:43:51 bowl kernel: [350485.786832]  [<c010361a>]
> show_trace_log_lvl+0x1c/0x33
> Aug 29 23:43:51 bowl kernel: [350485.786839]  [<c01036d4>]
> show_stack_log_lvl+0x8d/0xaa
> Aug 29 23:43:52 bowl kernel: [350485.786844]  [<c010390e>]
> show_registers+0x1cb/0x321
> Aug 29 23:43:52 bowl kernel: [350485.786848]  [<c0103bff>] die+0x112/0x1e1
> Aug 29 23:43:52 bowl kernel: [350485.786852]  [<c01132d2>]
> do_page_fault+0x229/0x565
> Aug 29 23:43:52 bowl kernel: [350485.786859]  [<c03c8d3a>] error_code+0x72/0x78
> Aug 29 23:43:52 bowl kernel: [350485.786870]  [<c0331962>]
> netlink_run_queue+0x40/0x76
> Aug 29 23:43:52 bowl kernel: [350485.786875]  [<c03988e3>]
> inet_diag_rcv+0x1f/0x2c
> Aug 29 23:43:52 bowl kernel: [350485.786880]  [<c03312a5>]
> netlink_data_ready+0x57/0x59
> Aug 29 23:43:53 bowl kernel: [350485.786885]  [<c0330681>]
> netlink_sendskb+0x24/0x45
> Aug 29 23:43:53 bowl kernel: [350485.786889]  [<c03307c6>]
> netlink_unicast+0x100/0x116
> Aug 29 23:43:53 bowl kernel: [350485.786893]  [<c0330f83>]
> netlink_sendmsg+0x1c2/0x280
> Aug 29 23:43:53 bowl kernel: [350485.786898]  [<c02fcce9>]
> sock_sendmsg+0xba/0xd5
> Aug 29 23:43:53 bowl kernel: [350485.786909]  [<c02fe4d1>]
> sys_sendmsg+0x17b/0x1e8
> Aug 29 23:43:53 bowl kernel: [350485.786914]  [<c02fe92d>]
> sys_socketcall+0x230/0x24d
> Aug 29 23:43:53 bowl kernel: [350485.786919]  [<c01028d2>] syscall_call+0x7/0xb
> Aug 29 23:43:53 bowl kernel: [350485.786923]  =======================
> Aug 29 23:43:53 bowl kernel: [350485.786926] Code: f0 ff 4e 18 0f 94 c0 84 c0
> 0f 84 66 ff ff ff 89 f0 e8 86 e2 fc ff e9 5a ff ff ff f0 ff 40 10 eb be 55 89
> e5 57 89 d7 56 89 c6 53 <8b> 50 54 83 fa 10 72 55 8b 9e 9c 00 00 00 31 c9 8b 03
> 83 f8 0f
> Aug 29 23:43:53 bowl kernel: [350485.786976] EIP: [<c03318ae>]
> netlink_rcv_skb+0xa/0x7e SS:ESP 0068:dee05c80
> Aug 29 23:43:53 bowl kernel: [350485.790485]  at virtual address 00000054
> Aug 29 23:43:53 bowl kernel: [350485.790557]  printing eip:
> Aug 29 23:43:53 bowl kernel: [350485.790613] c03318ae
> Aug 29 23:43:53 bowl kernel: [350485.790665] *pde = 00000000
> Aug 29 23:43:53 bowl kernel: [350485.790727] Oops: 0000 [#4]
> Aug 29 23:43:53 bowl kernel: [350485.790779] PREEMPT SMP
> Aug 29 23:43:53 bowl kernel: [350485.790907] Modules linked in: w83627hf
> hwmon_vid i2c_isa
> Aug 29 23:43:53 bowl kernel: [350485.791103] CPU:    1
> Aug 29 23:43:53 bowl kernel: [350485.791104] EIP:    0060:[<c03318ae>]    Not
> tainted VLI
> Aug 29 23:43:54 bowl kernel: [350485.791106] EFLAGS: 00010246   (2.6.22.3 #1)
> Aug 29 23:43:54 bowl kernel: [350485.791241] EIP is at netlink_rcv_skb+0xa/0x7e
> Aug 29 23:43:56 bowl kernel: [350485.791286] eax: 00000000   ebx: 00000000  
> ecx: c153a920   edx: c0398819
> Aug 29 23:43:57 bowl kernel: [350485.791336] esi: 00000000   edi: c0398819  
> ebp: eaa85c8c   esp: eaa85c80
> Aug 29 23:43:57 bowl kernel: [350485.791389] ds: 007b   es: 007b   fs: 00d8 
> gs: 0033  ss: 0068
> Aug 29 23:43:57 bowl kernel: [350485.791441] Process oidentd (pid: 21497,
> ti=eaa84000 task=caca0330 task.ti=eaa84000)
> Aug 29 23:43:57 bowl kernel: [350485.791492] Stack: 00000000 eaa85cac f7c8ba78
> eaa85ca4 c0331962 c0398819 f7c8ba00 0000004c
> Aug 29 23:43:57 bowl kernel: [350485.791825]        f736f000 eaa85cb4 c03988e3
> 00000001 f7c8ba00 eaa85cc4 c03312a5 0000004c
> Aug 29 23:43:57 bowl kernel: [350485.792158]        f7c8ba00 eaa85cd4 c0330681
> f7c8ba00 e9d49180 eaa85d00 c03307c6 7fffffff
> Aug 29 23:43:57 bowl kernel: [350485.792491] Call Trace:
> Aug 29 23:43:57 bowl kernel: [350485.792572]  [<c010361a>]
> show_trace_log_lvl+0x1c/0x33
> Aug 29 23:43:57 bowl kernel: [350485.792653]  [<c01036d4>]
> show_stack_log_lvl+0x8d/0xaa
> Aug 29 23:43:57 bowl kernel: [350485.792731]  [<c010390e>]
> show_registers+0x1cb/0x321
> Aug 29 23:43:58 bowl kernel: [350485.792808]  [<c0103bff>] die+0x112/0x1e1
> Aug 29 23:43:58 bowl kernel: [350485.792885]  [<c01132d2>]
> do_page_fault+0x229/0x565
> Aug 29 23:43:58 bowl kernel: [350485.792963]  [<c03c8d3a>] error_code+0x72/0x78
> Aug 29 23:43:58 bowl kernel: [350485.793043]  [<c0331962>]
> netlink_run_queue+0x40/0x76
> Aug 29 23:43:58 bowl kernel: [350485.793123]  [<c03988e3>]
> inet_diag_rcv+0x1f/0x2c
> Aug 29 23:43:58 bowl kernel: [350485.793208]  [<c03312a5>]
> netlink_data_ready+0x57/0x59
> Aug 29 23:43:58 bowl kernel: [350485.793290]  [<c0330681>]
> netlink_sendskb+0x24/0x45
> Aug 29 23:43:58 bowl kernel: [350485.793373]  [<c03307c6>]
> netlink_unicast+0x100/0x116
> Aug 29 23:43:59 bowl kernel: [350485.793455]  [<c0330f83>]
> netlink_sendmsg+0x1c2/0x280
> Aug 29 23:43:59 bowl kernel: [350485.793538]  [<c02fcce9>]
> sock_sendmsg+0xba/0xd5
> Aug 29 23:43:59 bowl kernel: [350485.793641]  [<c02fe4d1>]
> sys_sendmsg+0x17b/0x1e8
> Aug 29 23:43:59 bowl kernel: [350485.793732]  [<c02fe92d>]
> sys_socketcall+0x230/0x24d
> Aug 29 23:43:59 bowl kernel: [350485.793822]  [<c01028d2>] syscall_call+0x7/0xb
> Aug 29 23:44:00 bowl kernel: [350485.793919]  =======================
> Aug 29 23:44:00 bowl kernel: [350485.793964] Code: f0 ff 4e 18 0f 94 c0 84 c0
> 0f 84 66 ff ff ff 89 f0 e8 86 e2 fc ff e9 5a ff ff ff f0 ff 40 10 eb be 55 89
> e5 57 89 d7 56 89 c6 53 <8b> 50 54 83 fa 10 72 55 8b 9e 9c 00 00 00 31 c9 8b 03
> 83 f8 0f
> Aug 29 23:44:00 bowl kernel: [350485.796458] EIP: [<c03318ae>]
> netlink_rcv_skb+0xa/0x7e SS:ESP 0068:eaa85c80
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
