From: Chris Caputo <ccaputo@alt.net>
Subject: NMI watchdog lockups with e1000 in 2.6.9 / 2.6.9-ac14
Date: Fri, 17 Dec 2004 15:32:13 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0412171503510.22212-100000@nacho.alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is using the NMI Watchdog with the e1000 driver a bad thing?  I ask
because I have seen NMI "LOCKUP"s (below).  I am guessing they are caused
by mdelay/udelay calls.

If there is something I should try to help narrow this down, please let me
know.

Chris

---

2.6.9:

<Dec/09 01:05 am>swapper: page allocation failure. order:0, mode:0x20
<Dec/09 01:05 am> [<c0137739>] __alloc_pages+0x1b9/0x35e
<Dec/09 01:05 am>
<Dec/09 01:05 am> [<c0137903>] __get_free_pages+0x25/0x3f
<Dec/09 01:05 am> [<c013aba7>] kmem_getpages+0x21/0xc9
<Dec/09 01:05 am> [<c013b86e>] cache_grow+0xab/0x14d
<Dec/09 01:05 am> [<c013ba84>] cache_alloc_refill+0x174/0x219
<Dec/09 01:05 am> [<c013beda>] __kmalloc+0x85/0x8c
<Dec/09 01:05 am> [<c02d2331>] alloc_skb+0x47/0xe0
<Dec/09 01:05 am> [<c02950ac>] e1000_alloc_rx_buffers+0x44/0xe3
<Dec/09 01:05 am> [<c0294daf>] e1000_clean_rx_irq+0x18e/0x447
<Dec/09 01:05 am> [<c0121a50>] __mod_timer+0xeb/0x12a
<Dec/09 01:05 am> [<c0294990>] e1000_clean+0x51/0xca
<Dec/09 01:05 am> [<c02d8564>] net_rx_action+0x77/0xf6
<Dec/09 01:05 am> [<c011e48b>] __do_softirq+0xb7/0xc6
<Dec/09 01:05 am><4>NMI Watchdog detected LOCKUP on CPU2, eip c010f334, registers:
<Dec/09 01:05 am>printk: 31 messages suppressed.
<Dec/09 01:05 am>ntpd: page allocation failure. order:0, mode:0x20
<Dec/09 01:05 am>Stack pointer is garbage, not printing trace
<Dec/09 01:05 am>Modules linked in:
<Dec/09 01:05 am>
<Dec/09 01:05 am>CPU:    2
<Dec/09 01:05 am>EIP:    0060:[<c010f334>]    Not tainted VLI
<Dec/09 01:05 am>EFLAGS: 00000097   (2.6.9)
<Dec/09 01:05 am>EIP is at delay_tsc+0xd/0x15
<Dec/09 01:05 am>eax: d5b4a6f8   ebx: 00000be8   ecx: d5b4a4cc   edx: 000276b1
<Dec/09 01:05 am>esi: 0000266d   edi: c0459560   ebp: c0442371   esp: c0431d58
<Dec/09 01:05 am>ds: 007b   es: 007b   ss: 0068
<Dec/09 01:05 am>Process swapper (pid: 0, threadinfo=c0431000 task=c3190af0)
<Dec/09 01:05 am>Stack: 00000000 c025318e 00000be8 c027a93b 00000be8 00000005 0000000a 00000024
<Dec/09 01:05 am>
<Dec/09 01:05 am>       0000000d 00000025 c03bd2e0 00000025 0000686d 00000004 c0119fd0 c03bd2e0
<Dec/09 01:05 am>       c044234d 00000025 00006892 000078d3 0000686d c011a0dd 0000686d 00006892
<Dec/09 01:05 am>Call Trace:
<Dec/09 01:05 am>Stack pointer is garbage, not printing trace
<Dec/09 01:05 am>Code: af fe 89 04 24 01 f9 8b 04 24 8d 1c 0b 89 5c 24 04 8b 54 24 04 0f ac d0 0a c1 ea 0a eb b2 53 8b 5c 24 08 0f 31 89 c1 f3 90 0f 31 <29> c8 39 d8 72 f6 5b c3 55 b8 48 7d 37 c0 57 56 53 83 ec 24 8b
<Dec/09 01:05 am>console shuts up ...

And with 2.6.9-ac14:

<Dec/15 01:07 am>swapper: page allocation failure. order:0, mode:0x20
<Dec/15 01:07 am> [<c0137b9d>] __alloc_pages+0x1b9/0x35e
<Dec/15 01:07 am> [<c0137d67>] __get_free_pages+0x25/0x3f
<Dec/15 01:07 am> [<c013b00b>] kmem_getpages+0x21/0xc9
<Dec/15 01:07 am> [<c013bcd2>] cache_grow+0xab/0x14d
<Dec/15 01:07 am> [<c013bee8>] cache_alloc_refill+0x174/0x219
<Dec/15 01:07 am>
<Dec/15 01:07 am> [<c013c33e>] __kmalloc+0x85/0x8c
<Dec/15 01:07 am> [<c02d3945>] alloc_skb+0x47/0xe0
<Dec/15 01:07 am> [<c02958ec>] e1000_alloc_rx_buffers+0x44/0xe3
<Dec/15 01:07 am> [<c02955ef>] e1000_clean_rx_irq+0x18e/0x447
<Dec/15 01:07 am> [<c02d3b65>] __kfree_skb+0x55/0xbd
<Dec/15 01:07 am> [<c02951d0>] e1000_clean+0x51/0xca
<Dec/15 01:07 am> [<c02d9b48>] net_rx_action+0x77/0xf6
<Dec/15 01:07 am> [<c011e807>] __do_softirq+0xb7/0x<4>NMI Watchdog detected LOCKUP on CPU2, eip c02538a6, registers:
<Dec/15 01:07 am>Modules linked in:
<Dec/15 01:07 am>CPU:    2
<Dec/15 01:07 am>EIP:    0060:[<c02538a6>]    Not tainted VLI
<Dec/15 01:07 am>EFLAGS: 00000002   (2.6.9-ac14)
<Dec/15 01:07 am>EIP is at __const_udelay+0x1b/0x39
<Dec/15 01:07 am>eax: 00000000   ebx: 002e8000   ecx: 0000431c   edx: 00000200
<Dec/15 01:07 am>esi: 0000262e   edi: c045b560   ebp: c0443cd4   esp: c0433d60
<Dec/15 01:07 am>ds: 007b   es: 007b   ss: 0068
<Dec/15 01:07 am>Process swapper (pid: 0, threadinfo=c0433000 task=c3190af0)
<Dec/15 01:07 am>
<Dec/15 01:07 am>Stack: 00000000 c027b049 000010c7 00000005 00000078 00000022 0000000d 00000025
<Dec/15 01:07 am>       c03bf300 00000025 000161d2 00000004 c011a34c c03bf300 c0443cb2 00000025
<Dec/15 01:07 am>       000161f7 000167df 000161d2 c011a459 000161d2 000161f7 00000004 34ffffff
<Dec/15 01:07 am>Call Trace:
<Dec/15 01:07 am>
<Dec/15 01:07 am>Stack pointer is garbage, not printing trace
<Dec/15 01:07 am>Code: e2 89 d1 83 c1 01 89 4c 24 08 5b e9 71 ff ff ff 53 ba 00 f0 ff ff 21 e2 8b 52 10 8b 4c 24 08 c1 e2 08 c1 e1 02 8b 9a 88 0a 40 c0 <89> c8 69 db <4>printk: 38 messages suppressed.
<Dec/15 01:07 am>syslog-ng: page allocation failure. order:0, mode:0x20
<Dec/15 01:07 am>Stack pointer is garbage, not printing trace
<Dec/15 01:07 am>fa 00 00 00 89 da f7 e2 89 d1 83 c1 01 89 4c 24 08
<Dec/15 01:07 am>console shuts up ...
