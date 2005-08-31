From: Daniel Drake <dsd@gentoo.org>
Subject: prism54 vs netfilter problem? Badness in local_bh_enable at
	kernel/softirq.c:140
Date: Wed, 31 Aug 2005 12:53:23 +0100
Message-ID: <43159A33.8010600@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: prism54-private@prism54.org
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi,

A gentoo user reported these messages on boot:

eth0: resetting device...
eth0: uploading firmware...
eth0: firmware version: 1.0.4.3
eth0: firmware upload complete
eth0: interface reset complete
spurious 8259A interrupt: IRQ7.
eth0: islpci_close ()
eth0: resetting device...
eth0: uploading firmware...
eth0: firmware version: 1.0.4.3
eth0: firmware upload complete
eth0: interface reset complete
Badness in local_bh_enable at kernel/softirq.c:140
  [<c0125f9f>] local_bh_enable+0x8f/0xa0
  [<c03a71b9>] destroy_conntrack+0xd9/0xf0
  [<c0357d8a>] __kfree_skb+0x7a/0xf0
  [<c79181fa>] islpci_eth_transmit+0x15a/0x380 [prism54]
  [<c035d692>] dev_queue_xmit_nit+0xd2/0x140
  [<c036b04e>] qdisc_restart+0x15e/0x200
  [<c035dabf>] dev_queue_xmit+0x1cf/0x270
  [<c0363b23>] neigh_resolve_output+0xd3/0x1d0
  [<c03636f6>] neigh_update+0x2a6/0x350
  [<c0397963>] arp_process+0x1c3/0x570
  [<c036902e>] nf_hook_slow+0x7e/0x140
  [<c03977a0>] arp_process+0x0/0x570
  [<c0397e12>] arp_rcv+0x102/0x180
  [<c03977a0>] arp_process+0x0/0x570
  [<c035e0a8>] netif_receive_skb+0x148/0x1d0
  [<c035e1c9>] process_backlog+0x99/0x130
  [<c035e2e1>] net_rx_action+0x81/0x110
  [<c0125eb6>] __do_softirq+0xd6/0xf0
  [<c0125f05>] do_softirq+0x35/0x40
  [<c0125ff5>] irq_exit+0x45/0x50
  [<c0105aee>] do_IRQ+0x1e/0x30
  [<c0103d72>] common_interrupt+0x1a/0x20
  [<c0277a26>] acpi_processor_idle+0x126/0x270
  [<c0101110>] cpu_idle+0x70/0x80
  [<c04f6959>] start_kernel+0x169/0x190
  [<c04f6370>] unknown_bootoption+0x0/0x1d0
Badness in local_bh_enable at kernel/softirq.c:140
  [<c0125f9f>] local_bh_enable+0x8f/0xa0
  [<c03a717a>] destroy_conntrack+0x9a/0xf0
  [<c0357d8a>] __kfree_skb+0x7a/0xf0
  [<c79181fa>] islpci_eth_transmit+0x15a/0x380 [prism54]
  [<c035d692>] dev_queue_xmit_nit+0xd2/0x140
  [<c036b04e>] qdisc_restart+0x15e/0x200
  [<c035dabf>] dev_queue_xmit+0x1cf/0x270
  [<c0363b23>] neigh_resolve_output+0xd3/0x1d0
  [<c03636f6>] neigh_update+0x2a6/0x350
  [<c0397963>] arp_process+0x1c3/0x570
  [<c036902e>] nf_hook_slow+0x7e/0x140
  [<c03977a0>] arp_process+0x0/0x570
  [<c0397e12>] arp_rcv+0x102/0x180
  [<c03977a0>] arp_process+0x0/0x570
  [<c035e0a8>] netif_receive_skb+0x148/0x1d0
  [<c035e1c9>] process_backlog+0x99/0x130
  [<c035e2e1>] net_rx_action+0x81/0x110
  [<c0125eb6>] __do_softirq+0xd6/0xf0
  [<c0125f05>] do_softirq+0x35/0x40
  [<c0125ff5>] irq_exit+0x45/0x50
  [<c0105aee>] do_IRQ+0x1e/0x30
  [<c0103d72>] common_interrupt+0x1a/0x20
  [<c0277a26>] acpi_processor_idle+0x126/0x270
  [<c0101110>] cpu_idle+0x70/0x80
  [<c04f6959>] start_kernel+0x169/0x190
  [<c04f6370>] unknown_bootoption+0x0/0x1d0

This isn't a reproducible problem and apparently everything worked fine even 
after these messages had appeared. Just thought I should point out that 
something isn't quite right somewhere.

The Gentoo bug report is here:

	http://bugs.gentoo.org/show_bug.cgi?id=103803

Something similar has been reported previously:

	http://prism54.org/pipermail/prism54-users/2003-November/000083.html
	http://prism54.org/pipermail/prism54-users/2003-November/000047.html

Hope this is useful.

Daniel
