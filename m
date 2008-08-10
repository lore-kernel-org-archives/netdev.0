From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Sat, 9 Aug 2008 21:31:01 -0700
Message-ID: <20080809213101.0927a808.akpm@linux-foundation.org>
References: <bug-11297-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	brian.haley@hp.com
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39809 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750739AbYHJEbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 00:31:08 -0400
In-Reply-To: <bug-11297-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 Aug 2008 17:26:17 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11297
> 
>            Summary: OOPS in rt6_fill_node
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: parag.warudkar@gmail.com
> 
> 
> Latest working kernel version: 2.6.26-rc4
> Earliest failing kernel version: 2.6.26

Can you please confirm the version numbers here?  2.6.26-rc4 was OK,
but 2.6.26 and 2.6.27-rc2 are busted?

Brian had a patch but apparently things still aren't right (see the
full bugzilla report for details).


> Distribution: NA
> Hardware Environment: x86
> Software Environment: ip
> Problem Description: 
> 
> $ ip -f inet6 route get fec0::1
> 
> Produces this oops -
> BUG: unable to handle kernel NULL pointer dereference at 00000000
> 
> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
> 
> *pdpt = 0000000036466001 *pde = 0000000000000000
> 
> Oops: 0000 [#1] SMP
> 
> Modules linked in: pcnet32 smsc47m192 i2c_i801 i2c_dev i2c_core r8169
> coretemp i
> t87 hwmon_vid lcm e1000e
> 
> Pid: 3033, comm: ip Not tainted (2.6.26.2 #1)
> 
> EIP: 0060:[<c0369b85>] EFLAGS: 00010246 CPU: 1
> 
> EIP is at rt6_fill_node+0x175/0x3b0
> 
> EAX: 00000000 EBX: f7115bbc ECX: 00000000 EDX: f7115c60
> 
> ESI: f7c1f100 EDI: f7548f00 EBP: f7115bdc ESP: f7115ba4
> 
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> 
> Process ip (pid: 3033, ti=f7114000 task=f64cbc50 task.ti=f7114000)
> 
> Stack: f7115bbc 00000000 f7115c54 f7115bc0 f7115c60 f6d75078 00000000
> f7115bdc  
>        c036a5f0 c036b360 00000000 f75487a0 00000000 f7548f00 f7115c9c
> c036c30e  
>        f7115c70 00000000 00000018 00000bd9 489b2024 00000000 00000000
> 00000000  
> Call Trace:
> 
>  [<c036a5f0>] ? ip6_route_output+0x50/0xa0
> 
>  [<c036b360>] ? ip6_pol_route_output+0x0/0x20
> 
>  [<c036c30e>] ? inet6_rtm_getroute+0x16e/0x200
> 
>  [<c036c1a0>] ? inet6_rtm_getroute+0x0/0x200
> 
>  [<c030ef19>] ? rtnetlink_rcv_msg+0x1b9/0x1f0
> 
>  [<c030ed60>] ? rtnetlink_rcv_msg+0x0/0x1f0
> 
>  [<c031426d>] ? netlink_rcv_skb+0x8d/0xb0
> 
>  [<c030ed57>] ? rtnetlink_rcv+0x17/0x20
> 
>  [<c031402d>] ? netlink_unicast+0x23d/0x270
> 
>  [<c030162a>] ? memcpy_fromiovec+0x4a/0x70
> 
>  [<c0314811>] ? netlink_sendmsg+0x1c1/0x290
> 
>  [<c02fa165>] ? sock_sendmsg+0xc5/0xf0
> 
>  [<c01363a0>] ? autoremove_wake_function+0x0/0x50
> 
>  [<c01363a0>] ? autoremove_wake_function+0x0/0x50
> 
>  [<c02fa165>] ? sock_sendmsg+0xc5/0xf0
> 
>  [<c0217f37>] ? copy_from_user+0x37/0x70
> 
>  [<c03018ec>] ? verify_iovec+0x2c/0x90
> 
>  [<c02fa29a>] ? sys_sendmsg+0x10a/0x220
> 
>  [<c015ab08>] ? __inc_zone_page_state+0x18/0x20
> 
>  [<c01642ed>] ? __page_set_anon_rmap+0x2d/0x40
> 
>  [<c0164325>] ? page_add_new_anon_rmap+0x25/0x30
> 
>  [<c015eda6>] ? handle_mm_fault+0x606/0x750
> 
>  [<c0160f5e>] ? vma_adjust+0xfe/0x410
> 
>  [<c0113156>] ? do_page_fault+0x126/0x830
> 
>  [<c02fb343>] ? sys_socketcall+0x233/0x260
> 
>  [<c0102f39>] ? sysenter_past_esp+0x6a/0x91
> 
>  =======================
> 
> Code: 62 01 00 00 c6 43 01 80 8b 45 0c 85 c0 0f 85 13 02 00 00 8b 45 d8
> 85 c0 74
>  3c 8b 86 88 00 00 00 8d 5d e0 31 c9 89 1c 24 8b 55 d8 <8b> 00 e8 d4 e3
> ff ff 85
>  c0 75 20 b9 10 00 00 00 ba 07 00 00 00
> 
> EIP: [<c0369b85>] rt6_fill_node+0x175/0x3b0 SS:ESP 0068:f7115ba4
> 
> ---[ end trace e9f2563374550ae8 ]---
> 
> 
> Steps to reproduce:
> $ ip -f inet6 route get fec0::1
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
