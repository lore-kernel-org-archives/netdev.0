From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Null pointer dereference when bringing up bonding device on kernel-2.6.24-2.fc9.i686
Date: Mon, 28 Jan 2008 21:01:41 +0100
Message-ID: <m3bq75en2y.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55586 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753759AbYA1UB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 15:01:59 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JJaAz-000617-3K
	for netdev@vger.kernel.org; Mon, 28 Jan 2008 20:01:53 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 20:01:53 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 20:01:53 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://bugzilla.redhat.com/show_bug.cgi?id=430391

Bringing up interface bond0:
BUG: unable to handle kernel NULL
pointer dereference at virtual address 00000000
printing eip: c0506fd8 *pde = 7f5f8067 
Oops: 0000 [#1] SMP 
Modules linked in: bonding ipv6 xt_pkttype ipt_LOG ipt_iprange
ipt_REJECT xt_tcpudp nf_conntrack_ipv4 xt_state nf_conntrack_tftp
nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables
dm_mirror dm_mod rtc_cmos iTCO_wdt pcspkr iTCO_vendor_support e1000
i2c_i801 i2c_core button tg3 e752x_edac edac_core sr_mod sg cdrom
ata_generic ata_piix pata_acpi libata sd_mod scsi_mod raid456
async_xor async_memcpy async_tx xor raid1 ext3 jbd mbcache uhci_hcd
ohci_hcd ehci_hcd

Pid: 1620, comm: modprobe Not tainted (2.6.24-2.fc9 #1)
EIP: 0060:[<c0506fd8>] EFLAGS: 00210202 CPU: 3
EIP is at strnicmp+0x25/0x7c
EAX: f6d64062 EBX: 00000000 ECX: 00000010 EDX: 00000000
ESI: 00000010 EDI: 00000000 EBP: f6f2ae64 ESP: f6f2ae50
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process modprobe (pid: 1620, ti=f6f2a000 task=f6fc8000
task.ti=f6f2a000)
Stack: 00000000 f6d64000 f8cf7a14 00000000 f780f630 f6f2ae88 f8ce6fb6 00000000 
       f8cf09b4 00000000 f8cf8f80 00000000 00000001 f780f630 f6f2aeb0 f89a0778 
       f8cf1568 00000064 f6f40540 f8cf7e00 f6f2aeb0 f6f40568 f8cf7e00 f8cf7e00 
Call Trace:
 [<c04064b6>] show_trace_log_lvl+0x1a/0x2f
 [<c0406566>] show_stack_log_lvl+0x9b/0xa3
 [<c0406615>] show_registers+0xa7/0x178
 [<c040681b>] die+0x135/0x220
 [<c0640bd3>] do_page_fault+0x553/0x631
 [<c063f25a>] error_code+0x72/0x78
 [<f8ce6fb6>] bond_create+0x40/0x2da [bonding]
 [<f89a0778>] bonding_init+0x778/0x802 [bonding]
 [<c045482d>] sys_init_module+0x1430/0x155c
 [<c040526e>] syscall_call+0x7/0xb
 =======================
Code: 89 d0 5e 5f 5d c3 55 89 e5 57 31 ff 56 89 ce 53 31 db 83 ec 08
85 c9 89 45 f0 89 55 ec eb 50 31 ff eb 4e 8b 55 f0 8a 02 8b 55 ec <8a>
1a 42 ff 45 f0 84 c0 89 55 ec 74 e7 84 db 89 c7 74 33 38 d8 
EIP: [<c0506fd8>] strnicmp+0x25/0x7c SS:ESP 0068:f6f2ae50
---[ end trace b1f7597239228b36 ]---
./network-functions: line 216:  1620 Segmentation fault      modprobe
$1 > /dev/null 2>&1


Sorry if bugs in distribution kernels are less interesting.


/Benny


