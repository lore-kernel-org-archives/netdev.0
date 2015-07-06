From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 100971] New: Crash in networking subsystem on removing PPP
 interface
Date: Mon, 6 Jul 2015 09:10:48 -0700
Message-ID: <20150706091048.58f8d436@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35307 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbbGFQKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 12:10:39 -0400
Received: by pdbci14 with SMTP id ci14so108372738pdb.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 09:10:39 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id pb6sm18725241pbc.75.2015.07.06.09.10.38
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 09:10:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 5 Jul 2015 14:35:59 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 100971] New: Crash in networking subsystem on removing PPP interface


https://bugzilla.kernel.org/show_bug.cgi?id=100971

            Bug ID: 100971
           Summary: Crash in networking subsystem on removing PPP
                    interface
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14.44
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: nitr0@seti.kr.ua
        Regression: No

Created attachment 181891
  --> https://bugzilla.kernel.org/attachment.cgi?id=181891&action=edit
kernel config

I have some PPPoE BRAS servers witn linux-3.14 kernel, and noticed random
crashes (BRAS uptime from some days to some weeks). BRAS remains accessible by
ssh, but any shell command that interacts with network subsystem (for ex.,
obtaining list of interfaces, or removing shaper rules) will hang till it
killed from other ssh session.

I have crashes on 2 BRAS, with 3.14.42 and 3.14.44 kernels, with igb-5.2.5 and
igb 5.2.18. There's HTB shaper on PPP ingress, and IFB egress redirect.

Almost same BRAS with same shaper works pretty stable on 3.2.28 (uptime is ~2
years).

I'll try to rollback to 3.10 kernel - possibly bug isn't present on it.

Here's bug message:

[639661.740225] BUG: unable to handle kernel paging request at 05040214
[639661.740235] IP: [<c115c121>] unregister_sysctl_table+0x11/0x70
[639661.740243] *pdpt = 00000000350e0001 *pde = 0000000000000000 
[639661.740248] Oops: 0000 [#1] SMP 
[639661.740251] Modules linked in: act_mirred pppoe pppox ppp_generic slhc
iptable_filter xt_length xt_TCPMSS xt_tcpudp xt_mark xt_dscp iptable_mangle
ip_tables x_tables ipv6 sch_sfq sch_htb cls_u32 sch_ingress sch_prio sch_tbf
cls_flow cls_fw act_police ifb 8021q mrp garp stp llc softdog acpi_cpufreq
processor thermal fan thermal_sys asus_atk0110 parport_pc parport igb(O)
k10temp hwmon dca ptp pps_core i2c_nforce2 i2c_core ohci_pci ohci_hcd nv_tco
sd_mod crc_t10dif crct10dif_common pata_acpi pcspkr pata_amd sata_nv ehci_pci
ehci_hcd ata_generic libata usbcore scsi_mod usb_common ext4 mbcache jbd2 crc16
vfat fat isofs
[639661.740318] CPU: 1 PID: 10673 Comm: accel-pppd Tainted: G           O
3.14.44-i686 #1
[639661.740322] Hardware name: System manufacturer System Product Name/M2N-SLI
DELUXE, BIOS ASUS M2N-SLI DELUXE ACPI BIOS Revision 5001 02/04/2010
[639661.740327] task: f53238e0 ti: e1f86000 task.ti: e1f86000
[639661.740331] EIP: 0060:[<c115c121>] EFLAGS: 00210206 CPU: 1
[639661.740334] EIP is at unregister_sysctl_table+0x11/0x70
[639661.740337] EAX: 05040200 EBX: 05040200 ECX: 8010000a EDX: 8010000b
[639661.740340] ESI: e0faf80c EDI: e0faf800 EBP: e1f87e58 ESP: e1f87e4c
[639661.740343]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[639661.740346] CR0: 8005003b CR2: 05040214 CR3: 3469f000 CR4: 000007f0
[639661.740349] Stack:
[639661.740351]  d3fc8c00 e0faf80c e0faf800 e1f87e64 c12ab02e d3ef0800 e1f87eac
c12fff3b
[639661.740357]  c10818b0 e1f87ea8 c1099fe0 e1f87e80 00000000 00000000 00000001
00000000
[639661.740363]  d3ef0800 c12ba78d e1f87e94 e1f87e94 00000000 c1494c98 c1494ee4
00000000
[639661.740369] Call Trace:
[639661.740375]  [<c12ab02e>] ? neigh_sysctl_unregister+0x1e/0x30
[639661.740380]  [<c12fff3b>] ? inetdev_event+0x17b/0x490
[639661.740386]  [<c10818b0>] ? dyntick_save_progress_counter+0x20/0x20
[639661.740390]  [<c1099fe0>] ? __stop_cpus+0x40/0x60
[639661.740395]  [<c12ba78d>] ? fib_rules_event+0x1d/0x190
[639661.740399]  [<c105fb61>] ? notifier_call_chain+0x41/0x60
[639661.740403]  [<c105fc9f>] ? raw_notifier_call_chain+0x1f/0x30
[639661.740408]  [<c12a11ae>] ? rollback_registered_many+0x12e/0x240
[639661.740412]  [<c12a12e4>] ? rollback_registered+0x24/0x40
[639661.740415]  [<c12a2a4f>] ? unregister_netdevice_queue+0x4f/0xb0
[639661.740419]  [<c12a2ac9>] ? unregister_netdev+0x19/0x20
[639661.740424]  [<f8e3a5ab>] ? ppp_shutdown_interface+0xdb/0xf0 [ppp_generic]
[639661.740428]  [<f8e3bf04>] ? ppp_release+0x54/0x70 [ppp_generic]
[639661.740433]  [<c110c7a7>] ? __fput+0x87/0x1e0
[639661.740437]  [<c10593e9>] ? task_work_run+0x79/0xb0
[639661.740442]  [<c133e5c5>] ? work_notifysig+0x16/0x1d
[639661.740444] Code: 96 04 1e 00 b8 ec 97 57 c1 e8 ec 1f 1e 00 eb a6 8d 76 00
8d bc 27 00 00 00 00 55 89 e5 57 56 53 3e 8d 74 26 00 85 c0 89 c3 74 25 <8b> 40
14 e8 47 f8 ff ff 83 f8 01 7f 1d b8 ec 97 57 c1 e8 b8 1f
[639661.740469] EIP: [<c115c121>] unregister_sysctl_table+0x11/0x70 SS:ESP
0068:e1f87e4c
[639661.740474] CR2: 0000000005040214
[639661.740530] ---[ end trace 6c00a3dbe41f0937 ]---

What additional info is needed?

Kernel config is attched. Also I can send unstripped vmlinux or modules is this
helps in some way.

-- 
You are receiving this mail because:
You are the assignee for the bug.
