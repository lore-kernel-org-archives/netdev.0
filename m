From: Stephen Hemminger <shemminger@osdl.org>
Subject: Oops on bootup.
Date: Thu, 8 May 2003 11:25:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508112531.0483fccf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This happened once and is not reproducible.
There appears to be initialization window where netlink data can
arrive before socket slab cache is initialized or something like that.
Probably a packet has to arrive at just the right time or something similar.

System is 4 CPU with 3 ethernets.

Any leads?
==============================
Initializing RT netlink socket
Unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip:
c01444b2
*pde = 00000000
Oops: 0000 [#1]
CPU:    4
EIP:    0060:[<c01444b2>]    Not tainted
EFLAGS: 00010086
EIP is at kmem_cache_alloc+0x38/0x18a
eax: 00000004   ebx: c041e250   ecx: c0360598   edx: 00000000
esi: f7ffa860   edi: 00000246   ebp: c377ff24   esp: c377ff04
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 1, threadinfo=c377e000 task=c377c080)
Stack: f7ffa860 000000d0 ffffffff 00005566 00005566 c041e250 f7ff7800 c028e8f4 
       c377ff38 c027f45a f7ffa860 000000d0 c041e250 c377ff54 c0176e62 f7ff7800 
       00005544 c041e250 00000000 c028e8f4 c377ff68 c017794c f7ff7800 c041e250 
Call Trace:
 [<c028e8f4>] rtnetlink_rcv+0x0/0x532
 [<c027f45a>] sock_alloc_inode+0x1e/0x7a
 [<c0176e62>] alloc_inode+0x1e/0x14a
 [<c028e8f4>] rtnetlink_rcv+0x0/0x532
 [<c017794c>] new_inode+0x1c/0xd8
 [<c027f72f>] sock_alloc+0x19/0x80
 [<c0293b84>] netlink_kernel_create+0x2e/0x88
 [<c041620a>] rtnetlink_init+0x26/0x74
 [<c028e8f4>] rtnetlink_rcv+0x0/0x532
 [<c04162cb>] netlink_proto_init+0x45/0x4c
 [<c03fc8be>] do_initcalls+0x2a/0x98
 [<c0133920>] init_workqueues+0x12/0x29
 [<c01050fb>] init+0x5d/0x1fa
 [<c010509e>] init+0x0/0x1fa
 [<c0108f31>] kernel_thread_helper+0x5/0xc

Code: 8b 1a 85 db 0f 84 11 01 00 00 f0 ff 86 10 01 00 00 8b 02 c7 
 <0>Kernel panic: Attempted to kill init!
