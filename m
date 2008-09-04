From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: latest git crash (BUG/rt_fill_info)
Date: Thu, 4 Sep 2008 17:51:03 +0300
Message-ID: <200809041751.04163.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:43452 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbYIDOwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 10:52:25 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id 756C0131011
	for <netdev@vger.kernel.org>; Thu,  4 Sep 2008 17:52:53 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Single processor, working as NAT at office.
I will try to reproduce the bug. Crash is happening on "light" traffic, after 10-20 minutes of usage.

Sep  4 17:43:41 x.x.x.x [ 1084.917877] BUG: unable to handle kernel 
Sep  4 17:43:41 x.x.x.x paging request
Sep  4 17:43:41 x.x.x.x at 84e8dc55
Sep  4 17:43:41 x.x.x.x [ 1084.917943] IP:
Sep  4 17:43:41 x.x.x.x [<c02826be>] rt_fill_info+0x329/0x33f
Sep  4 17:43:41 x.x.x.x [ 1084.918006] Oops: 0000 [#1] 
Sep  4 17:43:41 x.x.x.x SMP 
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918033] Modules linked in:
Sep  4 17:43:41 x.x.x.x xt_tcpudp
Sep  4 17:43:41 x.x.x.x netconsole
Sep  4 17:43:41 x.x.x.x configfs
Sep  4 17:43:41 x.x.x.x ipt_MASQUERADE
Sep  4 17:43:41 x.x.x.x iptable_nat
Sep  4 17:43:41 x.x.x.x nf_nat
Sep  4 17:43:41 x.x.x.x nf_conntrack_ipv4
Sep  4 17:43:41 x.x.x.x nf_conntrack
Sep  4 17:43:41 x.x.x.x rtc_cmos
Sep  4 17:43:41 x.x.x.x rtc_core
Sep  4 17:43:41 x.x.x.x rtc_lib
Sep  4 17:43:41 x.x.x.x iptable_filter
Sep  4 17:43:41 x.x.x.x ip_tables
Sep  4 17:43:41 x.x.x.x x_tables
Sep  4 17:43:41 x.x.x.x 8021q
Sep  4 17:43:41 x.x.x.x garp
Sep  4 17:43:41 x.x.x.x stp
Sep  4 17:43:41 x.x.x.x llc
Sep  4 17:43:41 x.x.x.x tun
Sep  4 17:43:41 x.x.x.x loop
Sep  4 17:43:41 x.x.x.x tulip
Sep  4 17:43:41 x.x.x.x r8169
Sep  4 17:43:41 x.x.x.x sky2
Sep  4 17:43:41 x.x.x.x via_velocity
Sep  4 17:43:41 x.x.x.x via_rhine
Sep  4 17:43:41 x.x.x.x sis900
Sep  4 17:43:41 x.x.x.x ne2k_pci
Sep  4 17:43:41 x.x.x.x 8390
Sep  4 17:43:41 x.x.x.x skge
Sep  4 17:43:41 x.x.x.x tg3
Sep  4 17:43:41 x.x.x.x libphy
Sep  4 17:43:41 x.x.x.x 8139too
Sep  4 17:43:41 x.x.x.x e1000
Sep  4 17:43:41 x.x.x.x e100
Sep  4 17:43:41 x.x.x.x usb_storage
Sep  4 17:43:41 x.x.x.x mtdblock
Sep  4 17:43:41 x.x.x.x mtd_blkdevs
Sep  4 17:43:41 x.x.x.x usbhid
Sep  4 17:43:41 x.x.x.x ohci_hcd
Sep  4 17:43:41 x.x.x.x uhci_hcd
Sep  4 17:43:41 x.x.x.x ehci_hcd
Sep  4 17:43:41 x.x.x.x usbcore
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918318] 
Sep  4 17:43:41 x.x.x.x [ 1084.918318] Pid: 0, comm: swapper Not tainted (2.6.27-rc5-build-0034-00131-g5f17cfc #6)
Sep  4 17:43:41 x.x.x.x [ 1084.918318] EIP: 0060:[<c02826be>] EFLAGS: 00010293 CPU: 0
Sep  4 17:43:41 x.x.x.x [ 1084.918318] EIP is at rt_fill_info+0x329/0x33f
Sep  4 17:43:41 x.x.x.x [ 1084.918318] EAX: ceeab300 EBX: 00000000 ECX: 00000000 EDX: cee93000
Sep  4 17:43:41 x.x.x.x [ 1084.918318] ESI: ceeab300 EDI: cee98820 EBP: c098cf00 ESP: c098cee8
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Sep  4 17:43:41 x.x.x.x [ 1084.918318] Process swapper (pid: 0, ti=c098c000 task=c038e3cc task.ti=c03b5000)
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918318] Stack: 
Sep  4 17:43:41 x.x.x.x c028569a 
Sep  4 17:43:41 x.x.x.x ceeab330 
Sep  4 17:43:41 x.x.x.x c098cf18 
Sep  4 17:43:41 x.x.x.x cee98820 
Sep  4 17:43:41 x.x.x.x ceeab300 
Sep  4 17:43:41 x.x.x.x ceeab330 
Sep  4 17:43:41 x.x.x.x c098cf18 
Sep  4 17:43:41 x.x.x.x c028589d 
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918318]        
Sep  4 17:43:41 x.x.x.x cf8dd800 
Sep  4 17:43:41 x.x.x.x ceeab300 
Sep  4 17:43:41 x.x.x.x c03a32fc 
Sep  4 17:43:41 x.x.x.x c03b34a0 
Sep  4 17:43:41 x.x.x.x c098cf54 
Sep  4 17:43:41 x.x.x.x c026a9f8 
Sep  4 17:43:41 x.x.x.x cf8dd800 
Sep  4 17:43:41 x.x.x.x c03b34b8 
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918318]        
Sep  4 17:43:41 x.x.x.x cf8dd800 
Sep  4 17:43:41 x.x.x.x 00000000 
Sep  4 17:43:41 x.x.x.x 00000001 
Sep  4 17:43:41 x.x.x.x 00080000 
Sep  4 17:43:41 x.x.x.x ceeab300 
Sep  4 17:43:41 x.x.x.x ceeab3b0 
Sep  4 17:43:41 x.x.x.x c02775e4 
Sep  4 17:43:41 x.x.x.x ceeab3b0 
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918318] Call Trace:
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c028569a>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x ip_rcv_finish+0x2a6/0x2bc
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c028589d>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x ip_rcv+0x1ed/0x217
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c026a9f8>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x netif_receive_skb+0x3cd/0x400
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c02775e4>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x eth_type_trans+0x28/0xcc
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<d08e244e>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x rtl8139_poll+0x270/0x391 [8139too]
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c0269414>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x net_rx_action+0xbb/0x1e5
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c012514f>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x __do_softirq+0x7b/0xf4
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c01250d4>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x __do_softirq+0x0/0xf4
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c01060c7>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x do_softirq+0x65/0xb6
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c014a395>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x handle_fasteoi_irq+0x0/0xb6
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c0124d74>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x irq_exit+0x44/0x79
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c010604c>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x do_IRQ+0xae/0xc4
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c010429c>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x common_interrupt+0x28/0x30
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c013007b>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x sys_clock_getres+0x43/0x84
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c010903e>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x default_idle+0x32/0x51
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c0102a03>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x cpu_idle+0xd4/0xf5
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  [<c02b9992>] 
Sep  4 17:43:41 x.x.x.x ? 
Sep  4 17:43:41 x.x.x.x rest_init+0x4e/0x50
Sep  4 17:43:41 x.x.x.x [ 1084.918318]  =======================
Sep  4 17:43:41 x.x.x.x [ 1084.918318] Code: 
Sep  4 17:43:41 x.x.x.x 75 
Sep  4 17:43:41 x.x.x.x e8 
Sep  4 17:43:41 x.x.x.x e8 
Sep  4 17:43:41 x.x.x.x 19 
Sep  4 17:43:41 x.x.x.x 06 
Sep  4 17:43:41 x.x.x.x ff 
Sep  4 17:43:41 x.x.x.x ff 
Sep  4 17:43:41 x.x.x.x 83 
Sep  4 17:43:41 x.x.x.x c4 
Sep  4 17:43:41 x.x.x.x 10 
Sep  4 17:43:41 x.x.x.x 85 
Sep  4 17:43:41 x.x.x.x c0 
Sep  4 17:43:41 x.x.x.x 78 
Sep  4 17:43:41 x.x.x.x 13 
Sep  4 17:43:41 x.x.x.x 8b 
Sep  4 17:43:41 x.x.x.x 86 
Sep  4 17:43:41 x.x.x.x 9c 
Sep  4 17:43:41 x.x.x.x 00 
Sep  4 17:43:41 x.x.x.x 00 
Sep  4 17:43:41 x.x.x.x 00 
Sep  4 17:43:41 x.x.x.x 8b 
Sep  4 17:43:41 x.x.x.x 55 
Sep  4 17:43:41 x.x.x.x dc 
Sep  4 17:43:41 x.x.x.x 2b 
Sep  4 17:43:41 x.x.x.x 45 
Sep  4 17:43:41 x.x.x.x dc 
Sep  4 17:43:41 x.x.x.x 89 
Sep  4 17:43:41 x.x.x.x 02 
Sep  4 17:43:41 x.x.x.x 8b 
Sep  4 17:43:41 x.x.x.x 46 
Sep  4 17:43:41 x.x.x.x 50 
Sep  4 17:43:41 x.x.x.x eb 
Sep  4 17:43:41 x.x.x.x 18 
Sep  4 17:43:41 x.x.x.x 8b 
Sep  4 17:43:41 x.x.x.x 8e 
Sep  4 17:43:41 x.x.x.x a8 
Sep  4 17:43:41 x.x.x.x 00 
Sep  4 17:43:41 x.x.x.x 00 
Sep  4 17:43:41 x.x.x.x 00 
Sep  4 17:43:41 x.x.x.x 89 
Sep  4 17:43:41 x.x.x.x f0 
Sep  4 17:43:41 x.x.x.x 29 
Sep  4 17:43:41 x.x.x.x 4d 
Sep  4 17:43:41 x.x.x.x unparseable log message: "<dc> "
Sep  4 17:43:41 x.x.x.x 8b 
Sep  4 17:43:41 x.x.x.x 55 
Sep  4 17:43:41 x.x.x.x dc 
Sep  4 17:43:41 x.x.x.x e8 
Sep  4 17:43:41 x.x.x.x 84 
Sep  4 17:43:41 x.x.x.x 22 
Sep  4 17:43:41 x.x.x.x fe 
Sep  4 17:43:41 x.x.x.x ff 
Sep  4 17:43:41 x.x.x.x b8 
Sep  4 17:43:41 x.x.x.x a6 
Sep  4 17:43:41 x.x.x.x ff 
Sep  4 17:43:41 x.x.x.x ff 
Sep  4 17:43:41 x.x.x.x ff 
Sep  4 17:43:41 x.x.x.x 8d 
Sep  4 17:43:41 x.x.x.x 65 
Sep  4 17:43:41 x.x.x.x f4 
Sep  4 17:43:41 x.x.x.x 5b 
Sep  4 17:43:41 x.x.x.x 5e 
Sep  4 17:43:41 x.x.x.x 5f 
Sep  4 17:43:41 x.x.x.x 5d 
Sep  4 17:43:41 x.x.x.x 
Sep  4 17:43:41 x.x.x.x [ 1084.918318] EIP: [<c02826be>] 
Sep  4 17:43:41 x.x.x.x rt_fill_info+0x329/0x33f
Sep  4 17:43:41 x.x.x.x SS:ESP 0068:c098cee8
Sep  4 17:43:41 x.x.x.x [ 1084.925116] Kernel panic - not syncing: Fatal exception in interrupt
Sep  4 17:43:41 x.x.x.x [ 1084.925227] Rebooting in 5 seconds..
