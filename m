From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 42693] New: WARNING: at net/core/dev.c:1886
 skb_gso_segment+0x2ab/0x320()
Date: Mon, 30 Jan 2012 08:08:24 -0800
Message-ID: <20120130080824.291e1417@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39270 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753695Ab2A3QI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 11:08:27 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 43A0F1410011
	for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 08:08:27 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0xDkgXh1V+Bo for <netdev@vger.kernel.org>;
	Mon, 30 Jan 2012 08:08:26 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id CD1CA141000B
	for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 08:08:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 30 Jan 2012 12:28:10 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42693] New: WARNING: at net/core/dev.c:1886 skb_gso_segment+0x2ab/0x320()


https://bugzilla.kernel.org/show_bug.cgi?id=42693

           Summary: WARNING: at net/core/dev.c:1886
                    skb_gso_segment+0x2ab/0x320()
           Product: Networking
           Version: 2.5
    Kernel Version: 3.0.18
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: web.igor@novg.net
        Regression: Yes


These warnings pops up a few times a second when a relatively high load is
imposed on 10Gbit ethernet, and causing performance degradation.
Looking into code, it seems to be related to segmentation offload, GSO, and
checksums.
The igb and ixgbe modules are out-of-kernel versions from sourceforge.
IGB 3.3.6 and IXGBE 3.7.17, latest at the moment.
When i've fallen back to the 2.6.39.4 with the same modules, the problems
disappear.

[  826.097369] ------------[ cut here ]------------
[  826.097372] WARNING: at net/core/dev.c:1886 skb_gso_segment+0x2ab/0x320()
[  826.097374] ixgbe: caps=(0x72114bb3, 0x0) len=3150 data_len=0 ip_summed=0
[  826.097375] Modules linked in: ixgbe igb
[  826.097377] Pid: 0, comm: swapper Tainted: G        W   3.0.18 #2
[  826.097379] Call Trace:
[  826.097379]  <IRQ>  [<ffffffff8104162c>] ? warn_slowpath_common+0x6c/0xa0
[  826.097383]  [<ffffffff81041715>] ? warn_slowpath_fmt+0x45/0x50
[  826.097386]  [<ffffffff8132353b>] ? skb_gso_segment+0x2ab/0x320
[  826.097389]  [<ffffffff81324f1e>] ? dev_hard_start_xmit+0x21e/0x5f0
[  826.097391]  [<ffffffff8133af53>] ? sch_direct_xmit+0xf3/0x1c0
[  826.097393]  [<ffffffff81325445>] ? dev_queue_xmit+0x155/0x5a0
[  826.097395]  [<ffffffff81274b0a>] ? bond_start_xmit+0x3da/0x470
[  826.097397]  [<ffffffff81366e38>] ? tcp_v4_rcv+0x4c8/0x740
[  826.097400]  [<ffffffff81324f62>] ? dev_hard_start_xmit+0x262/0x5f0
[  826.097402]  [<ffffffff81345db5>] ? ip_local_deliver+0x85/0x110
[  826.097404]  [<ffffffff81325696>] ? dev_queue_xmit+0x3a6/0x5a0
[  826.097406]  [<ffffffff8138a53d>] ? br_dev_queue_push_xmit+0x4d/0x70
[  826.097408]  [<ffffffff8138b11b>] ? br_handle_frame_finish+0x10b/0x1c0
[  826.097410]  [<ffffffff8138b371>] ? br_handle_frame+0x1a1/0x210
[  826.097412]  [<ffffffff81274510>] ? bond_set_carrier+0xa0/0xa0
[  826.097414]  [<ffffffff8138b1d0>] ? br_handle_frame_finish+0x1c0/0x1c0
[  826.097416]  [<ffffffff81322d8d>] ? __netif_receive_skb+0x12d/0x370
[  826.097419]  [<ffffffff81323e48>] ? netif_receive_skb+0x58/0x80
[  826.097421]  [<ffffffff81324249>] ? dev_gro_receive+0x1c9/0x2c0
[  826.097423]  [<ffffffff81324943>] ? napi_gro_receive+0xa3/0xc0
[  826.097427]  [<ffffffffa0064108>] ? ixgbe_poll+0x3f8/0x13f0 [ixgbe]
[  826.097429]  [<ffffffff81070800>] ? hotplug_cfd+0x10/0x40
[  826.097431]  [<ffffffff81324541>] ? net_rx_action+0x81/0x120
[  826.097433]  [<ffffffff81046f78>] ? __do_softirq+0x98/0x120
[  826.097435]  [<ffffffff8107ed2a>] ? handle_irq_event_percpu+0x7a/0x140
[  826.097437]  [<ffffffff813a228c>] ? call_softirq+0x1c/0x30
[  826.097439]  [<ffffffff81003f2d>] ? do_softirq+0x4d/0x80
[  826.097441]  [<ffffffff81047266>] ? irq_exit+0x96/0xc0
[  826.097443]  [<ffffffff81003dec>] ? do_IRQ+0x5c/0xd0
[  826.097445]  [<ffffffff813a0d93>] ? common_interrupt+0x13/0x13
[  826.097446]  <EOI>  [<ffffffff81009738>] ? mwait_idle+0x58/0x80
[  826.097450]  [<ffffffff810009ec>] ? cpu_idle+0x4c/0x90
[  826.097452]  [<ffffffff8154485b>] ? start_kernel+0x2b0/0x2bb
[  826.097453] ---[ end trace f7478101639067dd ]---

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
