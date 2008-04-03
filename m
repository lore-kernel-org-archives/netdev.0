From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Three TCP/IP warnings in 2.6.25-rc7-git1
Date: Wed, 02 Apr 2008 22:21:09 -0700
Message-ID: <47F46945.40500@linux.intel.com>
References: <47F15200.3060706@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, David Miller <davem@davemloft.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:13879 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751861AbYDCFVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:21:15 -0400
In-Reply-To: <47F15200.3060706@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> Hi,
> 
> kerneloops.org still has 3 tcp/ip related warnings in the top 15 of 
> oopses/warnings
> that users (mostly of Fedora 9 alpha/beta, but also LKML and netdev) see.
> All three have been seen as recent as 2.6.25-rc7-git1, but seem to date 
> back to around
> 2.6.24-rc4 era.


the warnings below are still present in 2.6.25-rc8.....

It would be not so nice to ship a 2.6.25 that triggers these frequently,
it has the risk of causing many user bugreports to this list and other
places...

> 
> Number 1 is a WARN_ON in tcp_ack(), there are several backtraces at
> http://www.kerneloops.org/search.php?search=tcp_ack but the core
> comes down to the following:
> 
> tcp_ack
> tcp_rcv_established
> tcp_v4_do_rcv
> tcp_v4_rcv
> ip_local_deliver_finish
> ip_local_deliver
> ip_rcv_finish
> ip_rcv
> netif_receive_skb
> tg3_poll or nv_napi_poll or the e1000 equivalent
> net_rx_action
> __do_softirq
> do_softirq
> irq_exit
> do_IRQ
> 
> 
> Number 2 is a WARN_ON in tcp_enter_frto(), backtraces at
> http://www.kerneloops.org/search.php?search=tcp_enter_frto
> the core backtrace comes down to
> 
> tcp_enter_frto
> tcp_write_timer
> run_timer_softirq
> __do_softirq
> do_softirq
> 
> 
> Number 3 is a WARN_ON in tcp_mark_head+lost, backtraces at
> http://www.kerneloops.org/search.php?search=tcp_mark_head_lost
> the core backtrace comes down to
> 
> tcp_mark_head_lost
> tcp_ack
> tcp_rcv_established
> tcp_v4_do_rcv
> tcp_v4_rcv
> ip_local_deliver_finish
> ip_local_deliver
> ip_rcv_finish
> ip_rcv
> netif_receive_skb
> tg3_poll or nv_napi_poll
> net_rx_action
> __do_softirq
> 
> 
> The URLs link to several mailinglist/bugzilla postings for these.
> Note that not all backtraces have such a thing; a lot of these backtraces
> are collected by an automated daemon and submitted directly from 
> testers/users
> systems to the database.
> 

