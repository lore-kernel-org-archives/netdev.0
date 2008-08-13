From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 12:13:40 -0400
Message-ID: <48A30834.4090802@myri.com>
References: <48A23137.2010107@myri.com> <20080812.181549.229367205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1965 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752912AbYHMQVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 12:21:17 -0400
In-Reply-To: <20080812.181549.229367205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Tue, 12 Aug 2008 20:56:23 -0400
> 
>>      pkt_sched: Schedule qdiscs instead of netdev_queue.
> 
> While I'm waiting for your beforehand profile data,
> here is a stab in the dark patch which might fix
> the problem.
> 
> Robert, this could explain some of the things in the
> multiqueue testing profile you sent me a week or so
> ago.
> 
> Let me know how well it works:

Excellent!  This completely fixes the increased CPU
utilization I observed on both 10GbE and 1GbE interfaces,
and CPU utilization is now reduced back to 2.6.26 levels.

Oprofile now is nearly identical to what it was prior to
37437bb2e1ae8af470dfcd5b4ff454110894ccaf:

8363      6.5081  vmlinux                  _raw_spin_lock
5612      4.3672  oprofiled                (no symbols)
4420      3.4396  ehci_hcd                 (no symbols)
4325      3.3657  vmlinux                  handle_IRQ_event
3688      2.8700  vmlinux                  default_idle
3164      2.4622  vmlinux                  nv_start_xmit_optimized
3092      2.4062  vmlinux                  sk_run_filter
3072      2.3906  vmlinux                  tcp_ack
2969      2.3105  vmlinux                  __copy_skb_header
2453      1.9089  vmlinux                  kmem_cache_free
2400      1.8677  vmlinux                  IRQ0x69_interrupt
2295      1.7860  vmlinux                  nv_rx_process_optimized
2092      1.6280  vmlinux                  kmem_cache_alloc
2072      1.6124  vmlinux                  kfree
2049      1.5945  vmlinux                  packet_rcv_spkt
1984      1.5439  vmlinux                  __tcp_push_pending_frames
1942      1.5113  vmlinux                  nv_nic_irq_optimized
1933      1.5043  vmlinux                  _raw_spin_unlock
1637      1.2739  vmlinux                  nv_tx_done_optimized
1630      1.2685  vmlinux                  eth_type_trans
1517      1.1805  vmlinux                  __qdisc_run



Thank you,

Drew
