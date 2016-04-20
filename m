From: Tony Lindgren <tony@atomide.com>
Subject: Regression in next for smsc911x with tigthen lockdep checks
Date: Wed, 20 Apr 2016 08:01:09 -0700
Message-ID: <20160420150108.GF5995@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:51542 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791AbcDTPBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 11:01:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Looks like commit fafc4e1ea1a4 ("sock: tigthen lockdep checks for
sock_owned_by_user") in next causes a regression at least for
smsc911x with CONFIG_LOCKDEP. It keeps spamming with the following
message. Any ideas?

Regards,

Tony

8< ----------------
WARNING: CPU: 0 PID: 0 at include/net/sock.h:1408 udp_queue_rcv_skb+0x398/0x640
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.6.0-rc4-next-20160420 #1087
Hardware name: Generic OMAP36xx (Flattened Device Tree)
[<c01103c8>] (unwind_backtrace) from [<c010c400>] (show_stack+0x10/0x14)
[<c010c400>] (show_stack) from [<c04813ec>] (dump_stack+0xb0/0xe4)
[<c04813ec>] (dump_stack) from [<c0137afc>] (__warn+0xd8/0x104)
[<c0137afc>] (__warn) from [<c0137bd8>] (warn_slowpath_null+0x20/0x28)
[<c0137bd8>] (warn_slowpath_null) from [<c06d5310>] (udp_queue_rcv_skb+0x398/0x640)
[<c06d5310>] (udp_queue_rcv_skb) from [<c06d5a84>] (__udp4_lib_rcv+0x4cc/0xc0c)
[<c06d5a84>] (__udp4_lib_rcv) from [<c069e980>] (ip_local_deliver_finish+0xcc/0x4f4)
[<c069e980>] (ip_local_deliver_finish) from [<c069f748>] (ip_local_deliver+0xcc/0xd8)
[<c069f748>] (ip_local_deliver) from [<c069ee64>] (ip_rcv_finish+0xbc/0x700)
[<c069ee64>] (ip_rcv_finish) from [<c069fbe0>] (ip_rcv+0x48c/0x6d4)
[<c069fbe0>] (ip_rcv) from [<c0662790>] (__netif_receive_skb_core+0x380/0xa10)
[<c0662790>] (__netif_receive_skb_core) from [<c0665138>] (netif_receive_skb_internal+
0x74/0x1ec)
[<c0665138>] (netif_receive_skb_internal) from [<c05da394>] (smsc911x_poll+0xd8/0x228)
[<c05da394>] (smsc911x_poll) from [<c0665cd0>] (net_rx_action+0x124/0x470)
[<c0665cd0>] (net_rx_action) from [<c013e114>] (__do_softirq+0xc8/0x54c)
[<c013e114>] (__do_softirq) from [<c013e8b8>] (irq_exit+0xbc/0x130)
[<c013e8b8>] (irq_exit) from [<c019c8c8>] (__handle_domain_irq+0x6c/0xdc)
[<c019c8c8>] (__handle_domain_irq) from [<c07af2b8>] (__irq_svc+0x58/0x78)
[<c07af2b8>] (__irq_svc) from [<c0603884>] (cpuidle_enter_state+0xc4/0x3d4)
[<c0603884>] (cpuidle_enter_state) from [<c0183be0>] (cpu_startup_entry+0x198/0x3a0)
[<c0183be0>] (cpu_startup_entry) from [<c0b00c08>] (start_kernel+0x350/0x3c8)
[<c0b00c08>] (start_kernel) from [<8000807c>] (0x8000807c)
