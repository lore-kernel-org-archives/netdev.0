From: Andrew Watts <akwatts@ymail.com>
Subject: kernel panic with time-stamping in phy devices (monitor mode)
Date: Thu, 2 Dec 2010 08:05:45 -0800 (PST)
Message-ID: <252997.92320.qm@web111013.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm7-vm1.bullet.mail.ne1.yahoo.com ([98.138.90.250]:24911 "HELO
	nm7-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752744Ab0LBQFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 11:05:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

The 'time stamping in phy devices' code introduced in 2.6.36
(c1f19b51d1d87f3e3bb7e6648f43f7d57ed2da6b et al.) triggers
kernel panics when wireless devices are placed in monitor mode
(tested with b43 and ath5k devices on a 32-bit system).

To reproduce, set CONFIG_NETWORK_PHY_TIMESTAMPING=y and put a
wireless device into monitor mode:

 # ifconfig wlan0 down
 # iwconfig wlan0 mode monitor 
 # ifconfig wlan0 up

~ Andy

==============

 [<c14455ad>] ? __alloc_skb+0x53/0xf8
 [<f92fdd57>] ? b43_dma_rx+0x18a/0x342 [b43]
 [<f92e8475>] ? b43_do_interrupt_thread+0x420/0x92e [b43]
 [<c1027731>] ? __dequeue_entity+0x31/0x35
 [<c1027a44>] ? set_next_entity+0xad/0xbb
 [<f92e899b>] ? b43_interrupt_thread_handler+0x18/0x2b [b43]
 [<c107c378>] ? irq_thread+0xb6/0x19e
 [<c15625a0>] ? schedule+0x254/0x566
 [<c107c2c2>] ? irq_thread+0x0/0x19e
 [<c10448b1>] ? kthread+0x67/0x69
 [<c104484a>] ? kthread+0x0/0x69
 [<c100323e>] ? kernel_thread_helper+0x6/0x18
Code: 4c 24 14 8b 88 a8 00 00 00 89 4c 24 10 89 54 24 0c 8b
40 50 89 44 24 08 8b 45 04 89 44 24 04 c7 04 24 30 74 7a c1
e8 b5 d2 11 00 <0f> 0b eb fe 55 89 e5 56 53 83 ec 24 8b 88
a0 00 00 00 8b 58 54
EIP: [<c1444ea0>] skb_push+0x7d/0x81 SS:ESP 0068:cee01d78
---[ end trace af1c99818e62b195 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 6674, comm: irq/18-b43 Tainted: G     D     2.6.36.1
Call Trace:
 [<c156217d>] ? printk+0x28/0x2a
 [<c156205c>] panic+0x57/0x150
 [<c1564adf>] oops_begin+0x0/0x40
 [<c1004e36>] die+0x49/0x5d
 [<c1564304>] do_trap+0x84/0xad
 [<c10037e5>] ? do_invalid_op+0x0/0x93
 [<c100386b>] do_invalid_op+0x86/0x93
 [<c1444ea0>] ? skb_push+0x7d/0x81
 [<c15640b9>] error_code+0x65/0x6c
 [<c1444ea0>] ? skb_push+0x7d/0x81
 [<c145f721>] ? skb_defer_rx_timestamp+0x12/0x5a
 [<c145f721>] skb_defer_rx_timestamp+0x12/0x5a
 [<c144d23c>] netif_receive_skb+0x1f/0x47
 [<c153a6e8>] ieee80211_rx+0x661/0x8e1
 [<f85daca2>] ? ssb_pci_read32+0x19/0x31 [ssb]
 [<f92e54cf>] ? b43_tsf_read+0x2a/0x47 [b43]
 [<f92f8d42>] b43_rx+0x24c/0x5eb [b43]
 [<c14455ad>] ? __alloc_skb+0x53/0xf8
 [<f92fdd57>] b43_dma_rx+0x18a/0x342 [b43]
 [<f92e8475>] b43_do_interrupt_thread+0x420/0x92e [b43]
 [<c1027731>] ? __dequeue_entity+0x31/0x35
 [<c1027a44>] ? set_next_entity+0xad/0xbb
 [<f92e899b>] b43_interrupt_thread_handler+0x18/0x2b [b43]
 [<c107c378>] irq_thread+0xb6/0x19e
 [<c15625a0>] ? schedule+0x254/0x566
 [<c107c2c2>] ? irq_thread+0x0/0x19e
 [<c10448b1>] kthread+0x67/0x69
 [<c104484a>] ? kthread+0x0/0x69
 [<c100323e>] kernel_thread_helper+0x6/0x18



      
