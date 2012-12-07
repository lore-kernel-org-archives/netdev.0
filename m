From: Dave Jones <davej@redhat.com>
Subject: GPF in ip6_dst_lookup_tail
Date: Fri, 7 Dec 2012 09:15:25 -0500
Message-ID: <20121207141525.GA20613@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030606Ab2LGOP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 09:15:29 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qB7EFSh3025348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 09:15:28 -0500
Received: from gelk.kernelslacker.org (ovpn-113-42.phx2.redhat.com [10.3.113.42])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qB7EFROi009011
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 09:15:28 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id qB7EFQuO021343
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 09:15:26 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id qB7EFPbk021342
	for netdev@vger.kernel.org; Fri, 7 Dec 2012 09:15:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just hit this gpf in overnight testing.

general protection fault: 0000 [#1] PREEMPT SMP 
Modules linked in: sctp libcrc32c ipt_ULOG fuse binfmt_misc nfnetlink nfc caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 nfsv3 nfs_acl nfs fscache lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables usb_debug microcode serio_raw pcspkr i2c_piix4 i2c_core r8169 mii vhost_net tun macvtap macvlan kvm_amd kvm
CPU 3 
Pid: 19371, comm: trinity-child3 Not tainted 3.7.0-rc8+ #6 Gigabyte Technology Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
RIP: 0010:[<ffffffff815fe038>]  [<ffffffff815fe038>] ip6_dst_lookup_tail+0xe8/0x200
RSP: 0018:ffff880046277968  EFLAGS: 00010206
RAX: 2000000000000011 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff880046277b00 RSI: ffff880070a6cd80 RDI: ffff8800bb22d000
RBP: ffff8800462779f8 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff880046277a10
R13: ffff880046277b00 R14: ffff8800bb22d000 R15: ffffffff81cb40c0
FS:  00007f0817b3f740(0000) GS:ffff88012b400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000004 CR3: 00000000a7dfb000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-child3 (pid: 19371, threadinfo ffff880046276000, task ffff880044dca450)
Stack:
 ffff8800bb22d000 0000000000000002 0000000000000001 0000000000000000
 ffff880046277998 ffffffff81335b56 ffff8800462779b8 ffffffff81074cec
 0000000000000001 ffff880070a6cd80 ffff8800462779f8 00000000ae4317df
Call Trace:
 [<ffffffff81335b56>] ? __const_udelay+0x36/0x40
 [<ffffffff81074cec>] ? __rcu_read_unlock+0x5c/0xa0
 [<ffffffff81527945>] ? sk_dst_check+0x5/0x260
 [<ffffffff815fe3fb>] ip6_sk_dst_lookup_flow+0xcb/0x1b0
 [<ffffffff8161f45e>] udpv6_sendmsg+0x66e/0xb90
 [<ffffffff81335b56>] ? __const_udelay+0x36/0x40
 [<ffffffff81074cec>] ? __rcu_read_unlock+0x5c/0xa0
 [<ffffffff815bd4e4>] inet_sendmsg+0x114/0x230
 [<ffffffff815bd3d5>] ? inet_sendmsg+0x5/0x230
 [<ffffffff815261e9>] ? sock_update_classid+0xa9/0x2d0
 [<ffffffff81526270>] ? sock_update_classid+0x130/0x2d0
 [<ffffffff81520d1c>] sock_sendmsg+0xbc/0xf0
 [<ffffffff810b7ab2>] ? get_lock_stats+0x22/0x70
 [<ffffffff810bd037>] ? lock_release_non_nested+0x2b7/0x2f0
 [<ffffffff815210fc>] __sys_sendmsg+0x3ac/0x3c0
 [<ffffffff810b7b88>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff810b7ab2>] ? get_lock_stats+0x22/0x70
 [<ffffffff810b7f1e>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff8100a136>] ? native_sched_clock+0x26/0x90
 [<ffffffff810b7b88>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff81055e54>] ? do_setitimer+0x1c4/0x300
 [<ffffffff810b7f1e>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff811d6bea>] ? fget_light+0x3ca/0x500
 [<ffffffff810bdf9d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff815237d9>] sys_sendmsg+0x49/0x90
 [<ffffffff81684b42>] system_call_fastpath+0x16/0x1b
Code: 00 00 48 8b 5d d8 4c 8b 65 e0 4c 8b 6d e8 4c 8b 75 f0 4c 8b 7d f8 c9 c3 0f 1f 00 49 8b 34 24 48 8b 86 98 00 00 00 48 85 c0 74 c2 <f6> 80 6d 01 00 00 de 75 b9 48 8b 56 18 49 8d 75 24 b9 01 00 00 
RIP  [<ffffffff815fe038>] ip6_dst_lookup_tail+0xe8/0x200
 RSP <ffff880046277968>
---[ end trace f7dde22e5674fdd6 ]---



0000000000000000 <.text>:
   0:	00 00                	add    %al,(%rax)
   2:	48 8b 5d d8          	mov    -0x28(%rbp),%rbx
   6:	4c 8b 65 e0          	mov    -0x20(%rbp),%r12
   a:	4c 8b 6d e8          	mov    -0x18(%rbp),%r13
   e:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  12:	4c 8b 7d f8          	mov    -0x8(%rbp),%r15
  16:	c9                   	leaveq 
  17:	c3                   	retq   
  18:	0f 1f 00             	nopl   (%rax)
  1b:	49 8b 34 24          	mov    (%r12),%rsi
  1f:	48 8b 86 98 00 00 00 	mov    0x98(%rsi),%rax
  26:	48 85 c0             	test   %rax,%rax
  29:	74 c2                	je     0xffffffffffffffed

/home/davej/tmp/tmp.YOesIDyrIr.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <.text>:
   0:	f6 80 6d 01 00 00 de 	testb  $0xde,0x16d(%rax)
   7:	75 b9                	jne    0xffffffffffffffc2
   9:	48 8b 56 18          	mov    0x18(%rsi),%rdx
   d:	49 8d 75 24          	lea    0x24(%r13),%rsi
  11:	b9                   	.byte 0xb9
  12:	01 00                	add    %eax,(%rax)
	...


which looks like an inlined copy of ipv6_addr_any

         * marked as OPTIMISTIC, we release the found
         * dst entry and replace it instead with the
         * dst entry of the nexthop router
         */
        rt = (struct rt6_info *) *dst;
        n = rt->n;
      dc:       48 8b 86 98 00 00 00    mov    0x98(%rsi),%rax
        if (n && !(n->nud_state & NUD_VALID)) {
      e3:       48 85 c0                test   %rax,%rax
      e6:       74 c2                   je     aa <ip6_dst_lookup_tail+0xaa>
      e8:       f6 80 6d 01 00 00 de    testb  $0xde,0x16d(%rax)
      ef:       75 b9                   jne    aa <ip6_dst_lookup_tail+0xaa>


RAX here is 2000000000000011 , which clearly isn't a valid rt address to dereference.

Suddenly this starts to look familiar..  I started seeing this around 3.6-rc7
back in September.  http://www.spinics.net/lists/netdev/msg211894.html

	Dave
