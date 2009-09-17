From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: 2.6.31 / WARNING / tcp_input
Date: Thu, 17 Sep 2009 20:33:38 +0300
Message-ID: <200909172033.38960.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44576 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984AbZIQRbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 13:31:45 -0400
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 187192EC001
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2009 20:31:40 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing unusual in configs, heavily loaded HTTP proxy.

Some tunings:
sysctl -w net.core.somaxconn=4096
sysctl -w net.core.wmem_max=384000
kernel.panic_on_oops=1
kernel.panic=5
vm.min_free_kbytes=16384
net.ipv4.tcp_max_syn_backlog=10240
net.ipv4.conf.all.arp_filter=1
vm.panic_on_oom=2
net.core.netdev_max_backlog=4000


[  123.221032] ------------[ cut here ]------------
[  123.221183] WARNING: at net/ipv4/tcp_input.c:2920 tcp_ack+0xc6c/0x17bf()
[  123.221316] Hardware name: PowerEdge 2900
[  123.221438] Modules linked in: ext4 jbd2 mptspi mptsas scsi_transport_spi 
scsi_transport_sas mptscsih mptbase xt_owner ipt_REDIRECT xt_tcpudp xt_dscp 
iptable_raw iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack rtc_cmos 
rtc_core rtc_lib nf_defrag_ipv4 iptable_filter ip_tables x_tables 8021q garp 
stp llc loop usb_storage mtdblock mtd_blkdevs mtd iTCO_wdt 
iTCO_vendor_support pata_acpi ata_piix ata_generic libata megaraid_sas bnx2 
sr_mod cdrom tulip r8169 sky2 via_velocity via_rhine sis900 ne2k_pci 8390 
skge tg3 libphy 8139too e1000 e100 usbhid ohci_hcd uhci_hcd ehci_hcd usbcore 
nls_base
[  123.225025] Pid: 0, comm: swapper Not tainted 2.6.31-build-0046-32bit #20
[  123.225162] Call Trace:
[  123.225289]  [<c012d051>] warn_slowpath_common+0x60/0x90
[  123.225415]  [<c012d08e>] warn_slowpath_null+0xd/0x10
[  123.225540]  [<c02c8e15>] tcp_ack+0xc6c/0x17bf
[  123.225665]  [<c02ca51c>] tcp_rcv_established+0x6dc/0x8fd
[  123.225791]  [<c02cff7f>] tcp_v4_do_rcv+0x24/0x17e
[  123.225915]  [<c02d04c0>] tcp_v4_rcv+0x3e7/0x5a8
[  123.226039]  [<c02b953a>] ip_local_deliver_finish+0xb6/0x12e
[  123.226174]  [<c02b9613>] ip_local_deliver+0x61/0x6a
[  123.226303]  [<c02b9215>] ip_rcv_finish+0x29d/0x2b3
[  123.226427]  [<c02b9458>] ip_rcv+0x22d/0x259
[  123.226552]  [<c029d700>] netif_receive_skb+0x439/0x458
[  123.226677]  [<c02ab3ca>] ? eth_type_trans+0x25/0xa9
[  123.226808]  [<f84c1193>] bnx2_poll_work+0xffd/0x1137 [bnx2]
[  123.226938]  [<c012331a>] ? enqueue_task_fair+0x131/0x173
[  123.227069]  [<c011f015>] ? activate_task+0x3c/0x4b
[  123.227206]  [<f84c145f>] bnx2_poll+0xf8/0x1d8 [bnx2]
[  123.227331]  [<c029dc93>] net_rx_action+0x93/0x177
[  123.227457]  [<c0131ad9>] __do_softirq+0xa7/0x144
[  123.227582]  [<c0131a32>] ? __do_softirq+0x0/0x144
[  123.227705]  <IRQ>  [<c0131853>] ? irq_exit+0x29/0x5c
[  123.227876]  [<c0104393>] ? do_IRQ+0x80/0x96
[  123.228000]  [<c0102f49>] ? common_interrupt+0x29/0x30
[  123.228136]  [<c0108a1e>] ? mwait_idle+0x8a/0xb9
[  123.228266]  [<c0101bf0>] ? cpu_idle+0x44/0x60
[  123.228390]  [<c02f90ed>] ? start_secondary+0x195/0x19a
[  123.228515] ---[ end trace 22f267765b97f808 ]---
