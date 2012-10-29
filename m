From: Roland Stigge <stigge@antcom.de>
Subject: Re: 3.7-rc3 oops on reboot
Date: Mon, 29 Oct 2012 13:49:11 +0100
Message-ID: <508E7B47.60207@antcom.de>
References: <CAAAP30E-g3YdXOMvfueDQZREZ+_Adi2uhxgLeqKixkupU+QNhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAAP30E-g3YdXOMvfueDQZREZ+_Adi2uhxgLeqKixkupU+QNhA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2012 01:08 PM, Alexandre Pereira da Silva wrote:
> I am getting oops on 3.7-rc3 at reboot.
> 
> This is an LPC32XX machine. This problem only happens when I connect
> the ethernet cable and get an IP address.
> 
> Here are the kernel messages.
> [   38.570000] Unable to handle kernel paging request at virtual
> address a0000014
> [   38.570000] pgd = c1730000
> [   38.580000] [a0000014] *pgd=00000000
> [   38.580000] Internal error: Oops: 5 [#1] PREEMPT ARM
> [   38.580000] Modules linked in:
> [   38.580000] CPU: 0    Not tainted  (3.7.0-rc3 #4)
> [   38.580000] PC is at trie_firstleaf+0xc/0x2c
> [   38.580000] LR is at fib_table_flush+0x1c/0x170
> [   38.580000] pc : [<c029659c>]    lr : [<c0298dec>]    psr: a0000013
> [   38.580000] sp : c1719d50  ip : c1719d60  fp : c1719d5c
> [   38.580000] r10: 00000000  r9 : 00000000  r8 : c16341e0
> [   38.580000] r7 : c09d2c24  r6 : 00000001  r5 : a0000000  r4 : 000003fc
> [   38.580000] r3 : c18dac00  r2 : c09c6fc0  r1 : c09c6fc0  r0 : a0000014
> [   38.580000] Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> [   38.580000] Control: 0005317f  Table: 81730000  DAC: 00000015
> [   38.580000] Process ifconfig (pid: 396, stack limit = 0xc17181b8)
> [   38.580000] Stack: (0xc1719d50 to 0xc171a000)
> [   38.580000] 9d40:                                     c1719d9c
> c1719d60 c0298dec c02965a0
> [   38.580000] 9d60: c170f308 c14d42e0 00000000 a0000014 c16341e0
> 000003fc a0000000 00000001
> [   38.580000] 9d80: c09d2c24 c16341e0 00000000 00000000 c1719dbc
> c1719da0 c0294244 c0298de0
> [   38.580000] 9da0: c160f800 c160f800 ffffffff 00000000 c1719dd4
> c1719dc0 c0294294 c0294224
> [   38.580000] 9dc0: 00000000 c16341e0 c1719dec c1719dd8 c0294bf0
> c0294284 00000002 00000000
> [   38.580000] 9de0: c1719e14 c1719df0 c003e810 c0294b60 ffffffff
> c09d4698 ffffffff c16341e0
> [   38.580000] 9e00: 00000002 00000000 c1719e3c c1719e18 c003ea9c
> c003e7e0 00000000 c1719e28
> [   38.580000] 9e20: c16341e0 00000000 00000000 c16341e0 c1719e54
> c1719e40 c003ead4 c003ea5c
> [   38.580000] 9e40: 00000000 00000000 c1719e8c c1719e58 c028b9bc
> c003eac4 00000000 c145edec
> [   38.580000] 9e60: c1719e8c c16341e0 00000000 c160f800 c145ede0
> c145edec 00000000 00000000
> [   38.580000] 9e80: c1719ea4 c1719e90 c028ba94 c028b828 00000000
> c09d2c24 c1719f14 c1719ea8
> [   38.580000] 9ea0: c028d278 c028ba88 c003d890 00000000 00008916
> bef74c18 30687465 00000000
> [   38.580000] 9ec0: 00000000 00000000 00000002 00000000 00000001
> 00084a10 00000002 00000000
> [   38.580000] 9ee0: 00000001 00084a10 00001000 00008914 bef74c18
> bef74c18 00008916 00000003
> [   38.580000] 9f00: c1718000 00000000 c1719f2c c1719f18 c028e284
> c028cf18 c1404420 00008916
> [   38.580000] 9f20: c1719f4c c1719f30 c022ed8c c028e1c4 c022eb6c
> 00000003 bef74c18 bef74c18
> [   38.580000] 9f40: c1719f74 c1719f50 c009e5e8 c022eb7c 000ac000
> 000ad000 bef74c18 00008916
> [   38.580000] 9f60: c14dcbe0 00000000 c1719fa4 c1719f78 c009e66c
> c009e304 c0080184 00000000
> [   38.580000] 9f80: b6f73ee4 bef74c18 00008916 00000003 00000036
> c000e224 00000000 c1719fa8
> [   38.580000] 9fa0: c000e0c0 c009e638 bef74c18 00008916 00000003
> 00008916 bef74c18 00000000
> [   38.580000] 9fc0: bef74c18 00008916 00000003 00000036 00085a28
> 00000000 000859a8 00000000
> [   38.580000] 9fe0: b6f2bde4 bef74bc0 0000ddb4 b6f2be28 60000010
> 00000003 00000000 00000000
> [   38.580000] Backtrace:
> [   38.580000] [<c0296590>] (trie_firstleaf+0x0/0x2c) from
> [<c0298dec>] (fib_table_flush+0x1c/0x170)
> [   38.580000] [<c0298dd0>] (fib_table_flush+0x0/0x170) from
> [<c0294244>] (fib_flush.clone.27+0x30/0x60)
> [   38.580000] [<c0294214>] (fib_flush.clone.27+0x0/0x60) from
> [<c0294294>] (fib_disable_ip+0x20/0x38)
> [   38.580000]  r7:00000000 r6:ffffffff r5:c160f800 r4:c160f800
> [   38.580000] [<c0294274>] (fib_disable_ip+0x0/0x38) from
> [<c0294bf0>] (fib_inetaddr_event+0xa0/0xb4)
> [   38.580000]  r4:c16341e0 r3:00000000
> [   38.580000] [<c0294b50>] (fib_inetaddr_event+0x0/0xb4) from
> [<c003e810>] (notifier_call_chain+0x40/0x70)
> [   38.580000]  r5:00000000 r4:00000002
> [   38.580000] [<c003e7d0>] (notifier_call_chain+0x0/0x70) from
> [<c003ea9c>] (__blocking_notifier_call_chain+0x50/0x68)
> [   38.580000]  r8:00000000 r7:00000002 r6:c16341e0 r5:ffffffff r4:c09d4698
> r3:ffffffff
> [   38.580000] [<c003ea4c>] (__blocking_notifier_call_chain+0x0/0x68)
> from [<c003ead4>] (blocking_notifier_call_chain+0x20/0x28)
> [   38.580000]  r7:c16341e0 r6:00000000 r5:00000000 r4:c16341e0
> [   38.580000] [<c003eab4>] (blocking_notifier_call_chain+0x0/0x28)
> from [<c028b9bc>] (__inet_del_ifa+0x1a4/0x260)
> [   38.580000] [<c028b818>] (__inet_del_ifa+0x0/0x260) from
> [<c028ba94>] (inet_del_ifa+0x1c/0x24)
> [   38.580000] [<c028ba78>] (inet_del_ifa+0x0/0x24) from [<c028d278>]
> (devinet_ioctl+0x370/0x634)
> [   38.580000] [<c028cf08>] (devinet_ioctl+0x0/0x634) from
> [<c028e284>] (inet_ioctl+0xd0/0x110)
> [   38.580000] [<c028e1b4>] (inet_ioctl+0x0/0x110) from [<c022ed8c>]
> (sock_ioctl+0x220/0x278)
> [   38.580000]  r4:00008916 r3:c1404420
> [   38.580000] [<c022eb6c>] (sock_ioctl+0x0/0x278) from [<c009e5e8>]
> (do_vfs_ioctl+0x2f4/0x334)
> [   38.580000]  r6:bef74c18 r5:bef74c18 r4:00000003 r3:c022eb6c
> [   38.580000] [<c009e2f4>] (do_vfs_ioctl+0x0/0x334) from [<c009e66c>]
> (sys_ioctl+0x44/0x64)
> [   38.580000]  r5:00000000 r4:c14dcbe0
> [   38.580000] [<c009e628>] (sys_ioctl+0x0/0x64) from [<c000e0c0>]
> (ret_fast_syscall+0x0/0x2c)
> [   38.580000]  r8:c000e224 r7:00000036 r6:00000003 r5:00008916 r4:bef74c18
> [   38.580000] Code: e89da810 e1a0c00d e92dd800 e24cb004 (e5900000)
> [   39.040000] ---[ end trace 1e122706a9f64743 ]---
> 
> Do anybody have any idea what may have happened there?

I just tried both on a PHY3250 reference machine, and on a custom board
and couldn't reproduce sth. like this. Booted the kernel and connected
the ethernet cable later on, as well as with cable connected on boot.

Any related patches applied? Can you reproduce this on a reference
machine? Can you provide a .config for this? Any more detail about how
this could be reproduced?

Thanks in advance,

Roland
