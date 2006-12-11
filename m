From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: kernel panic with the newly merged md5 signature support
Date: Mon, 11 Dec 2006 21:38:58 -0000 (GMT)
Message-ID: <36718.81.105.127.245.1165873138.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:4014 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937672AbWLKVjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 16:39:00 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I decided to try out the md5 signature support, with a view to eventually
fixing up Quagga to make use of it.  As the API has changed quite a bit,
I modified a simple echo client/server as a simple test.  I compiled
up 2.6.19-git17 and ran it under debian etch.

Unfortunately, both the client and server machines panic (actually I'm
using qemu to make things easy for myself).  Although my test programs
might be buggy, I don't believe they should cause a panic.

Has anyone got this stuff working yet?

I've attached the client panic below.  Both panics, the kernel .config
and the source code for the test client and server can be found at:

http://www.solinno.co.uk/md5sig/

Thanks,

Leigh.

BUG: unable to handle kernel NULL pointer dereference at virtual address
00000000
 printing eip:
c026e678
*pde = 00000000
Oops: 0000 [#1]
SMP
Modules linked in: ipv6 dm_snapshot dm_mirror dm_mod loop tsdev psmouse
serio_raw pcspkr evdev ext3 jbd mbcache ide_cd cdrom ide_disk ne2k_pci
8390 piix generic ide_core processor
CPU:    0
EIP:    0060:[<c026e678>]    Not tainted VLI
EFLAGS: 00000206   (2.6.19-git17 #1)
EIP is at __tcp_get_md5sig_pool+0x3c/0x40
eax: 00000000   ebx: 00000000   ecx: c703aaa0   edx: 00000003
esi: 230a0a0a   edi: c6c0ceec   ebp: 0000003c   esp: c0359e30
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, ti=c0358000 task=c032db60 task.ti=c0358000)
Stack: 0000003c c027a4ba 00000001 c7b96274 c703ac40 c74ec0d0 c020dc13
0000001d
       c1103fb8 c1103fb4 c0390f20 c0359eec c01c6114 00000000 c0119dcc
00000000
       00000002 c1103540 ffffffff 00000000 00000000 c74ec0d0 c0347950
c6d35ac0
Call Trace:
 [<c027a4ba>] tcp_v4_do_calc_md5_hash+0x20/0x1a9
 [<c020dc13>] __add_entropy_words+0x5f/0x18b
 [<c01c6114>] __next_cpu+0x12/0x1f
 [<c0119dcc>] find_busiest_group+0x1bf/0x4b4
 [<c0275118>] tcp_transmit_skb+0x36f/0x449
 [<c0276da8>] tcp_retransmit_skb+0x1d0/0x268
 [<c026fda3>] tcp_enter_loss+0xb6/0x208
 [<c02788d2>] tcp_write_timer+0x0/0xae
 [<c02787ca>] tcp_retransmit_timer+0x278/0x380
 [<c01338b6>] hrtimer_run_queues+0x4d/0xcf
 [<c027894a>] tcp_write_timer+0x78/0xae
 [<c0128461>] run_timer_softirq+0x10b/0x166
 [<c01241aa>] __do_softirq+0x60/0xba
 [<c0124235>] do_softirq+0x31/0x35
 [<c0104f72>] do_IRQ+0x62/0x74
 [<c01003d2>] init+0x0/0x162
 [<c01036a7>] common_interrupt+0x23/0x28
 [<c0101018>] default_idle+0x0/0x39
 [<c010103f>] default_idle+0x27/0x39
 [<c01010f4>] cpu_idle+0xa0/0xb9
 [<c035e83d>] start_kernel+0x1f4/0x1f8
 [<c035e292>] unknown_bootoption+0x0/0x181
 =======================
Code: 3c c0 8b 0d 38 db 3c c0 a1 34 db 3c c0 42 85 c9 0f 45 c2 a3 34 db 3c
c0 b0 01 86 05 e4 78 34 c0 31 c0 85 c9 74 07 f7 d1 8b 04 99 <8b> 00 5b c3
a1 38 db 3c c0 e9 e7 fd ff ff 90 90 56 53 89 c3 0f
EIP: [<c026e678>] __tcp_get_md5sig_pool+0x3c/0x40 SS:ESP 0068:c0359e30
 <0>Kernel panic - not syncing: Fatal exception in interrupt

