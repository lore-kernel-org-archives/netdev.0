From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Tue, 18 Nov 2003 11:01:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118110139.45f2be60.akpm@osdl.org>
References: <6.0.1.1.2.20031118232152.01ae5728@tornado.reub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Reuben Farrelly <reuben-linux@reub.net>
In-Reply-To: <6.0.1.1.2.20031118232152.01ae5728@tornado.reub.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's one for the networking guys.

The mm kernels have a patch which detects when atomic_dec_and_test
takes an atomic_t negative - it is assumed that this is a bug so
a warning is generated.


Reuben Farrelly <reuben-linux@reub.net> wrote:
>
> Hi Andrew,
> 
> Have started to see this problem occur in -test9 and I think, -test8 (but 
> not before then).  At the moment I'm running -test9-mm3 which has the same 
> problem.  Kernel is not tainted.
> 
> Fortunately when this box died a few mins ago (twice in a row) it was able 
> to dump a heap of stuff to syslog, so I got something useful out of the 
> crashes.  This first one triggered when I started to load the ethernet card 
> up with a "debug ip packet detail" from a Cisco router ;-)
> 
> Reuben
> 
> Crash 1:
> 
> 
> Nov 18 23:09:00 tornado kernel: Badness in atomic_dec_and_test at 
> include/asm/atomic.h:150
> Nov 18 23:09:00 tornado kernel: Call Trace:
> Nov 18 23:09:00 tornado kernel:  [<c029203c>] skb_release_data+0x14c/0x160
> Nov 18 23:09:00 tornado kernel:  [<c0292063>] kfree_skbmem+0x13/0x30
> Nov 18 23:09:00 tornado kernel:  [<c0292138>] __kfree_skb+0xb8/0x1b0
> Nov 18 23:09:00 tornado kernel:  [<c0218815>] e100intr+0x1e5/0x290
> Nov 18 23:09:00 tornado kernel:  [<c0296e9a>] net_tx_action+0x4a/0xf0
> Nov 18 23:09:00 tornado kernel:  [<c01234a5>] do_softirq+0x95/0xa0
> Nov 18 23:09:00 tornado kernel:  [<c010cd9b>] do_IRQ+0xfb/0x130
> Nov 18 23:09:00 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:00 tornado kernel:  [<c02f56fc>] common_interrupt+0x18/0x20
> Nov 18 23:09:00 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:00 tornado kernel:  [<e08cd23d>] 
> acpi_processor_idle+0xd4/0x1c5 [processor]
> Nov 18 23:09:00 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:00 tornado kernel:  [<c0109044>] cpu_idle+0x34/0x40
> Nov 18 23:09:00 tornado kernel:  [<c0398795>] start_kernel+0x185/0x1c0
> Nov 18 23:09:00 tornado kernel:  [<c03984b0>] unknown_bootoption+0x0/0x120
> Nov 18 23:09:00 tornado kernel:
> Nov 18 23:09:00 tornado kernel: BUG: dst underflow 0: c02921ef
> Nov 18 23:09:00 tornado kernel: Attempt to release alive inet socket dfd4c780
> Nov 18 23:09:00 tornado kernel: BUG: dst underflow 0: c02921ef
> Nov 18 23:09:00 tornado kernel: Attempt to release alive inet socket dfd4c780
> Nov 18 23:09:01 tornado kernel: BUG: dst underflow 0: c02921ef
> Nov 18 23:09:01 tornado kernel: Badness in atomic_dec_and_test at 
> include/asm/atomic.h:150
> Nov 18 23:09:01 tornado kernel: Call Trace:
> Nov 18 23:09:01 tornado kernel:  [<c029203c>] skb_release_data+0x14c/0x160
> Nov 18 23:09:01 tornado kernel:  [<c0292063>] kfree_skbmem+0x13/0x30
> Nov 18 23:09:01 tornado kernel:  [<c0292138>] __kfree_skb+0xb8/0x1b0
> Nov 18 23:09:01 tornado kernel:  [<c02921ef>] __kfree_skb+0x16f/0x1b0
> Nov 18 23:09:01 tornado kernel:  [<c0218815>] e100intr+0x1e5/0x290
> Nov 18 23:09:01 tornado kernel:  [<c0296e9a>] net_tx_action+0x4a/0xf0
> Nov 18 23:09:01 tornado kernel:  [<c01234a5>] do_softirq+0x95/0xa0
> Nov 18 23:09:01 tornado kernel:  [<c010cd9b>] do_IRQ+0xfb/0x130
> Nov 18 23:09:01 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:01 tornado kernel:  [<c02f56fc>] common_interrupt+0x18/0x20
> Nov 18 23:09:01 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:01 tornado kernel:  [<e08cd21c>] 
> acpi_processor_idle+0xb3/0x1c5 [processor]
> Nov 18 23:09:01 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:01 tornado kernel:  [<c0109044>] cpu_idle+0x34/0x40
> Nov 18 23:09:01 tornado kernel:  [<c0398795>] start_kernel+0x185/0x1c0
> Nov 18 23:09:01 tornado kernel:  [<c03984b0>] unknown_bootoption+0x0/0x120
> Nov 18 23:09:01 tornado kernel:
> Nov 18 23:09:01 tornado kernel: BUG: dst underflow -1: c02921ef
> Nov 18 23:09:01 tornado kernel: Badness in atomic_dec_and_test at 
> include/asm/atomic.h:150
> Nov 18 23:09:01 tornado kernel: Call Trace:
> Nov 18 23:09:01 tornado kernel:  [<c0291136>] sock_wfree+0x86/0xa0
> Nov 18 23:09:01 tornado kernel:  [<c02920fe>] __kfree_skb+0x7e/0x1b0
> Nov 18 23:09:01 tornado kernel:  [<c02921ef>] __kfree_skb+0x16f/0x1b0
> Nov 18 23:09:01 tornado kernel:  [<c0218815>] e100intr+0x1e5/0x290
> Nov 18 23:09:01 tornado kernel:  [<c0296e9a>] net_tx_action+0x4a/0xf0
> Nov 18 23:09:01 tornado kernel:  [<c01234a5>] do_softirq+0x95/0xa0
> Nov 18 23:09:01 tornado kernel:  [<c010cd9b>] do_IRQ+0xfb/0x130
> Nov 18 23:09:01 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:01 tornado kernel:  [<c02f56fc>] common_interrupt+0x18/0x20
> Nov 18 23:09:01 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:01 tornado kernel:  [<e08cd21c>] 
> acpi_processor_idle+0xb3/0x1c5 [processor]
> Nov 18 23:09:01 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:09:01 tornado kernel:  [<c0109044>] cpu_idle+0x34/0x40
> Nov 18 23:09:01 tornado kernel:  [<c0398795>] start_kernel+0x185/0x1c0
> Nov 18 23:09:01 tornado kernel:  [<c03984b0>] unknown_bootoption+0x0/0x120
> Nov 18 23:09:01 tornado kernel:
> Nov 18 23:09:02 tornado kernel: Attempt to release alive inet socket dfd4c780
> Nov 18 23:09:02 tornado kernel: Attempt to release alive inet socket dfd4c780
> Nov 18 23:09:02 tornado kernel: BUG: dst underflow 0: c02d5c1b
> Nov 18 23:09:02 tornado kernel: BUG: dst underflow 0: c02921ef
> Nov 18 23:09:02 tornado kernel: Attempt to release alive inet socket dfd4c780
> Nov 18 23:09:02 tornado kernel: BUG: dst underflow -1: c02921ef
> Nov 18 23:09:02 tornado kernel: Badness in atomic_dec_and_test at 
> include/asm/atomic.h:150
> Nov 18 23:09:02 tornado kernel: Call Trace:
> Nov 18 23:09:02 tornado kernel:  [<c0291136>] sock_wfree+0x86/0xa0
> Nov 18 23:09:02 tornado kernel:  [<c02920fe>] __kfree_skb+0x7e/0x1b0
> Nov 18 23:09:02 tornado kernel:  [<c02921ef>] __kfree_skb+0x16f/0x1b0
> Nov 18 23:09:02 tornado kernel:  [<c0218815>] e100intr+0x1e5/0x290
> Nov 18 23:09:02 tornado kernel:  [<c0296e9a>] net_tx_action+0x4a/0xf0
> Nov 18 23:09:02 tornado kernel:  [<c01234a5>] do_softirq+0x95/0xa0
> Nov 18 23:09:02 tornado kernel:  [<c010cd9b>] do_IRQ+0xfb/0x130
> Nov 18 23:09:02 tornado kernel:  [<c02f56fc>] common_interrupt+0x18/0x20
> Nov 18 23:09:02 tornado kernel:  [<c02ee87e>] unix_dgram_sendmsg+0x3e/0x700
> Nov 18 23:09:02 tornado kernel:  [<c01387bc>] find_get_page+0x2c/0x60
> Nov 18 23:09:02 tornado kernel:  [<c028e3d3>] sock_aio_write+0xc3/0xf0
> Nov 18 23:09:02 tornado kernel:  [<c0156841>] do_sync_write+0xb1/0xe0
> Nov 18 23:09:02 tornado kernel:  [<c01385c5>] unlock_page+0x15/0x60
> Nov 18 23:09:02 tornado kernel:  [<c011b670>] schedule+0x350/0x680
> Nov 18 23:09:02 tornado kernel:  [<c011d2a0>] autoremove_wake_function+0x0/0x50
> Nov 18 23:09:02 tornado kernel:  [<c011b9f0>] default_wake_function+0x0/0x20
> Nov 18 23:09:02 tornado kernel:  [<c0127be0>] do_timer+0xe0/0xf0
> Nov 18 23:09:02 tornado kernel:  [<c015696f>] vfs_write+0xff/0x130
> Nov 18 23:09:02 tornado kernel:  [<c0156a52>] sys_write+0x42/0x70
> Nov 18 23:09:02 tornado kernel:  [<c02f4d3a>] sysenter_past_esp+0x43/0x65
> Nov 18 23:09:02 tornado kernel:
> Nov 18 23:09:02 tornado kernel: BUG: dst underflow -2: c02921ef
> 
> 
> Crash 2:
> 
> Nov 18 23:23:56 tornado kernel: Badness in atomic_dec_and_test at 
> include/asm/atomic.h:150
> Nov 18 23:23:56 tornado kernel: Call Trace:
> Nov 18 23:23:56 tornado kernel:  [<c029203c>] skb_release_data+0x14c/0x160
> Nov 18 23:23:56 tornado kernel:  [<c0292063>] kfree_skbmem+0x13/0x30
> Nov 18 23:23:56 tornado kernel:  [<c0292138>] __kfree_skb+0xb8/0x1b0
> Nov 18 23:23:56 tornado kernel:  [<c0218815>] e100intr+0x1e5/0x290
> Nov 18 23:23:56 tornado kernel:  [<c0296e9a>] net_tx_action+0x4a/0xf0
> Nov 18 23:23:56 tornado kernel:  [<c01234a5>] do_softirq+0x95/0xa0
> Nov 18 23:23:56 tornado kernel:  [<c010cd9b>] do_IRQ+0xfb/0x130
> Nov 18 23:23:56 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:23:56 tornado kernel:  [<c02f56fc>] common_interrupt+0x18/0x20
> Nov 18 23:23:56 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:23:56 tornado kernel:  [<e08cd23d>] 
> acpi_processor_idle+0xd4/0x1c5 [processor]
> Nov 18 23:23:56 tornado kernel:  [<c0107000>] rest_init+0x0/0x60
> Nov 18 23:23:56 tornado kernel:  [<c0109044>] cpu_idle+0x34/0x40
> Nov 18 23:23:56 tornado kernel:  [<c0398795>] start_kernel+0x185/0x1c0
> Nov 18 23:23:56 tornado kernel:  [<c03984b0>] unknown_bootoption+0x0/0x120
> Nov 18 23:23:56 tornado kernel:
> Nov 18 23:23:56 tornado kernel: BUG: dst underflow 0: c02921ef
> Nov 18 23:23:56 tornado kernel: Attempt to release alive inet socket dfd4c780
> Nov 18 23:23:56 tornado kernel: BUG: dst underflow 0: c02921ef
> Nov 18 23:23:56 tornado kernel: Attempt to release alive inet socket dfd4c780
> 
