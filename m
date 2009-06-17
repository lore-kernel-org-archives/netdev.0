From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13561] New: swapper: page allocation failure.
 order:0, mode:0x20
Date: Wed, 17 Jun 2009 12:16:10 -0700
Message-ID: <20090617121610.d4f0ea9d.akpm@linux-foundation.org>
References: <bug-13561-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: nkukard@lbsd.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54729 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752469AbZFQTQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 15:16:13 -0400
In-Reply-To: <bug-13561-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 17 Jun 2009 18:41:24 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13561
> 
>            Summary: swapper: page allocation failure. order:0, mode:0x20
>            Product: Memory Management
> 
> ...
>
> [ 1884.639134] swapper: page allocation failure. order:0, mode:0x20
> [ 1884.639136] Pid: 0, comm: swapper Tainted: P           2.6.29.4-1.0 #1
> [ 1884.639137] Call Trace:
> [ 1884.639139]  <IRQ>  [<ffffffff8028828b>] __alloc_pages_internal+0x41e/0x43f
> [ 1884.639146]  [<ffffffff802ac183>] alloc_pages_current+0xb9/0xc2
> [ 1884.639149]  [<ffffffff802b08eb>] new_slab+0xcf/0x28c
> [ 1884.639151]  [<ffffffff802b0d14>] __slab_alloc+0x200/0x3e2
> [ 1884.639154]  [<ffffffff803d9e3b>] ? __alloc_skb+0x42/0x131
> [ 1884.639157]  [<ffffffff804974cc>] ? _spin_lock_irqsave+0x28/0x31
> [ 1884.639160]  [<ffffffff803d9e3b>] ? __alloc_skb+0x42/0x131
> [ 1884.639162]  [<ffffffff802b12cf>] kmem_cache_alloc_node+0x7c/0xc6
> [ 1884.639165]  [<ffffffff8024b8a4>] ? __mod_timer+0xb3/0xc5
> [ 1884.639168]  [<ffffffff803d9e3b>] __alloc_skb+0x42/0x131
> [ 1884.639171]  [<ffffffff8041892e>] tcp_send_ack+0x2b/0x112
> [ 1884.639173]  [<ffffffff80415c53>] __tcp_ack_snd_check+0x65/0x7d
> [ 1884.639176]  [<ffffffff80416906>] tcp_rcv_established+0x7d7/0x926
> [ 1884.639179]  [<ffffffff8041dfb3>] tcp_v4_do_rcv+0x1b1/0x35e
> [ 1884.639181]  [<ffffffff8041e606>] tcp_v4_rcv+0x4a6/0x785
> [ 1884.639185]  [<ffffffff80402a2d>] ip_local_deliver_finish+0x177/0x25a
> [ 1884.639187]  [<ffffffff80402b82>] ip_local_deliver+0x72/0x7a
> [ 1884.639190]  [<ffffffff804025e3>] ip_rcv_finish+0x32b/0x345
> [ 1884.639192]  [<ffffffff80402879>] ip_rcv+0x27c/0x2b9
> [ 1884.639195]  [<ffffffff803e05b0>] netif_receive_skb+0x471/0x496
> [ 1884.639201]  [<ffffffffa0ca07c0>] rtl8169_rx_interrupt+0x362/0x43d [r8169]
> [ 1884.639205]  [<ffffffffa0ca38b3>] rtl8169_poll+0x3f/0x1fe [r8169]
> [ 1884.639208]  [<ffffffff803de82c>] net_rx_action+0xae/0x19c
> [ 1884.639212]  [<ffffffff8024745d>] __do_softirq+0x8a/0x139
> [ 1884.639214]  [<ffffffff8021259c>] call_softirq+0x1c/0x30
> [ 1884.639217]  [<ffffffff80213d78>] do_softirq+0x44/0x8f
> [ 1884.639219]  [<ffffffff80247153>] irq_exit+0x3f/0x7e
> [ 1884.639222]  [<ffffffff80213ff3>] do_IRQ+0xc3/0xe4
> [ 1884.639224]  [<ffffffff80211d13>] ret_from_intr+0x0/0x29
> [ 1884.639225]  <EOI>  [<ffffffff8022704e>] ? native_safe_halt+0x6/0x8
> [ 1884.639230]  [<ffffffff802180c2>] ? default_idle+0x2e/0x4b
> [ 1884.639233]  [<ffffffff8021830c>] ? c1e_idle+0x109/0x110
> [ 1884.639235]  [<ffffffff802590c9>] ? atomic_notifier_call_chain+0x13/0x15
> [ 1884.639239]  [<ffffffff8021022e>] ? cpu_idle+0x59/0x9a
> [ 1884.639242]  [<ffffffff804925d6>] ? start_secondary+0x254/0x25b

yep, that's OK.  The kernel was excessively low on memory and the
network driver was unable to allocate a page for a received packet. 
The packet will just be dropped and everything should recover.  If you
get a lot of these warnings (one per minute?) then increasing the value
in /proc/sys/vm/min_free_kbytes should help.


Dave, we get quite a few reports of this nature, especially from e1000
(grr).  Do you think we could/should suppress the warning, by
sprinkling a few __GFP_NOWARNs in the right places?  It doesn't seem
like it's being very useful?


