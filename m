From: Pavel Mateja <pavel@netsafe.cz>
Subject: eth0: hw csum failure
Date: Mon, 5 Dec 2011 13:51:26 +0100
Message-ID: <201112051351.26798.pavel@netsafe.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.netsafe.cz ([83.223.49.132]:37436 "EHLO gate1.netsafe.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932148Ab1LEM6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 07:58:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm trying new kernel and I got my dmesg flooded with traces:

[   78.068024] eth0: hw csum failure.
[   78.068030] Pid: 0, comm: kworker/0:0 Not tainted 3.1.0-rc3+ #13
[   78.068033] Call Trace:
[   78.068035]  <IRQ>  [<ffffffff81225bc6>] ? netdev_rx_csum_fault+0x29/0x31
[   78.068048]  [<ffffffff8121fb86>] ? __skb_checksum_complete_head+0x41/0x53
[   78.068058]  [<ffffffffa02da598>] ? br_multicast_rcv+0x7e8/0xca1 [bridge]
[   78.068063]  [<ffffffff8118b424>] ? swiotlb_map_sg_attrs+0xe8/0x10e
[   78.068077]  [<ffffffffa0051547>] ? ahci_qc_prep+0x59/0x108 [libahci]
[   78.068083]  [<ffffffffa0050e15>] ? ahci_qc_issue+0x11/0xdb [libahci]
[   78.068093]  [<ffffffffa0021bd2>] ? ata_qc_issue+0x28b/0x2c5 [libata]
[   78.068099]  [<ffffffff8102ec2c>] ? select_task_rq_fair+0x369/0x610
[   78.068108]  [<ffffffffa0024fb2>] ? ata_qc_set_pc_nbytes+0x1b/0x1b [libata]
[   78.068114]  [<ffffffffa02d4fb8>] ? br_handle_frame_finish+0x90/0x1fe [bridge]
[   78.068121]  [<ffffffffa02d52cc>] ? br_handle_frame+0x1a6/0x1be [bridge]
[   78.068127]  [<ffffffffa02d5126>] ? br_handle_frame_finish+0x1fe/0x1fe [bridge]
[   78.068132]  [<ffffffff81223181>] ? __netif_receive_skb+0x162/0x2a8
[   78.068136]  [<ffffffff812264eb>] ? netif_receive_skb+0x63/0x69
[   78.068140]  [<ffffffff8122691a>] ? napi_gro_receive+0x1d/0x2b
[   78.068143]  [<ffffffff81226567>] ? napi_skb_finish+0x1c/0x31
[   78.068151]  [<ffffffffa00c4c9f>] ? sky2_poll+0x781/0x99c [sky2]
[   78.068155]  [<ffffffff812269ea>] ? net_rx_action+0x61/0x14f
[   78.068161]  [<ffffffff81039e2b>] ? __do_softirq+0xb5/0x16f
[   78.068166]  [<ffffffff812ce2ac>] ? call_softirq+0x1c/0x30
[   78.068170]  [<ffffffff8100375b>] ? do_softirq+0x2e/0x63
[   78.068174]  [<ffffffff8103a087>] ? irq_exit+0x3c/0x9a
[   78.068177]  [<ffffffff810034a1>] ? do_IRQ+0x82/0x98
[   78.068182]  [<ffffffff812c792b>] ? common_interrupt+0x6b/0x6b
[   78.068184]  <EOI>  [<ffffffff81008056>] ? mwait_idle+0x7f/0xa5
[   78.068192]  [<ffffffff81008049>] ? mwait_idle+0x72/0xa5
[   78.068195]  [<ffffffff8100123b>] ? cpu_idle+0xa0/0xda
[   78.068199]  [<ffffffff812c7654>] ? _raw_spin_unlock_irqrestore+0x5/0xf
[   78.068205]  [<ffffffff812bb779>] ? start_secondary+0x1c9/0x1cf

If i did git bisect right it was caused by commit
4b275d7efa1c4412f0d572fcd7f78ed0919370b3
bridge: Pseudo-header required for the checksum of ICMPv6

Problem disappears when I turn off HW checksum via ethtool.

Can anybody help?
-- 
Pavel Mateja
