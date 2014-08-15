From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 82471] New: net/core/dev.c skb_war_bad_offload
Date: Fri, 15 Aug 2014 14:26:46 -0700
Message-ID: <20140815142646.4be3d091@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:39395 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbaHOV0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 17:26:49 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so4141416pad.11
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 14:26:49 -0700 (PDT)
Received: from haswell.linuxnetplumber.net (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id dd5sm8846378pbc.85.2014.08.15.14.26.48
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 14:26:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 15 Aug 2014 13:21:00 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 82471] New: net/core/dev.c skb_war_bad_offload


https://bugzilla.kernel.org/show_bug.cgi?id=82471

            Bug ID: 82471
           Summary: net/core/dev.c skb_war_bad_offload
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16.1
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: vladi@aresgate.net
        Regression: No

Created attachment 146761
  --> https://bugzilla.kernel.org/attachment.cgi?id=146761&action=edit
kernel config

Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973225] ------------[
cut here ]------------
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973236] WARNING: CPU:
2 PID: 0 at net/core/dev.c:2246 skb_warn_bad_offload+0xc8/0xd5()
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973238] :
caps=(0x000000000419fba9, 0x00000000001b583b) len=2962 data_len=2896
gso_size=1448 gso_type=1 ip_summed=3
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973239] Modules
linked in: ntfs msdos xfs libcrc32c ipmi_devintf intel_rapl
x86_pkg_temp_thermal intel_powerclamp coretemp crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper
cryptd sb_edac edac_core 8021q garp ioatdma stp ipmi_si mrp llc bonding
hid_generic ixgbe usbhid hid ahci dca libahci mdio
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973257] CPU: 2 PID: 0
Comm: swapper/2 Tainted: G        W     3.16.0 #2
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973259] Hardware
name: Supermicro X9DRD-7LN4F(-JBOD)/X9DRD-EF/X9DRD-7LN4F, BIOS 3.0a 12/05/2013
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973260]
0000000000000009 ffff88046fd036b0 ffffffff815c4096 ffff88046fd036f8
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973262]
ffff88046fd036e8 ffffffff8103f633 ffff880018b7c4e0 ffff8804687df000
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973264]
0000000000000001 0000000000000003 ffffffffa0193320 ffff88046fd03748
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973266] Call Trace:
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973268]  <IRQ>
[<ffffffff815c4096>] dump_stack+0x45/0x56
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973280]
[<ffffffff8103f633>] warn_slowpath_common+0x73/0x90
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973286]
[<ffffffff8103f697>] warn_slowpath_fmt+0x47/0x50
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973288]
[<ffffffff812edadc>] ? ___ratelimit+0x7c/0xf0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973291]
[<ffffffff815c5e19>] skb_warn_bad_offload+0xc8/0xd5
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973294]
[<ffffffff814e57fe>] skb_checksum_help+0x16e/0x180
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973297]
[<ffffffff814e9ecc>] dev_hard_start_xmit+0x42c/0x4b0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973299]
[<ffffffff814ea154>] ? __dev_queue_xmit+0x204/0x440
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973301]
[<ffffffff814ea232>] __dev_queue_xmit+0x2e2/0x440
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973302]
[<ffffffff814ea39b>] ? dev_queue_xmit+0xb/0x10
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973304]
[<ffffffff814ea39b>] dev_queue_xmit+0xb/0x10
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973308]
[<ffffffffa012b758>] vlan_dev_hard_start_xmit+0x88/0x100 [8021q]
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973317]
[<ffffffff814e9d9a>] dev_hard_start_xmit+0x2fa/0x4b0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973321]
[<ffffffff814ea232>] __dev_queue_xmit+0x2e2/0x440
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973323]
[<ffffffff814ea39b>] dev_queue_xmit+0xb/0x10
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973325]
[<ffffffff814f1192>] neigh_connected_output+0xb2/0xf0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973327]
[<ffffffff815192dc>] ip_finish_output+0x4ec/0x890
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973329]
[<ffffffff8151ac03>] ip_output+0x53/0x90
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973331]
[<ffffffff8151a39b>] ip_local_out_sk+0x2b/0x30
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973333]
[<ffffffff8151a6fa>] ip_queue_xmit+0x13a/0x3c0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973335]
[<ffffffff815309fa>] tcp_transmit_skb+0x42a/0x8f0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973337]
[<ffffffff81530ffa>] tcp_write_xmit+0x13a/0xc00
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973347]
[<ffffffff8152f033>] ? tcp_established_options+0x33/0xd0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973350]
[<ffffffff81531d09>] __tcp_push_pending_frames+0x29/0xc0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973353]
[<ffffffff8152da77>] tcp_rcv_established+0x1f7/0x5e0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973356]
[<ffffffff81535fc5>] tcp_v4_do_rcv+0x215/0x4a0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973369]
[<ffffffff810651f8>] ? ttwu_do_activate.constprop.64+0x58/0x60
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973374]
[<ffffffff81295d31>] ? security_sock_rcv_skb+0x11/0x20
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973377]
[<ffffffff815392ad>] tcp_v4_rcv+0x73d/0x7c0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973380]
[<ffffffff8106fafc>] ? update_group_capacity+0x16c/0x270
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973386]
[<ffffffff812e8300>] ? cpumask_next_and+0x30/0x50
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973388]
[<ffffffff81514b50>] ip_local_deliver_finish+0x80/0x1c0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973390]
[<ffffffff81515154>] ip_local_deliver+0x34/0x90
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973392]
[<ffffffff81514d99>] ip_rcv_finish+0x109/0x350
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973399]
[<ffffffff815153d2>] ip_rcv+0x222/0x370
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973403]
[<ffffffff814e5eb6>] __netif_receive_skb_core+0x416/0x570
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973407]
[<ffffffff814e73f3>] __netif_receive_skb+0x13/0x60
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973410]
[<ffffffff814e745e>] netif_receive_skb_internal+0x1e/0x90
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973415]
[<ffffffff814e7b40>] napi_gro_receive+0x70/0xa0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973422]
[<ffffffffa0134f4c>] ixgbe_clean_rx_irq+0x75c/0xb20 [ixgbe]
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973427]
[<ffffffffa0136172>] ixgbe_poll+0x522/0x850 [ixgbe]
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973430]
[<ffffffff8105e986>] ? hrtimer_get_next_event+0xb6/0xc0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973437]
[<ffffffff814e8dc1>] net_rx_action+0x101/0x1a0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973443]
[<ffffffff810430ab>] __do_softirq+0xdb/0x240
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973447]
[<ffffffff8104349e>] irq_exit+0xee/0x110
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973450]
[<ffffffff81004913>] do_IRQ+0x53/0xf0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973453]
[<ffffffff815caaaa>] common_interrupt+0x6a/0x6a
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973454]  <EOI>
[<ffffffff814af007>] ? cpuidle_enter_state+0x47/0xc0
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973463]
[<ffffffff814af132>] cpuidle_enter+0x12/0x20
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973468]
[<ffffffff81075fbf>] cpu_startup_entry+0x24f/0x280
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973477]
[<ffffffff810905e3>] ? clockevents_config_and_register+0x23/0x30
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973482]
[<ffffffff810282be>] start_secondary+0x1be/0x270
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.973486] ---[ end
trace de552357488766e8 ]---
Aug  6 06:46:50 prod-ent-ceph03.dc2.ec.loc kernel: [29530.974181] ------------[
cut here ]------------

--
You are receiving this mail because:
You are the assignee for the bug.
