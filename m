From: Chuck Ebbert <76306.1226@compuserve.com>
Subject: e100: Freeing alive device?
Date: Wed, 7 May 2003 07:06:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305070708_MC3-1-37C1-F91C@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
	 charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Every time I boot 2.5.69 I get this in the log:

        Intel(R) PRO/100 Network Driver - version 2.2.21-k1
        Copyright (c) 2003 Intel Corporation

        e100: selftest OK.
        Freeing alive device c3f34000, eth%d              <========= eth%d ???
        e100: eth0: Intel(R) PRO/100 Network Connection

        e100: selftest OK.
        e100: eth1: Intel(R) PRO/100 Network Connection

(Output from lspci for these adapters is at the end of this message.)


  I added a stack dump in net/core/dev.c where the message
is printed and caught this:

        [<c029ee5d>] netdev_finish_unregister+0x8d/0xb0
        [<c02a3471>] linkwatch_run_queue+0xc1/0xe0
        [<c0118f2d>] __wake_up+0x1d/0x30
        [<c02a34b3>] linkwatch_event+0x23/0x30
        [<c01299fb>] worker_thread+0x1cb/0x280
        [<c02a3490>] linkwatch_event+0x0/0x30
        [<c0118e90>] default_wake_function+0x0/0x20
        [<c0108e76>] ret_from_fork+0x6/0x14
        [<c0118e90>] default_wake_function+0x0/0x20
        [<c0129830>] worker_thread+0x0/0x280
        [<c01070e5>] kernel_thread_helper+0x5/0x10


  Both of these adapters have PXE enabled:

01:09.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 05)
Subsystem: Compaq Computer Corporation NC3121 Fast Ethernet NIC (WOL)
Flags: bus master, medium devsel, latency 120, IRQ 19
Memory at f9fff000 (32-bit, prefetchable) [size=4K]
I/O ports at ece0 [size=32]
Memory at fcf00000 (32-bit, non-prefetchable) [size=1M]
Expansion ROM at fd000000 [disabled] [size=1M]
Capabilities: [dc] Power Management version 1

01:0a.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 05)
Subsystem: Compaq Computer Corporation NC3121 Fast Ethernet NIC (WOL)
Flags: bus master, medium devsel, latency 120, IRQ 18
Memory at f9ffe000 (32-bit, prefetchable) [size=4K]
I/O ports at ecc0 [size=32]
Memory at fce00000 (32-bit, non-prefetchable) [size=1M]
Expansion ROM at fd000000 [disabled] [size=1M]
Capabilities: [dc] Power Management version 1
                                                                                
