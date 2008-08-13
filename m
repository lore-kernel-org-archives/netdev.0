From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 11:06:11 -0400
Message-ID: <48A2F863.7040402@myri.com>
References: <48A23137.2010107@myri.com> <20080812.180535.99302127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1917 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754548AbYHMPGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 11:06:15 -0400
In-Reply-To: <20080812.180535.99302127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Tue, 12 Aug 2008 20:56:23 -0400
> 
>> According to oprofile, the system is spending a lot of
>> time in __qdisc_run() when sending on the 1GbE forcedeth
>> interface:
> 
> What does the profile look like beforehand?

The qdisc stuff is gone, and nearly everything is in the
noise.  Beforehand, we're at ~15% CPU.  Here is the
first page or so from opreport -l from immediately
prior:

7566      6.4373  vmlinux                  _raw_spin_lock
5894      5.0147  oprofiled                (no symbols)
4136      3.5190  ehci_hcd                 (no symbols)
3965      3.3735  vmlinux                  handle_IRQ_event
3333      2.8358  vmlinux                  tcp_ack
2952      2.5116  vmlinux                  __copy_skb_header
2869      2.4410  vmlinux                  default_idle
2702      2.2989  vmlinux                  nv_rx_process_optimized
2511      2.1364  vmlinux                  nv_start_xmit_optimized
2310      1.9654  vmlinux                  sk_run_filter
2157      1.8352  vmlinux                  kmem_cache_alloc
2139      1.8199  vmlinux                  IRQ0x69_interrupt
1797      1.5289  vmlinux                  nv_nic_irq_optimized
1796      1.5281  vmlinux                  kmem_cache_free
1784      1.5179  vmlinux                  kfree
1690      1.4379  vmlinux                  _raw_spin_unlock
1594      1.3562  vmlinux                  tcp_sendpage
1578      1.3426  vmlinux                  __tcp_push_pending_frames
1576      1.3409  vmlinux                  packet_rcv_spkt
1560      1.3273  vmlinux                  __inet_lookup_established
1558      1.3256  vmlinux                  nv_tx_done_optimized

[ On this system, forcedeth shares an irq with ehci_hcd,
so that's why that is so high.]

Drew
