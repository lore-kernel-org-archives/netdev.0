From: Anton Blanchard <anton@samba.org>
Subject: oops in ip_rcv
Date: Thu, 5 May 2005 20:15:42 +1000
Message-ID: <20050505101542.GB7916@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Im booting a recent 2.6.12-rc3++ git tree on ppc64. Just got an oops
very early in boot, right after:

TCP established hash table entries: 131072 (order: 9, 2097kernel:

It looks like we tried to load from address -1.

c0000000003c515c ip_rcv+0x4c/0x6e0
c0000000003a6750 netif_receive_skb+0x290/0x3b0
c0000000003a6954 process_backlog+0xe4/0x250
c0000000003a4204 net_rx_action+0x114/0x2d0
c00000000005e06c __do_softirq+0xec/0x1d0
c000000000014568 call_do_softirq+0x14/0x24
c00000000000fdcc do_softirq+0x9c/0xb0
c00000000005dad4 irq_exit+0x64/0x80
c00000000000fcbc do_IRQ+0x7c/0xf0

I do have some local patches, I'll try to reproduce without them.

Anton
