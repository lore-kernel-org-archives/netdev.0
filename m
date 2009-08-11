From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13954] New: Oops in rtnetlink code when
 creating can device
Date: Mon, 10 Aug 2009 21:54:36 -0700
Message-ID: <20090810215436.0bf47297.akpm@linux-foundation.org>
References: <bug-13954-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34410 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751851AbZHKLyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:54:52 -0400
In-Reply-To: <bug-13954-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 10 Aug 2009 11:34:28 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13954

Thanks.

>            Summary: Oops in rtnetlink code when creating can device
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30-rc5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: dbaryshkov@gmail.com
>         Regression: No
> 
> 
> I've got a nice oops when looking around new CAN code in kernel.
> 
> root@qemux86:~# ip link add type can
> [  713.113325] BUG: unable to handle kernel NULL pointer dereference at (null)
> [  713.114216] IP: [<c13eecab>] register_netdevice+0xab/0x420
> [  713.114920] *pdpt = 00000000061bd001 *pde = 0000000000000000 
> [  713.115627] Oops: 0000 [#1] SMP 
> [  713.115972] last sysfs file:
> /sys/devices/virtual/backlight/fujitsu-laptop/brightness
> [  713.116137] Modules linked in:
> [  713.116137] 
> [  713.116137] Pid: 1803, comm: ip Not tainted (2.6.31-rc5 #68) 
> [  713.116137] EIP: 0060:[<c13eecab>] EFLAGS: 00000246 CPU: 0
> [  713.116137] EIP is at register_netdevice+0xab/0x420
> [  713.116137] EAX: 00000000 EBX: 00000000 ECX: 00000001 EDX: 00000001
> [  713.116137] ESI: c72c6000 EDI: 00000000 EBP: c61abb54 ESP: c61abb34
> [  713.116137]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [  713.116137] Process ip (pid: 1803, ti=c61aa000 task=c6f395e0
> task.ti=c61aa000)
> [  713.116137] Stack:
> [  713.116137]  c61abb54 c13f732f 00000001 c61abbb4 894f908a 00000000 c72c6000
> 00000000
> [  713.116137] <0> c61abc74 c13f8278 c61abbb4 00000010 c165d494 c1652090
> c61abc18 c6f3d028
> [  713.116137] <0> 894f908a 894f908a c61abc18 c13f7da0 c61abc74 c13f7f46
> 00000008 c1546f80
> [  713.116137] Call Trace:
> [  713.116137]  [<c13f732f>] ? rtnl_create_link+0x4f/0x130
> [  713.116137]  [<c13f8278>] ? rtnl_newlink+0x4d8/0x4e0
> [  713.116137]  [<c13f7da0>] ? rtnl_newlink+0x0/0x4e0
> [  713.116137]  [<c13f7f46>] ? rtnl_newlink+0x1a6/0x4e0
> [  713.116137]  [<c13f7da0>] ? rtnl_newlink+0x0/0x4e0
> [  713.116137]  [<c13f7d00>] ? rtnetlink_rcv_msg+0x180/0x220
> [  713.116137]  [<c13f7b80>] ? rtnetlink_rcv_msg+0x0/0x220
> [  713.116137]  [<c1400e56>] ? netlink_rcv_skb+0x86/0xb0
> [  713.116137]  [<c13f7b5a>] ? rtnetlink_rcv+0x2a/0x50
> [  713.116137]  [<c140085b>] ? netlink_unicast+0x29b/0x2b0
> [  713.116137]  [<c1400a5b>] ? netlink_sendmsg+0x1eb/0x2f0
> [  713.116137]  [<c13db72b>] ? sock_sendmsg+0xdb/0x110
> [  713.116137]  [<c10bef17>] ? __d_instantiate+0x57/0xe0
> [  713.116137]  [<c1053cd0>] ? autoremove_wake_function+0x0/0x60
> [  713.116137]  [<c110a75f>] ? ext3_lookup+0xaf/0x130
> [  713.116137]  [<c10bfd24>] ? d_alloc+0x114/0x1a0
> [  713.116137]  [<c10c5a95>] ? mntput_no_expire+0x25/0xe0
> [  713.116137]  [<c11b518e>] ? copy_from_user+0x3e/0x150
> [  713.116137]  [<c11b518e>] ? copy_from_user+0x3e/0x150
> [  713.116137]  [<c13e55cb>] ? verify_iovec+0x3b/0xc0
> [  713.116137]  [<c13db8b8>] ? sys_sendmsg+0x158/0x280
> [  713.116137]  [<c107a22c>] ? unlock_page+0x4c/0x70
> [  713.116137]  [<c108efb8>] ? __do_fault+0x378/0x470
> [  713.116137]  [<c10a81d3>] ? lookup_object+0x33/0x80
> [  713.116137]  [<c107a820>] ? filemap_fault+0x0/0x3c0
> [  713.116137]  [<c1029ba9>] ? kmemcheck_mark_freed+0x19/0x40
> [  713.116137]  [<c11b518e>] ? copy_from_user+0x3e/0x150
> [  713.116137]  [<c13dcd97>] ? sys_socketcall+0xb7/0x290
> [  713.116137]  [<c10230fa>] ? do_page_fault+0x18a/0x2a0
> [  713.116137]  [<c100324f>] ? sysenter_do_call+0x12/0x26
> [  713.116137] Code: ff ff 3b 96 84 02 00 00 72 d6 8b 86 b4 00 00 00 c7 86 00
> 02 00 00 00 00 00 00 c7 86 04 02 00 00 ff ff ff ff c7 46 4c ff ff ff ff <8b> 10
> 85 d2 74 2f 89 f0 ff d2 83 f8 00 89 c7 74 24 b8 fb ff ff 
> [  713.116137] EIP: [<c13eecab>] register_netdevice+0xab/0x420 SS:ESP
> 0068:c61abb34
> [  713.116137] CR2: 0000000000000000
> [  713.142874] ---[ end trace 883d4085b7c1045b ]---
> 

Boy, the backtrace is a bit hard to follow.  Maybe enabling frame
pointers would clean it up.

