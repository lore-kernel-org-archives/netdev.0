From: "Alexandros C. Couloumbis" <alex@ozo.com>
Subject: [natsemi] DMA-API: device driver failed to check map error
Date: Fri, 28 Feb 2014 01:19:54 +0200
Message-ID: <cc15fd3eec43833f03996a367f91d041@webmail.ozo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozonet.static.otenet.gr ([79.129.116.252]:40499 "EHLO
	orion.ozo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbaB0Xmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 18:42:31 -0500
Received: from webmail.ozo.com (localhost [127.0.0.1])
	by orion.ozo.com (8.14.7/8.14.7) with ESMTP id s1RNJsMS011591
	for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 01:19:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I got below warning on current linux 3.13.5

bus: 'pci': add driver natsemi
kobject: 'natsemi' (c7121780): kobject_add_internal: parent: 'drivers', 
set: 'drivers'
bus: 'pci': driver_probe_device: matched device 0000:00:0e.0 with 
driver natsemi
bus: 'pci': really_probe: probing driver natsemi with device 
0000:00:0e.0
natsemi dp8381x driver, version 2.1, Sept 11, 2006
   originally by Donald Becker <becker@scyld.com>
   2.4.x kernel port by Jeff Garzik, Tjeerd Mulder
device: 'eth0': device_add
kobject: 'net' (c71387c0): kobject_add_internal: parent: 
'0000:00:0e.0', set: '(null)'
kobject: 'eth0' (c782fa58): kobject_add_internal: parent: 'net', set: 
'devices'
kobject: 'eth0' (c782fa58): kobject_uevent_env
kobject: 'eth0' (c782fa58): fill_kobj_path: path = 
'/devices/pci0000:00/0000:00:0e.0/net/eth0'
kobject: 'queues' (c7137488): kobject_add_internal: parent: 'eth0', 
set: '<NULL>'
kobject: 'queues' (c7137488): kobject_uevent_env
kobject: 'queues' (c7137488): kobject_uevent_env: filter function 
caused the event to drop!
kobject: 'tx-0' (c789888c): kobject_add_internal: parent: 'queues', 
set: 'queues'
kobject: 'tx-0' (c789888c): kobject_uevent_env
kobject: 'tx-0' (c789888c): fill_kobj_path: path = 
'/devices/pci0000:00/0000:00:0e.0/net/eth0/queues/tx-0'
natsemi eth0: NatSemi DP8381[56] at 0x80000000 (0000:00:0e.0), 
00:0d:b9:01:3b:6c, IRQ 10, port TP.
driver: '0000:00:0e.0': driver_bound: bound to device 'natsemi'
bus: 'pci': really_probe: bound device 0000:00:0e.0 to driver natsemi
kobject: 'natsemi' (c7121780): kobject_uevent_env
kobject: 'natsemi' (c7121780): fill_kobj_path: path = 
'/bus/pci/drivers/natsemi'
eth0: DSPCFG accepted after 0 usec.
eth0: link up.
eth0: Setting full-duplex based on negotiated link capability.
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:937 check_unmap+0x5ca/0x66b()
natsemi 0000:00:0e.0: DMA-API: device driver failed to check map 
error[device address=0x00000000066c0040] [size=1538 bytes] [mapped as 
single]
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.5 #5
  00000000 c1246fdc c7809e90 c11d4746 c7809ea4 c1016ad2 c122e39f 
c7802af0
  c7880b00 c7809ebc c1016b0f 00000009 c7809eb4 c1247488 c7809ed0 
c7809f1c
  c110b360 c1246fdc 000003a9 c1247488 c12524af c7802af0 066c0040 
00000000
Call Trace:
  [<c11d4746>] dump_stack+0x16/0x18
  [<c1016ad2>] warn_slowpath_common+0x52/0x69
  [<c1016b0f>] warn_slowpath_fmt+0x26/0x2a
  [<c110b360>] check_unmap+0x5ca/0x66b
  [<c110b462>] debug_dma_unmap_page+0x61/0x69
  [<c115d055>] natsemi_poll+0x33b/0x5b1
  [<c1179e10>] net_rx_action+0x3f/0xf4
  [<c1018fd5>] __do_softirq+0x81/0x146
  [<c1018f54>] ? __tasklet_schedule+0x37/0x37
  <IRQ>  [<c101922b>] ? irq_exit+0x31/0x3f
  [<c10027f5>] ? do_IRQ+0x5e/0x73
  [<c11d72a9>] ? common_interrupt+0x29/0x2e
  [<c1005b41>] ? default_idle+0x5/0x7
  [<c1005fba>] ? arch_cpu_idle+0x12/0x17
  [<c10315f1>] ? cpu_startup_entry+0x62/0xbd
  [<c11cffc7>] ? rest_init+0x57/0x59
  [<c129d88a>] ? start_kernel+0x268/0x26d
  [<c129d2af>] ? i386_start_kernel+0x79/0x7d
---[ end trace 6926f272918daaf2 ]---

addr2line -e vmlinux c1179e10
net/core/dev.c:4342
[work = n->poll(n, weight);]

addr2line -e vmlinux c115d055
drivers/net/ethernet/natsemi/natsemi.c:2361
[skb_put(skb = np->rx_skbuff[entry], pkt_len);]

Regards.
