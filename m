From: Joonas Kortesalmi <vrsbs@derbian.org>
Subject: Oops: Process zebra, EIP is at fib_create_info+0x22b/0x580
Date: Sun, 22 Aug 2004 00:04:17 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821210417.GA8844@hamsu.derbian.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Running 2.6.8.1 and got a nice Oops from zebra (quagga).

After this, nothing routing-related worked. traceroute went to unin-
terruptible sleep, ip route get printed nothing and hanged... Perhaps
it's worth having a look so potential bug doesn't get into 2.6.9?

I'm not subscribed on the list and used a temporary account to avoid
too much spam but I will receive the mails for a few weeks or so.

-- clip --
Unable to handle kernel paging request at virtual address 042454df
 printing eip:
c02e39eb
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c02e39eb>]    Not tainted
EFLAGS: 00010206   (2.6.8.1) 
EIP is at fib_create_info+0x22b/0x580
eax: 00000011   ebx: ff0d7448   ecx: 0424548b   edx: c3fa06bc
esi: 0424548b   edi: c3fa06b4   ebp: c1167a3c   esp: c2577c14
ds: 007b   es: 007b   ss: 0068
Process zebra (pid: 2748, threadinfo=c2576000 task=c2575810)
Stack: 00000001 0424548b c11679e0 00000000 00000001 ffffffea c2577cd0 c2577cd0 
       c38f2c40 c02e4fe8 c10d0c90 c2577cd0 c10d0c80 c2577c6c c02b2833 00f1a8c0 
       00876260 00000001 00000018 c3f84680 c38f2c40 c3f846c4 c1876260 00f1a8c0 
Call Trace:
 [<c02e4fe8>] fn_hash_insert+0xa8/0x4a0
 [<c02b2833>] netlink_unicast+0x53/0xb0
 [<c02e2c13>] inet_rtm_newroute+0x53/0x70
 [<c029963f>] rtnetlink_rcv+0x2bf/0x390
 [<c029010d>] memcpy_toiovec+0x2d/0x60
 [<c02b3004>] netlink_data_ready+0x54/0x60
 [<c02b277f>] netlink_sendskb+0x1f/0x40
 [<c02b2cdf>] netlink_sendmsg+0x1ef/0x2d0
 [<c028b123>] sock_sendmsg+0x93/0xb0
 [<c029010d>] memcpy_toiovec+0x2d/0x60
 [<c0290741>] skb_copy_datagram_iovec+0x41/0x1e0
 [<c028e487>] kfree_skbmem+0x17/0x20
 [<c020f19e>] copy_from_user+0x2e/0x60
 [<c0290081>] verify_iovec+0x31/0x90
 [<c028c593>] sys_sendmsg+0x153/0x1b0
 [<c020f15d>] copy_to_user+0x2d/0x40
 [<c020f19e>] copy_from_user+0x2e/0x60
 [<c028c952>] sys_socketcall+0x192/0x1b0
 [<c01039f7>] syscall_call+0x7/0xb
Code: 8b 59 54 3b 1c 24 74 6e 8b 74 24 04 8b 36 89 74 24 04 85 f6 
-- clip --
