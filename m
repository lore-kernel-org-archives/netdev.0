From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 42912] New: Kernel freeze. tcp_input.c:3418
 tcp_clean_rtx_queue
Date: Mon, 12 Mar 2012 09:27:31 -0700
Message-ID: <20120312092731.6ca4bf0c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50817 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177Ab2CLQ1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 12:27:35 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 2176A142000F
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 09:27:34 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4nmjgtNcsCd4 for <netdev@vger.kernel.org>;
	Mon, 12 Mar 2012 09:27:32 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 1B2E61410001
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 09:27:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 12 Mar 2012 16:21:57 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42912] New: Kernel freeze. tcp_input.c:3418 tcp_clean_rtx_queue


https://bugzilla.kernel.org/show_bug.cgi?id=42912

           Summary: Kernel freeze. tcp_input.c:3418 tcp_clean_rtx_queue
           Product: Networking
           Version: 2.5
    Kernel Version: 3.3 rc6
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: r@roze.lv
        Regression: No


After some operating time (within a day) server (opensuse 11.3) crashes with:

Mar  8 15:48:19 is52 kernel: [37589.085733] ------------[ cut here
]------------
Mar  8 15:48:19 is52 kernel: [37589.085748] WARNING: at
/home/abuild/rpmbuild/BUILD/kernel-default-3.3.rc6/linux-3.3-rc6/net/ipv4/tcp_input.c:3418
tcp_clean_rtx_queue+0x763/0x800()
Mar  8 15:48:19 is52 kernel: [37589.085770] Hardware name: ProLiant DL360 G5
Mar  8 15:48:19 is52 kernel: [37589.085778] Modules linked in: mperf edd loop
dm_mod sg i5000_edac edac_core coretemp i5k_amb ipmi_si ipmi_msghandler
serio_raw pcspkr mvsas bnx2 libsas iTCO_wdt iTCO_vendor_s
upport hpwdt shpchp scsi_transport_sas pci_hotplug hpilo usbhid button
microcode container xfs uhci_hcd radeon ehci_hcd ttm drm_kms_helper drm
i2c_algo_bit usbcore usb_common fan thermal processor thermal_sy
s hpsa ata_generic cciss
Mar  8 15:48:19 is52 kernel: [37589.085875] Pid: 0, comm: swapper/2 Tainted: G 
      W I  3.3.0-rc6-3-default #1
Mar  8 15:48:19 is52 kernel: [37589.085897] Call Trace:
Mar  8 15:48:19 is52 kernel: [37589.085907]  [<ffffffff8100445a>]
dump_trace+0x9a/0x260
Mar  8 15:48:19 is52 kernel: [37589.085912]  [<ffffffff81556f4f>]
dump_stack+0x69/0x6f
Mar  8 15:48:19 is52 kernel: [37589.085916]  [<ffffffff8103ddab>]
warn_slowpath_common+0x7b/0xc0
Mar  8 15:48:19 is52 kernel: [37589.085921]  [<ffffffff8149ada3>]
tcp_clean_rtx_queue+0x763/0x800
Mar  8 15:48:19 is52 kernel: [37589.085926]  [<ffffffff8149d944>]
tcp_ack+0x2e4/0x570
Mar  8 15:48:19 is52 kernel: [37589.085931]  [<ffffffff8149e9f9>]
tcp_rcv_established+0x1c9/0x7c0
Mar  8 15:48:19 is52 kernel: [37589.085935]  [<ffffffff814a6341>]
tcp_v4_do_rcv+0x111/0x1b0
Mar  8 15:48:19 is52 kernel: [37589.085939]  [<ffffffff814a7adf>]
tcp_v4_rcv+0x55f/0x810
Mar  8 15:48:19 is52 kernel: [37589.085944]  [<ffffffff814850cc>]
ip_local_deliver_finish+0xcc/0x270
Mar  8 15:48:19 is52 kernel: [37589.085950]  [<ffffffff81452623>]
__netif_receive_skb+0x493/0x510
Mar  8 15:48:19 is52 kernel: [37589.085956]  [<ffffffff8145305a>]
netif_receive_skb+0x1a/0x80
Mar  8 15:48:19 is52 kernel: [37589.085959]  [<ffffffff814531c8>]
napi_skb_finish+0x38/0x50
Mar  8 15:48:19 is52 kernel: [37589.085967]  [<ffffffffa038d6df>]
bnx2_rx_int+0x3df/0x7d0 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.085986]  [<ffffffffa038db36>]
bnx2_poll_work+0x66/0x90 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086003]  [<ffffffffa038dc84>]
bnx2_poll+0x54/0x1a0 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086018]  [<ffffffff814539b1>]
net_rx_action+0x121/0x260
Mar  8 15:48:19 is52 kernel: [37589.086023]  [<ffffffff8104500d>]
__do_softirq+0x9d/0x1f0
Mar  8 15:48:19 is52 kernel: [37589.086028]  [<ffffffff8157871c>]
call_softirq+0x1c/0x30
Mar  8 15:48:19 is52 kernel: [37589.086032]  [<ffffffff810042d5>]
do_softirq+0x65/0xa0
Mar  8 15:48:19 is52 kernel: [37589.086036]  [<ffffffff810453de>]
irq_exit+0x8e/0xb0
Mar  8 15:48:19 is52 kernel: [37589.086040]  [<ffffffff81003efc>]
do_IRQ+0x5c/0xd0
Mar  8 15:48:19 is52 kernel: [37589.086045]  [<ffffffff8156f5ee>]
common_interrupt+0x6e/0x6e
Mar  8 15:48:19 is52 kernel: [37589.086050]  [<ffffffff8100ad92>]
mwait_idle+0x92/0x210
Mar  8 15:48:19 is52 kernel: [37589.086054]  [<ffffffff810011a9>]
cpu_idle+0x89/0xd0
Mar  8 15:48:19 is52 kernel: [37589.086057] ---[ end trace 306e3d00e8ef1b59
]---
Mar  8 15:48:19 is52 kernel: [37589.086059] ------------[ cut here
]------------
Mar  8 15:48:19 is52 kernel: [37589.086062] WARNING: at
/home/abuild/rpmbuild/BUILD/kernel-default-3.3.rc6/linux-3.3-rc6/net/ipv4/tcp_input.c:3048
tcp_fastretrans_alert+0x802/0x860()
Mar  8 15:48:19 is52 kernel: [37589.086065] Hardware name: ProLiant DL360 G5
Mar  8 15:48:19 is52 kernel: [37589.086066] Modules linked in: mperf edd loop
dm_mod sg i5000_edac edac_core coretemp i5k_amb ipmi_si ipmi_msghandler
serio_raw pcspkr mvsas bnx2 libsas iTCO_wdt iTCO_vendor_s
upport hpwdt shpchp scsi_transport_sas pci_hotplug hpilo usbhid button
microcode container xfs uhci_hcd radeon ehci_hcd ttm drm_kms_helper drm
i2c_algo_bit usbcore usb_common fan thermal processor thermal_sy
s hpsa ata_generic cciss
Mar  8 15:48:19 is52 kernel: [37589.086084] Pid: 0, comm: swapper/2 Tainted: G 
      W I  3.3.0-rc6-3-default #1
Mar  8 15:48:19 is52 kernel: [37589.086085] Call Trace:
Mar  8 15:48:19 is52 kernel: [37589.086089]  [<ffffffff8100445a>]
dump_trace+0x9a/0x260
Mar  8 15:48:19 is52 kernel: [37589.086093]  [<ffffffff81556f4f>]
dump_stack+0x69/0x6f
Mar  8 15:48:19 is52 kernel: [37589.086097]  [<ffffffff8103ddab>]
warn_slowpath_common+0x7b/0xc0
Mar  8 15:48:19 is52 kernel: [37589.086101]  [<ffffffff8149d602>]
tcp_fastretrans_alert+0x802/0x860
Mar  8 15:48:19 is52 kernel: [37589.086118]  [<ffffffff8149da62>]
tcp_ack+0x402/0x570
Mar  8 15:48:19 is52 kernel: [37589.086123]  [<ffffffff8149e9f9>]
tcp_rcv_established+0x1c9/0x7c0
Mar  8 15:48:19 is52 kernel: [37589.086127]  [<ffffffff814a6341>]
tcp_v4_do_rcv+0x111/0x1b0
Mar  8 15:48:19 is52 kernel: [37589.086131]  [<ffffffff814a7adf>]
tcp_v4_rcv+0x55f/0x810
Mar  8 15:48:19 is52 kernel: [37589.086135]  [<ffffffff814850cc>]
ip_local_deliver_finish+0xcc/0x270
Mar  8 15:48:19 is52 kernel: [37589.086140]  [<ffffffff81452623>]
__netif_receive_skb+0x493/0x510
Mar  8 15:48:19 is52 kernel: [37589.086145]  [<ffffffff8145305a>]
netif_receive_skb+0x1a/0x80
Mar  8 15:48:19 is52 kernel: [37589.086149]  [<ffffffff814531c8>]
napi_skb_finish+0x38/0x50
Mar  8 15:48:19 is52 kernel: [37589.086155]  [<ffffffffa038d6df>]
bnx2_rx_int+0x3df/0x7d0 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086172]  [<ffffffffa038db36>]
bnx2_poll_work+0x66/0x90 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086189]  [<ffffffffa038dc84>]
bnx2_poll+0x54/0x1a0 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086204]  [<ffffffff814539b1>]
net_rx_action+0x121/0x260
Mar  8 15:48:19 is52 kernel: [37589.086209]  [<ffffffff8104500d>]
__do_softirq+0x9d/0x1f0
Mar  8 15:48:19 is52 kernel: [37589.086213]  [<ffffffff8157871c>]
call_softirq+0x1c/0x30
Mar  8 15:48:19 is52 kernel: [37589.086217]  [<ffffffff810042d5>]
do_softirq+0x65/0xa0
Mar  8 15:48:19 is52 kernel: [37589.086221]  [<ffffffff810453de>]
irq_exit+0x8e/0xb0
Mar  8 15:48:19 is52 kernel: [37589.086225]  [<ffffffff81003efc>]
do_IRQ+0x5c/0xd0
Mar  8 15:48:19 is52 kernel: [37589.086229]  [<ffffffff8156f5ee>]
common_interrupt+0x6e/0x6e
Mar  8 15:48:19 is52 kernel: [37589.086233]  [<ffffffff8100ad92>]
mwait_idle+0x92/0x210
Mar  8 15:48:19 is52 kernel: [37589.086237]  [<ffffffff810011a9>]
cpu_idle+0x89/0xd0
Mar  8 15:48:19 is52 kernel: [37589.086240] ---[ end trace 306e3d00e8ef1b5a
]---
Mar  8 15:48:19 is52 kernel: [37589.086241] ------------[ cut here
]------------
Mar  8 15:48:19 is52 kernel: [37589.086244] WARNING: at
/home/abuild/rpmbuild/BUILD/kernel-default-3.3.rc6/linux-3.3-rc6/net/ipv4/tcp_input.c:2885
tcp_try_to_open+0x19a/0x1b0()
Mar  8 15:48:19 is52 kernel: [37589.086247] Hardware name: ProLiant DL360 G5
Mar  8 15:48:19 is52 kernel: [37589.086248] Modules linked in: mperf edd loop
dm_mod sg i5000_edac edac_core coretemp i5k_amb ipmi_si ipmi_msghandler
serio_raw pcspkr mvsas bnx2 libsas iTCO_wdt iTCO_vendor_s
upport hpwdt shpchp scsi_transport_sas pci_hotplug hpilo usbhid button
microcode container xfs uhci_hcd radeon ehci_hcd ttm drm_kms_helper drm
i2c_algo_bit usbcore usb_common fan thermal processor thermal_sy
s hpsa ata_generic cciss
Mar  8 15:48:19 is52 kernel: [37589.086266] Pid: 0, comm: swapper/2 Tainted: G 
      W I  3.3.0-rc6-3-default #1
Mar  8 15:48:19 is52 kernel: [37589.086267] Call Trace:
Mar  8 15:48:19 is52 kernel: [37589.086271]  [<ffffffff8100445a>]
dump_trace+0x9a/0x260
Mar  8 15:48:19 is52 kernel: [37589.086275]  [<ffffffff81556f4f>]
dump_stack+0x69/0x6f
Mar  8 15:48:19 is52 kernel: [37589.086278]  [<ffffffff8103ddab>]
warn_slowpath_common+0x7b/0xc0
Mar  8 15:48:19 is52 kernel: [37589.086282]  [<ffffffff8149c7da>]
tcp_try_to_open+0x19a/0x1b0
Mar  8 15:48:19 is52 kernel: [37589.086287]  [<ffffffff8149da62>]
tcp_ack+0x402/0x570
Mar  8 15:48:19 is52 kernel: [37589.086292]  [<ffffffff8149e9f9>]
tcp_rcv_established+0x1c9/0x7c0
Mar  8 15:48:19 is52 kernel: [37589.086296]  [<ffffffff814a6341>]
tcp_v4_do_rcv+0x111/0x1b0
Mar  8 15:48:19 is52 kernel: [37589.086300]  [<ffffffff814a7adf>]
tcp_v4_rcv+0x55f/0x810
Mar  8 15:48:19 is52 kernel: [37589.086304]  [<ffffffff814850cc>]
ip_local_deliver_finish+0xcc/0x270
Mar  8 15:48:19 is52 kernel: [37589.086309]  [<ffffffff81452623>]
__netif_receive_skb+0x493/0x510
Mar  8 15:48:19 is52 kernel: [37589.086314]  [<ffffffff8145305a>]
netif_receive_skb+0x1a/0x80
Mar  8 15:48:19 is52 kernel: [37589.086317]  [<ffffffff814531c8>]
napi_skb_finish+0x38/0x50
Mar  8 15:48:19 is52 kernel: [37589.086323]  [<ffffffffa038d6df>]
bnx2_rx_int+0x3df/0x7d0 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086341]  [<ffffffffa038db36>]
bnx2_poll_work+0x66/0x90 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086357]  [<ffffffffa038dc84>]
bnx2_poll+0x54/0x1a0 [bnx2]
Mar  8 15:48:19 is52 kernel: [37589.086372]  [<ffffffff814539b1>]
net_rx_action+0x121/0x260
Mar  8 15:48:19 is52 kernel: [37589.086377]  [<ffffffff8104500d>]
__do_softirq+0x9d/0x1f0
Mar  8 15:48:19 is52 kernel: [37589.086381]  [<ffffffff8157871c>]
call_softirq+0x1c/0x30
Mar  8 15:48:19 is52 kernel: [37589.086385]  [<ffffffff810042d5>]
do_softirq+0x65/0xa0
Mar  8 15:48:19 is52 kernel: [37589.086389]  [<ffffffff810453de>]
irq_exit+0x8e/0xb0
Mar  8 15:48:19 is52 kernel: [37589.086393]  [<ffffffff81003efc>]
do_IRQ+0x5c/0xd0
Mar  8 15:48:19 is52 kernel: [37589.086397]  [<ffffffff8156f5ee>]
common_interrupt+0x6e/0x6e
Mar  8 15:48:19 is52 kernel: [37589.086401]  [<ffffffff8100ad92>]
mwait_idle+0x92/0x210
Mar  8 15:48:19 is52 kernel: [37589.086405]  [<ffffffff810011a9>]
cpu_idle+0x89/0xd0
Mar  8 15:48:19 is52 kernel: [37589.086408] ---[ end trace 306e3d00e8ef1b5b
]---
Mar  8 15:48:19 is52 kernel: [37589.092626] ------------[ cut here
]------------

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
