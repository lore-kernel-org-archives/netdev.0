From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] bonding: add the debugfs interface to see RLB
 hash table
Date: Thu, 09 Dec 2010 19:43:26 +0900
Message-ID: <4D00B2CE.9030304@jp.fujitsu.com>
References: <4CF89A00.8030902@jp.fujitsu.com> <3778.1291840382@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:57926 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756592Ab0LIKoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 05:44:06 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB9Ai22C019534
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 9 Dec 2010 19:44:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E59A345DE5C
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 19:44:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C481545DE5B
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 19:44:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F6251DB8038
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 19:44:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C2CEE08001
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 19:44:01 +0900 (JST)
In-Reply-To: <3778.1291840382@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

> 	After applying your patches to net-next-2.6, I'm seeing the
> following crash when executing "rmmod bonding":
> 
> BUG: unable to handle kernel paging request at 6b6b6b9f
> IP: [<c0201f11>] debugfs_remove_recursive+0x1e/0x11a
> *pde = 00000000
> Oops: 0000 [#1] PREEMPT SMP
> last sysfs file: /sys/devices/virtual/net/bond0/flags
> Modules linked in: bonding(-) ipv6 mperf microcode loop tg3 e1000 libphy sworks_agp agpgart edd ext3 mbcache jbd pata_serverworks mptspi mptscsih mptbase [last unloaded: speedstep_lib]
> 
> Pid: 5237, comm: rmmod Not tainted 2.6.37-rc1-cur+ #11 /eserver xSeries 335 -[8676GBX]-
> EIP: 0060:[<c0201f11>] EFLAGS: 00010202 CPU: 2
> EIP is at debugfs_remove_recursive+0x1e/0x11a
> EAX: 6b6b6b6b EBX: f4d99480 ECX: 00000000 EDX: f3d5a5d4
> ESI: f4d99950 EDI: f2d445b8 EBP: f4d03eb8 ESP: f4d03ea8
>   DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process rmmod (pid: 5237, ti=f4d02000 task=f3d5a240 task.ti=f4d02000)
> Stack:
>   f4d03ec0 f4d99480 f4d99950 f4d99000 f4d03ec0 f801dc05 f4d03ef4 f8015c5b
>   c0156ab6 f4d03ed8 c0134ff0 f4d9949c f4d03ee4 c037ec67 f4d99150 f4d03ef4
>   f4d99000 f4d03f20 f4d99000 f4d03f08 c030eafe f4d03f20 c0ce4140 f80233a4
> Call Trace:
>   [<f801dc05>] ? bond_debug_unregister+0xe/0x10 [bonding]
>   [<f8015c5b>] ? bond_uninit+0x324/0x36d [bonding]
>   [<c0156ab6>] ? trace_hardirqs_on+0xb/0xd
>   [<c0134ff0>] ? local_bh_enable_ip+0x97/0xae
>   [<c037ec67>] ? _raw_spin_unlock_bh+0x2f/0x32
>   [<c030eafe>] ? rollback_registered_many+0x187/0x1fb
>   [<c030eb81>] ? unregister_netdevice_many+0xf/0x4d
>   [<c0318890>] ? __rtnl_link_unregister+0x56/0x8a
>   [<c0318f45>] ? rtnl_link_unregister+0x19/0x21
>   [<f801e32d>] ? bonding_exit+0x30/0x3c [bonding]
>   [<c0162ddc>] ? sys_delete_module+0x184/0x1dc
>   [<c01555fe>] ? put_lock_stats+0xd/0x22
>   [<c0155708>] ? lock_release_holdtime+0xf5/0xfa
>   [<c01a8fa3>] ? sys_munmap+0x39/0x3f
>   [<c037f098>] ? restore_all_notrace+0x0/0x18
>   [<c010294c>] ? sysenter_do_call+0x12/0x32
> Code: fc ff 89 d8 e8 27 77 fc ff 5b 5e 5d c3 55 89 e5 57 89 c7 56 53 83 ec 04 85 c0 0f 84 01 01 00 00 8b 40 40 85 c0 0f 84 f6 00 00 00<83>  78 34 00 0f 84 ec 00 00 00 8b 47 34 31 d2 89 fe 05 a4 00 00
> EIP: [<c0201f11>] debugfs_remove_recursive+0x1e/0x11a SS:ESP 0068:f4d03ea8
> CR2: 000000006b6b6b9f
> ---[ end trace e274f539dfd6ed30 ]---
> 
> 	This happens regardless of activity; e.g., "insmod bonding
> mode=balance-alb" followed immediately by "rmmod bonding" generates the
> above.
> 
> 	Any thoughts?

 Thank you for testing. I could reproduce a similar crash.
 I'm debugging now...

Best regards,
Taku izumi

