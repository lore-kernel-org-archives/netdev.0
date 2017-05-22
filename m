From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195835] New: regression: tcp_fastretrans_alert
Date: Sun, 21 May 2017 21:14:05 -0700
Message-ID: <20170521211405.426088fa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34420 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751030AbdEVEON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 00:14:13 -0400
Received: by mail-pf0-f180.google.com with SMTP id 9so69342776pfj.1
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 21:14:13 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id q82sm29129193pfl.28.2017.05.21.21.14.11
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 May 2017 21:14:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 21 May 2017 08:53:17 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195835] New: regression: tcp_fastretrans_alert


https://bugzilla.kernel.org/show_bug.cgi?id=195835

            Bug ID: 195835
           Summary: regression: tcp_fastretrans_alert
           Product: Networking
           Version: 2.5
    Kernel Version: 4.11.2
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: nanericwang@gmail.com
        Regression: No

The issue can be reproduced in 4.11 running netfilter and Transmission
BitTorrent. However 4.10.x has no such issue.

[May21 16:38] ------------[ cut here ]------------
[  +0.000044] WARNING: CPU: 3 PID: 0 at net/ipv4/tcp_input.c:2819
tcp_fastretrans_alert+0x7ff/0xa10
[  +0.000006] Modules linked in: xt_TPROXY iptable_mangle xt_owner xt_REDIRECT
nf_nat_redirect xt_set af_packet iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_set_hash_net i
[  +0.000100] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.11.2 #2
[  +0.000004] Hardware name: BIOSTAR Group A68N-5000/A68N-5000, BIOS 4.6.5
04/22/2014
[  +0.000002] Call Trace:
[  +0.000007]  <IRQ>
[  +0.000010]  ? dump_stack+0x46/0x5e
[  +0.000009]  ? __warn+0xb4/0xd0
[  +0.000006]  ? tcp_fastretrans_alert+0x7ff/0xa10
[  +0.000006]  ? tcp_ack+0xe95/0x1448
[  +0.000009]  ? __ip_flush_pending_frames.isra.51+0x70/0x70
[  +0.000007]  ? tcp_rcv_established+0x1ae/0x6b0
[  +0.000007]  ? tcp_v4_do_rcv+0x12b/0x1e8
[  +0.000006]  ? tcp_v4_rcv+0x7c4/0x880
[  +0.000011]  ? nf_nat_ipv4_fn+0x53/0x150 [nf_nat_ipv4]
[  +0.000007]  ? ip_local_deliver_finish+0x49/0x110
[  +0.000006]  ? ip_local_deliver+0x66/0xd8
[  +0.000006]  ? inet_del_offload+0x30/0x30
[  +0.000008]  ? ip_sabotage_in+0x26/0x30 [br_netfilter]
[  +0.000009]  ? nf_hook_slow+0x21/0xa0
[  +0.000005]  ? ip_rcv+0x2e8/0x370
[  +0.000006]  ? ip_local_deliver_finish+0x110/0x110
[  +0.000008]  ? __netif_receive_skb_core+0x363/0x700
[  +0.000007]  ? netif_receive_skb_internal+0x2a/0x98
[  +0.000014]  ? br_pass_frame_up+0x60/0xd8 [bridge]
[  +0.000012]  ? br_handle_frame_finish+0x132/0x330 [bridge]
[  +0.000015]  ? nf_ct_get_tuple+0x56/0x90 [nf_conntrack]
[  +0.000011]  ? br_pass_frame_up+0xd8/0xd8 [bridge]
[  +0.000007]  ? br_nf_hook_thresh+0xa7/0xb8 [br_netfilter]
[  +0.000009]  ? ipt_do_table+0x2b5/0x3e0 [ip_tables]
[  +0.000007]  ? br_nf_pre_routing_finish+0x173/0x2f8 [br_netfilter]
[  +0.000010]  ? br_pass_frame_up+0xd8/0xd8 [bridge]
[  +0.000007]  ? nf_nat_ipv4_in+0x23/0x70 [nf_nat_ipv4]
[  +0.000007]  ? br_nf_pre_routing+0x2c4/0x420 [br_netfilter]
[  +0.000007]  ? br_nf_forward_arp+0x250/0x250 [br_netfilter]
[  +0.000007]  ? nf_hook_slow+0x21/0xa0
[  +0.000010]  ? br_handle_frame+0x1ae/0x2c8 [bridge]
[  +0.000010]  ? br_pass_frame_up+0xd8/0xd8 [bridge]
[  +0.000010]  ? br_handle_local_finish+0x38/0x38 [bridge]
[  +0.000006]  ? __netif_receive_skb_core+0x1d7/0x700
[  +0.000006]  ? netif_receive_skb_internal+0x2a/0x98
[  +0.000006]  ? napi_gro_receive+0x6a/0xb0
[  +0.000012]  ? rtl8169_poll+0x2c9/0x690 [r8169]
[  +0.000007]  ? net_rx_action+0x1c6/0x2b8
[  +0.000007]  ? __do_softirq+0xd8/0x200
[  +0.000005]  ? irq_exit+0xa3/0xa8
[  +0.000007]  ? do_IRQ+0x45/0xc0
[  +0.000009]  ? common_interrupt+0x7f/0x7f
[  +0.000003]  </IRQ>
[  +0.000013]  ? acpi_idle_do_entry+0x2b/0xed0 [processor]
[  +0.000007]  ? acpi_idle_enter+0xe1/0x288 [processor]
[  +0.000009]  ? cpuidle_enter_state+0x128/0x1f0
[  +0.000008]  ? do_idle+0x17a/0x1d8
[  +0.000006]  ? cpu_startup_entry+0x68/0x70
[  +0.000009]  ? start_secondary+0x138/0x158
[  +0.000005]  ? start_cpu+0x14/0x14
[  +0.000008] ---[ end trace ab2d840ff39c9793 ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
