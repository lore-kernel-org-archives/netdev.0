From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Thu, 13 Nov 2008 09:50:22 +0100
Message-ID: <1226566222.6834.76.camel@localhost.localdomain>
References: <20081112.014923.68124784.davem@davemloft.net>
	 <1226487710.6834.53.camel@localhost.localdomain>
	 <20081112.035240.226243372.davem@davemloft.net>
	 <20081112.041143.11487260.davem@davemloft.net>
	 <1226494179.6834.64.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:44934 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbYKMIuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 03:50:40 -0500
In-Reply-To: <1226494179.6834.64.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Another bug... while unloading the niu module.

During my testing I'm unloading/loading the niu module, I usually take
down the interfaces _before_ unloading the module, but I forgot one
time, and got the following BUG in the kern log.


niu: niu_put_parent: port[3]
niu 0000:0b:00.3: PCI INT D disabled
niu: niu_put_parent: port[2]
niu 0000:0b:00.2: PCI INT C disabled
niu: niu_put_parent: port[1]
niu 0000:0b:00.1: PCI INT B disabled
------------[ cut here ]------------
kernel BUG at drivers/pci/msi.c:630!
invalid opcode: 0000 [#1] PREEMPT SMP 
last sysfs file: /sys/class/net/lo/operstate
Modules linked in: hpilo serio_raw bnx2 zlib_inflate ipmi_si
ipmi_msghandler hpwdt rng_core ehci_hcd uhci_hcd niu(-) sr_mod cdrom

Pid: 3307, comm: rmmod Tainted: G        W  (2.6.28-rc4-davem #17)
ProLiant DL380 G5
EIP: 0060:[<c02314fc>] EFLAGS: 00010282 CPU: 0
EIP is at msi_free_irqs+0xdc/0xe0
EAX: f60ad420 EBX: 00000030 ECX: f664ff14 EDX: c04a5680
ESI: f71d1000 EDI: f71d146c EBP: f6305eb4 ESP: f6305ea8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process rmmod (pid: 3307, ti=f6304000 task=f6aaa570 task.ti=f6304000)
Stack:
 f71d1000 f62b4540 f71d1000 f6305ebc c0231508 f6305ec8 c0231791 f62b4000
 f6305edc f81777f8 f71d1000 f817c5d4 f817c5d4 f6305ee8 c022c3e9 f71d1058
 f6305ef8 c0281609 f71d1058 f71d1184 f6305f0c c02816dd f817c5a0 f817c5d4
Call Trace:
 [<c0231508>] ? msix_free_all_irqs+0x8/0x10
 [<c0231791>] ? pci_disable_msix+0x31/0x40
 [<f81777f8>] ? niu_pci_remove_one+0x88/0x8a [niu]
 [<c022c3e9>] ? pci_device_remove+0x19/0x40
 [<c0281609>] ? __device_release_driver+0x59/0x90
 [<c02816dd>] ? driver_detach+0x9d/0xb0
 [<c0280975>] ? bus_remove_driver+0x75/0xa0
 [<c0281b89>] ? driver_unregister+0x39/0x40
 [<c022c641>] ? pci_unregister_driver+0x21/0x80
 [<f817443d>] ? niu_exit+0xd/0x10 [niu]
 [<c014d646>] ? sys_delete_module+0x116/0x1f0
 [<c01744e0>] ? do_munmap+0x1f0/0x250
 [<c01755f6>] ? sys_munmap+0x46/0x60
 [<c0103231>] ? sysenter_do_call+0x12/0x2c
Code: b7 43 08 8b 53 1c c1 e0 04 01 d0 ba 01 00 00 00 83 c0 0c 89 10 3b
7b 14 75 aa 8b 43 1c e8 bd 6f ee ff eb a0 5b 31 c0 5e 5f 5d c3 <0f> 0b
eb fe 55 89 e5 e8 18 ff ff ff 5d c3 8d b6 00 00 00 00 55 
EIP: [<c02314fc>] msi_free_irqs+0xdc/0xe0 SS:ESP 0068:f6305ea8
---[ end trace 6594bbb8d1cf29ee ]---


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
