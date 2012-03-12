From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 42912] Kernel freeze. tcp_input.c:3418 tcp_clean_rtx_queue
Date: Mon, 12 Mar 2012 09:27:46 -0700
Message-ID: <20120312092746.26ffcfc2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50831 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab2CLQ1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 12:27:50 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id C8EC7142000F
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 09:27:48 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WK-+tFK7VRUi for <netdev@vger.kernel.org>;
	Mon, 12 Mar 2012 09:27:47 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 767671410001
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 09:27:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 12 Mar 2012 16:23:32 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42912] Kernel freeze. tcp_input.c:3418 tcp_clean_rtx_queue


https://bugzilla.kernel.org/show_bug.cgi?id=42912





--- Comment #1 from Reinis Rozitis <r@roze.lv>  2012-03-12 16:23:32 ---
3.2.0-rc2 is not affected.
but I can reproduce it also with the stable 3.2.9 kernel:

Mar  4 14:10:17 is50 kernel: [35293.175230] WARNING: at
/usr/src/packages/BUILD/kernel-default-3.2.9/linux-3.2/net/ipv4/tcp_input.c:3439
tcp_clean_rtx_queue+0x6a2/0x730()
Mar  4 14:10:17 is50 kernel: [35293.175233] Hardware name: ProLiant DL360 G5
Mar  4 14:10:17 is50 kernel: [35293.175235] Modules linked in: mperf edd loop
dm_mod sg i5000_edac edac_core iTCO_wdt bnx2 mvsas ipmi_si usbhid hpwdt i5k_amb
libsas scsi_transport_sas iTCO_vendor_support hpi
lo ipmi_msghandler pcspkr shpchp pci_hotplug button serio_raw container xfs
uhci_hcd radeon ehci_hcd ttm drm_kms_helper drm i2c_algo_bit usbcore usb_common
fan thermal processor thermal_sys hpsa ata_generic
cciss
Mar  4 14:10:17 is50 kernel: [35293.175267] Pid: 0, comm: swapper/1 Tainted: G 
      W I  3.2.9-1-default #1
Mar  4 14:10:17 is50 kernel: [35293.175269] Call Trace:
Mar  4 14:10:17 is50 kernel: [35293.175280]  [<ffffffff81004458>]
dump_trace+0x78/0x320
Mar  4 14:10:17 is50 kernel: [35293.175285]  [<ffffffff81568fd5>]
dump_stack+0x69/0x6f
Mar  4 14:10:17 is50 kernel: [35293.175290]  [<ffffffff81057a9b>]
warn_slowpath_common+0x7b/0xc0
Mar  4 14:10:17 is50 kernel: [35293.175295]  [<ffffffff814ac3a2>]
tcp_clean_rtx_queue+0x6a2/0x730
Mar  4 14:10:17 is50 kernel: [35293.175301]  [<ffffffff814af3ab>]
tcp_ack+0x21b/0x560
Mar  4 14:10:17 is50 kernel: [35293.175306]  [<ffffffff814b0793>]
tcp_rcv_established+0x4a3/0x750
Mar  4 14:10:17 is50 kernel: [35293.175311]  [<ffffffff814b7e11>]
tcp_v4_do_rcv+0x111/0x1f0
Mar  4 14:10:17 is50 kernel: [35293.175316]  [<ffffffff814b9be9>]
tcp_v4_rcv+0x639/0x900
Mar  4 14:10:17 is50 kernel: [35293.175321]  [<ffffffff81496b24>]
ip_local_deliver_finish+0xd4/0x290
Mar  4 14:10:17 is50 kernel: [35293.175327]  [<ffffffff81462d56>]
__netif_receive_skb+0x4c6/0x530
Mar  4 14:10:17 is50 kernel: [35293.175333]  [<ffffffff814635c8>]
netif_receive_skb+0x58/0x80
Mar  4 14:10:17 is50 kernel: [35293.175337]  [<ffffffff81463708>]
napi_skb_finish+0x38/0x50
Mar  4 14:10:17 is50 kernel: [35293.175345]  [<ffffffffa03b1714>]
bnx2_rx_int+0x3d4/0x820 [bnx2]
Mar  4 14:10:17 is50 kernel: [35293.175365]  [<ffffffffa03b1bc6>]
bnx2_poll_work+0x66/0x90 [bnx2]
Mar  4 14:10:17 is50 kernel: [35293.175381]  [<ffffffffa03b1d14>]
bnx2_poll+0x54/0x1bc [bnx2]
Mar  4 14:10:17 is50 kernel: [35293.175397]  [<ffffffff81463f31>]
net_rx_action+0x121/0x240
Mar  4 14:10:17 is50 kernel: [35293.175403]  [<ffffffff8105ee01>]
__do_softirq+0xa1/0x1b0
Mar  4 14:10:17 is50 kernel: [35293.175408]  [<ffffffff81575fec>]
call_softirq+0x1c/0x30
Mar  4 14:10:17 is50 kernel: [35293.175412]  [<ffffffff810043a5>]
do_softirq+0x65/0xa0
Mar  4 14:10:17 is50 kernel: [35293.175417]  [<ffffffff8105f186>]
irq_exit+0x96/0xc0
Mar  4 14:10:17 is50 kernel: [35293.175421]  [<ffffffff81003fcc>]
do_IRQ+0x5c/0xd0
Mar  4 14:10:17 is50 kernel: [35293.175425]  [<ffffffff8156c06e>]
common_interrupt+0x6e/0x6e
Mar  4 14:10:17 is50 kernel: [35293.175431]  [<ffffffff8100adac>]
mwait_idle+0x8c/0x1c0
Mar  4 14:10:17 is50 kernel: [35293.175436]  [<ffffffff81001216>]
cpu_idle+0x86/0xc0
Mar  4 14:10:17 is50 kernel: [35293.175440] ---[ end trace e2ca8a69698d19ea
]---

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
