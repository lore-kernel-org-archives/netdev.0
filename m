From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 75571] New: using tc action mirred results BUG at
 net/core/skbuff.c:119
Date: Tue, 6 May 2014 08:16:28 -0700
Message-ID: <20140506081628.1626ff94@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:52779 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbaEFPQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:16:33 -0400
Received: by mail-pd0-f174.google.com with SMTP id w10so8451343pde.33
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 08:16:32 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id su8sm954743pbc.72.2014.05.06.08.16.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:16:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 5 May 2014 23:48:49 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 75571] New: using tc action mirred results BUG at net/core/skbuff.c:119


https://bugzilla.kernel.org/show_bug.cgi?id=75571

            Bug ID: 75571
           Summary: using tc action mirred results BUG at
                    net/core/skbuff.c:119
           Product: Networking
           Version: 2.5
    Kernel Version: 3.2.58
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: d77190@mail.ru
        Regression: No

Hello!
Got this bug while setting large shaper ruleset (about 4k hash rules) on mirred
ifb interface at boot time:
Attached archive consists of used shaper scripts.

[   19.355181] ------------[ cut here ]------------
[   19.356148] kernel BUG at net/core/skbuff.c:119!
[   19.356148] invalid opcode: 0000 [#1] SMP 
[   19.356148] Modules linked in: pppoe pppox ppp_generic slhc sch_sfq sch_htb
act_mirred cls_u32 sch_ingress ipt_REJECT ext4 jbd2 ipt_MASQUERADE xt_multiport
xt_rateest xt_RATEEST xt_layer7 xt_HL xt_TPROXY nf_tproxy_core xt_set
xt_connmark ipt_DF ipt_ULOG xt_socket ip6_tables nf_defrag_ipv6 xt_mark
xt_conntrack xt_TCPMSS xt_tcpudp xt_DSCP xt_dscp iptable_raw iptable_mangle
iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter
ip_tables x_tables ip_set_hash_net ip_set nfnetlink cpufreq_ondemand
acpi_cpufreq freq_table processor coretemp mperf ipip hwmon macvlan ifb tun
ipmi_watchdog ipmi_si ipmi_msghandler pcspkr
[   19.356148] 
[   19.356148] Pid: 2305, comm: openvpn Not tainted 3.2.58 #1 Intel Corporation
S3210SH/S3210SH
[   19.356148] EIP: 0060:[<c05cb9e4>] EFLAGS: 00210296 CPU: 0
[   19.356148] EIP is at skb_push+0x84/0x90
[   19.356148] EAX: 0000008b EBX: ef7a7a8e ECX: 00000000 EDX: fffe7ddb
[   19.356148] ESI: f1af8800 EDI: ebc1e840 EBP: f540be24 ESP: f540bdf8
[   19.356148]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   19.356148] Process openvpn (pid: 2305, ti=f540a000 task=f568b190
task.ti=f1b42000)
[   19.356148] Stack:
[   19.356148]  c0988ec4 f9ace566 000000ce 00000094 ef7a7a00 ef7a79c0 ef7a7a8e
ef7a7b40
[   19.356148]  f1af8800 f157ed00 ebc1e600 f540be48 f9ace566 f140c800 00000000
f2790800
[   19.356148]  00000001 f9ace450 f1459220 ebc1e600 f540be60 c05f0cff f540bf1c
00000000
[   19.356148] Call Trace:
[   19.356148]  [<f9ace566>] ? tcf_mirred+0x116/0x15c [act_mirred]
[   19.356148]  [<f9ace566>] tcf_mirred+0x116/0x15c [act_mirred]
[   19.356148]  [<f9ace450>] ? tcf_mirred_dump+0x110/0x110 [act_mirred]
[   19.356148]  [<c05f0cff>] tcf_action_exec+0x3f/0x80
[   19.356148]  [<f9ac70d2>] u32_classify+0x212/0x374 [cls_u32]
[   19.356148]  [<f83e59e6>] ? ipip_rcv+0x136/0x220 [ipip]
[   19.356148]  [<c05f779a>] ? nf_hook_slow+0x5a/0x110
[   19.356148]  [<c063c5a3>] ? tunnel4_rcv+0x33/0x90
[   19.356148]  [<c05fe0bf>] ? ip_local_deliver_finish+0x9f/0x230
[   19.356148]  [<c05ed981>] tc_classify_compat+0x31/0x70
[   19.356148]  [<c05ee8c4>] tc_classify+0x44/0xb0
[   19.356148]  [<f9abe0f1>] ingress_enqueue+0x21/0x80 [sch_ingress]
[   19.356148]  [<c05d2740>] __netif_receive_skb+0x2e0/0x4e0
[   19.356148]  [<c05d2a0a>] process_backlog+0xca/0x1a0
[   19.356148]  [<c05d4929>] net_rx_action+0xc9/0x1c0
[   19.356148]  [<c013e95b>] __do_softirq+0x7b/0x110
[   19.356148]  [<c013e8e0>] ? irq_enter+0x70/0x70
[   19.356148]  [<c013e8e0>] ? irq_enter+0x70/0x70
[   19.356148]  <IRQ> 
[   19.356148]  [<c05d4b30>] ? netif_rx_ni+0x20/0x30
[   19.356148]  [<f836e959>] ? tun_get_user+0x1a9/0x3e0 [tun]
[   19.356148]  [<f836ec2e>] ? tun_chr_aio_write+0x6e/0xb0 [tun]
[   19.356148]  [<c01bb3bc>] ? do_sync_write+0xac/0xf0
[   19.356148]  [<c010b487>] ? init_fpu+0xd7/0x160
[   19.356148]  [<c0123b30>] ? mm_fault_error+0x130/0x130
[   19.356148]  [<c01bbeca>] ? vfs_write+0x9a/0x170
[   19.673799]  [<c01bb310>] ? do_sync_readv_writev+0xe0/0xe0
[   19.673799]  [<c01bc06d>] ? sys_write+0x3d/0x70
[   19.673799]  [<c06d291c>] ? sysenter_do_call+0x12/0x2c
[   19.673799] Code: 5c 24 18 8b 88 a8 00 00 00 89 54 24 0c 89 4c 24 10 8b 40
50 c7 04 24 c4 8e 98 c0 89 44 24 08 8b 45 04 89 44 24 04 e8 e9 3b 10 00 <0f> 0b
eb fe 90 8d b4 26 00 00 00 00 55 89 e5 56 53 83 ec 24 8b 
[   19.673799] EIP: [<c05cb9e4>] skb_push+0x84/0x90 SS:ESP 0068:f540bdf8
[   19.726460] ---[ end trace c5c43cec4bd0fcd8 ]---
[   19.731801] Kernel panic - not syncing: Fatal exception in interrupt

-- 
You are receiving this mail because:
You are the assignee for the bug.
