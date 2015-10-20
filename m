From: Andrew <nitr0@seti.kr.ua>
Subject: [Bug] Linux 4.1.9, NULL pointer dereference in
 pppoe_release+0x120/0x150
Date: Tue, 20 Oct 2015 14:00:16 +0300
Message-ID: <56261EC0.2080807@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.seti.kr.ua ([91.202.132.4]:57230 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbbJTLAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 07:00:20 -0400
Received: from [91.226.57.222] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1ZoUeO-0006eE-H8
	for netdev@vger.kernel.org; Tue, 20 Oct 2015 14:00:18 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

After BRAS software upgrading (PPPoE daemon + kernel from 3.2.x to 
4.1.x) I have different kernel bugs/crashes - some of them don't hurt 
system, other crashes - cause network subsystem lockup (commands like 
'ip a' just hungs; and sometimes even 'reboot -f' doesn't help).

It seems like there's a similar trouble: 
http://permalink.gmane.org/gmane.linux.ppp/4410

Here's one of such crashes:

[98199.605120] BUG: unable to handle kernel NULL pointer dereference at 
00000280
[98199.605219] IP: [<f9a03580>] pppoe_release+0x120/0x150 [pppoe]
[98199.605275] *pdpt = 00000000345c5001 *pde = 0000000000000000
[98199.605335] Oops: 0000 [#1] SMP
[98199.605381] Modules linked in: act_mirred pppoe pppox ppp_generic 
slhc iptable_filter xt_length xt_TCPMSS xt_tcpudp xt_mark xt_dscp 
iptable_mangle ip_tables x_tables ipv6 sch_sfq sch_htb cls_u32 
sch_ingress sch_prio sch_tbf cls_flow cls_fw act_police ifb 8021q mrp 
garp stp llc softdog parport_pc parport acpi_cpufreq processor 
thermal_sys i2c_piix4 i2c_core igb(O) sp5100_tco k10temp hwmon ohci_pci 
ohci_hcd dca ptp pps_core sd_mod pata_acpi pcspkr pata_atiixp ahci 
libahci ata_generic libata ehci_pci ehci_hcd usbcore scsi_mod usb_common 
ext4 mbcache jbd2 crc16 vfat fat isofs
[98199.605858] CPU: 2 PID: 5691 Comm: accel-pppd Tainted: G           
O    4.1.9-i686 #1
[98199.605942] Hardware name: MICRO-STAR INTERNATIONAL CO.,LTD 
MS-7596/760GM-E51(MS-7596), BIOS V3.3 01/12/2012
[98199.606027] task: f47b0000 ti: dedfc000 task.ti: dedfc000
[98199.606073] EIP: 0060:[<f9a03580>] EFLAGS: 00210246 CPU: 2
[98199.606120] EIP is at pppoe_release+0x120/0x150 [pppoe]
[98199.606165] EAX: 00000000 EBX: d506c400 ECX: 00000000 EDX: fffffe01
[98199.606210] ESI: f228d800 EDI: f228d81c EBP: dedfdf48 ESP: dedfdf2c
[98199.606256]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[98199.606301] CR0: 8005003b CR2: 00000280 CR3: 32e38760 CR4: 000006f0
[98199.606344] Stack:
[98199.606385]  e0fcdc08 f5aa09a0 00000008 f228d81c f228d800 f9a03cc0 
f228d81c dedfdf60
[98199.606480]  c12f4f70 f52e2190 00000000 e0fcdc00 00000008 dedfdf68 
c12f4ff0 dedfdf94
[98199.606574]  c1139dc4 00000001 00000000 00000000 e0fcdc08 f231dc80 
f52e2190 f47b03c0
[98199.606668] Call Trace:
[98199.606717]  [<c12f4f70>] ? sock_release+0x20/0x90
[98199.606763]  [<c12f4ff0>] ? sock_close+0x10/0x20
[98199.606810]  [<c1139dc4>] ? __fput+0x84/0x1b0
[98199.606857]  [<c1063c71>] ? task_work_run+0x91/0xd0
[98199.606903]  [<c13bad15>] ? work_notifysig+0x16/0x1d
[98199.606946] Code: 5e 5f 5d c3 8d b4 26 00 00 00 00 89 d8 e8 29 64 8f 
c7 31 c0 83 c4 10 5b 5e 5f 5d c3 8d b4 26 00 00 00 00 8b 83 f8 01 00 00 
31 c9 <8b> 80 80 02 00 00 64 ff 08 89 8b f8 01 00 00 e9 0a ff ff ff 89
[98199.607180] EIP: [<f9a03580>] pppoe_release+0x120/0x150 [pppoe] 
SS:ESP 0068:dedfdf2c
[98199.607267] CR2: 0000000000000280
[98199.607701] ---[ end trace 61a91a29876c16b9 ]---
[98232.612193] BUG: unable to handle kernel NULL pointer dereference at 
00000280
[98232.612343] IP: [<f9a03580>] pppoe_release+0x120/0x150 [pppoe]
[98232.612455] *pdpt = 00000000345c5001 *pde = 0000000000000000
[98232.612591] Oops: 0000 [#2] SMP
[98232.612722] Modules linked in: act_mirred pppoe pppox ppp_generic 
slhc iptable_filter xt_length xt_TCPMSS xt_tcpudp xt_mark xt_dscp 
iptable_mangle ip_tables x_tables ipv6 sch_sfq sch_htb cls_u32 
sch_ingress sch_prio sch_tbf cls_flow cls_fw act_police ifb 8021q mrp 
garp stp llc softdog parport_pc parport acpi_cpufreq processor 
thermal_sys i2c_piix4 i2c_core igb(O) sp5100_tco k10temp hwmon ohci_pci 
ohci_hcd dca ptp pps_core sd_mod pata_acpi pcspkr pata_atiixp ahci 
libahci ata_generic libata ehci_pci ehci_hcd usbcore scsi_mod usb_common 
ext4 mbcache jbd2 crc16 vfat fat isofs
[98232.615182] CPU: 1 PID: 2121 Comm: accel-pppd Tainted: G D    O    
4.1.9-i686 #1
[98232.615294] Hardware name: MICRO-STAR INTERNATIONAL CO.,LTD 
MS-7596/760GM-E51(MS-7596), BIOS V3.3 01/12/2012
[98232.615407] task: f4966d80 ti: de2d2000 task.ti: de2d2000
[98232.615483] EIP: 0060:[<f9a03580>] EFLAGS: 00210246 CPU: 1
[98232.615560] EIP is at pppoe_release+0x120/0x150 [pppoe]
[98232.615634] EAX: 00000000 EBX: d48bf000 ECX: 00000000 EDX: fffffe01
[98232.615708] ESI: f226ca80 EDI: f226ca9c EBP: de2d3f48 ESP: de2d3f2c
[98232.615793]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[98232.615867] CR0: 8005003b CR2: 00000280 CR3: 32e38760 CR4: 000006f0
[98232.615940] Stack:
[98232.616008]  f40e6c08 f5d02cc0 00000008 f226ca9c f226ca80 f9a03cc0 
f226ca9c de2d3f60
[98232.616363]  c12f4f70 f52e2190 00000000 f40e6c00 00000008 de2d3f68 
c12f4ff0 de2d3f94
[98232.616716]  c1139dc4 00000001 00000000 00000000 f40e6c08 f22c9580 
f52e2190 f4967140
[98232.617069] Call Trace:
[98232.617147]  [<c12f4f70>] ? sock_release+0x20/0x90
[98232.617221]  [<c12f4ff0>] ? sock_close+0x10/0x20
[98232.617296]  [<c1139dc4>] ? __fput+0x84/0x1b0
[98232.617373]  [<c1063c71>] ? task_work_run+0x91/0xd0
[98232.617449]  [<c13bad15>] ? work_notifysig+0x16/0x1d
[98232.617533] Code: 5e 5f 5d c3 8d b4 26 00 00 00 00 89 d8 e8 29 64 8f 
c7 31 c0 83 c4 10 5b 5e 5f 5d c3 8d b4 26 00 00 00 00 8b 83 f8 01 00 00 
31 c9 <8b> 80 80 02 00 00 64 ff 08 89 8b f8 01 00 00 e9 0a ff ff ff 89
[98232.619662] EIP: [<f9a03580>] pppoe_release+0x120/0x150 [pppoe] 
SS:ESP 0068:de2d3f2c
[98232.619838] CR2: 0000000000000280
[98232.620409] ---[ end trace 61a91a29876c16ba ]---

Here's bug place:
(gdb) list *pppoe_release+0x120
0x1580 is in pppoe_release 
(/var/testpoint/LEAF-new/source/i486-unknown-linux-uclibc/linux/linux-4.1/drivers/net/ppp/pppoe.c:594).
589        }
590
591        po = pppox_sk(sk);
592
593        if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | 
PPPOX_ZOMBIE)) {
594            dev_put(po->pppoe_dev);
595            po->pppoe_dev = NULL;
596        }
597
598        pppox_unbind_sock(sk);
