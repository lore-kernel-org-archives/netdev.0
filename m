From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9933] New: kernel BUG at
 include/linux/skbuff.h:912
Date: Mon, 11 Feb 2008 10:08:02 -0800
Message-ID: <20080211100802.9640365b.akpm@linux-foundation.org>
References: <bug-9933-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, tomas.simonaitis@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48260 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544AbYBKSK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 13:10:58 -0500
In-Reply-To: <bug-9933-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Feb 2008 03:46:45 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9933
> 
>            Summary: kernel BUG at include/linux/skbuff.h:912
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: tomas.simonaitis@gmail.com
> 
> 
> Latest working kernel version: 2.6.22.3
> Earliest failing kernel version: 2.6.24.1
> Distribution: Debian etch
> Hardware Environment: x86_64, SMP
> 
> If libnetfilter-queue (v. 0.0.12-1) application calls nfq_set_verdict
> and:
> - protocol is IPv4 (works fine with IPv6)
> - new packet length has been changed
> - packet contains data payload (not affected if tcp header is extended with
> options, but data payload=0)
> 
> SKB_LINEAR_ASSERT is catched.
> 
> 
> ------------[ cut here ]------------
> kernel BUG at include/linux/skbuff.h:912!
> invalid opcode: 0000 [1] SMP
> CPU 4
> Modules linked in: nfnetlink_queue nfnetlink ip6table_mangle xt_NFQUEUE
> iptable_mangle xt_tcpudp nf_conntrack_ipv6 nf_conntrack_ipv4 xt_state
> nf_conntrack iptable_filter ip_tables ip6table_filter ip6_tables x_tables esp4
> ah4 xfrm4_mode_transport deflate zlib_deflate twofish twofish_common camellia
> serpent blowfish des_generic cbc ecb blkcipher aes_x86_64 aes_generic xcbc
> sha256_generic sha1_generic crypto_null af_key dm_crypt dm_snapshot dm_mirror
> dm_mod ipv6 ipmi_si iTCO_wdt container ipmi_msghandler button serio_raw evdev
> pcspkr ide_generic ide_cd cdrom pata_acpi ata_generic ata_piix libata scsi_mod
> usbhid piix generic ide_core ehci_hcd bnx2 uhci_hcd zlib_inflate cciss thermal
> processor fan
> Pid: 3390, comm: tcpmd5 Not tainted 2.6.24.2 #1
> RIP: 0010:[<ffffffff88258b2c>]  [<ffffffff88258b2c>]
> :nfnetlink_queue:nfqnl_recv_verdict+0x179/0x227
> RSP: 0018:ffff81012d219a08  EFLAGS: 00010206
> RAX: 0000000000000100 RBX: 0000000000000000 RCX: 0000000000010001
> RDX: ffff81012e539500 RSI: ffff81012e539638 RDI: ffff81012df7ce18
> RBP: 0000000000000075 R08: ffffffff88250079 R09: ffff81012df7ce18
> R10: 00007fff576df198 R11: ffff81012d9daac0 R12: 0000000000000014
> R13: ffff81012e691e40 R14: 0000000000000001 R15: ffff81012eae3c20
> FS:  00002aab53c7a6d0(0000) GS:ffff81012f8fdb40(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00002aab535e6090 CR3: 000000012e06c000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process tcpmd5 (pid: 3390, threadinfo ffff81012d218000, task ffff81012dafc080)
> Stack:  ffffffff8825000a ffff81012d219a60 ffff81012e524740 ffff81012d219a60
>  ffff81012d219af8 ffffffff88258ff8 ffff81012eae3c00 ffff81012d219ac8
>  ffff81012f9d7a80 ffffffff88255233 ffffffff804e42e8 0000000000000000
> Call Trace:
>  [<ffffffff88255233>] :nfnetlink:nfnetlink_rcv_msg+0x129/0x172
>  [<ffffffff8825512b>] :nfnetlink:nfnetlink_rcv_msg+0x21/0x172
>  [<ffffffff8825510a>] :nfnetlink:nfnetlink_rcv_msg+0x0/0x172
>  [<ffffffff803d23b6>] netlink_rcv_skb+0x34/0x8b
>  [<ffffffff8825501f>] :nfnetlink:nfnetlink_rcv+0x1f/0x2c
>  [<ffffffff803d2156>] netlink_unicast+0x1e0/0x240
>  [<ffffffff803d29eb>] netlink_sendmsg+0x2a2/0x2b5
>  [<ffffffff803ba345>] memcpy_fromiovec+0x36/0x66
>  [<ffffffff803b3790>] sock_sendmsg+0xe2/0xff
>  [<ffffffff80243e10>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff803b3790>] sock_sendmsg+0xe2/0xff
>  [<ffffffff80243e10>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80312f8d>] xfs_vn_getattr+0x3d/0xfd
>  [<ffffffff803b29c0>] move_addr_to_kernel+0x25/0x36
>  [<ffffffff803b39c1>] sys_sendmsg+0x214/0x287
>  [<ffffffff803b3b5c>] sys_sendto+0x128/0x151
>  [<ffffffff8027bbf5>] do_readv_writev+0x18f/0x1a4
>  [<ffffffff8020be2e>] system_call+0x7e/0x83
> 
> 
> Code: 0f 0b eb fe 44 01 e0 44 01 67 68 3b 87 b8 00 00 00 89 87 b4
> RIP  [<ffffffff88258b2c>] :nfnetlink_queue:nfqnl_recv_verdict+0x179/0x227
>  RSP <ffff81012d219a08>
> ---[ end trace 303d8add98149551 ]---
> 
> I cannot reproduce problem on kernel 2.6.22.3 (both i386 and x86-64) and
> 2.6.24.2 if arch is i386.
> 
> tcpmd5 application http://tcpmd5.googlecode.com/files/tcpmd5_0.0.3.tar.gz
> 
> 

