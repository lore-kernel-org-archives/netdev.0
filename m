From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 106711] New: VXLAN: RTNL assertion failed at
 net/core/net_namespace.c:187
Date: Wed, 28 Oct 2015 06:57:51 +0900
Message-ID: <20151028065751.4de6201f@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35526 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932781AbbJ0V56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 17:57:58 -0400
Received: by oifu63 with SMTP id u63so86521981oif.2
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 14:57:57 -0700 (PDT)
Received: from samsung9 ([144.49.132.22])
        by smtp.gmail.com with ESMTPSA id v76sm18379242oie.18.2015.10.27.14.57.56
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 14:57:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 27 Oct 2015 14:05:08 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 106711] New: VXLAN: RTNL assertion failed at net/core/net_namespace.c:187


https://bugzilla.kernel.org/show_bug.cgi?id=106711

            Bug ID: 106711
           Summary: VXLAN: RTNL assertion failed at
                    net/core/net_namespace.c:187
           Product: Networking
           Version: 2.5
    Kernel Version: 4.1.10
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: tuomo.turunen@nokia.com
        Regression: No

VXLAN packet receiving triggers ASSERT_RTNL() assertion failure if VXLAN
transport interface is in different network namespace than the VXLAN interface
itself:

[   38.891092] RTNL: assertion failed at
/build/distro/work/shared/linux-stable-30bb3a6af25f17c356252ac6cfbfd3ec04ae1a56/net/core/net_namespace.c
(187)
[   38.892738] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted
4.1.10-pc64-distro.git-v1.14 #1
[   38.893720] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.7.5-20140531_083030-gandalf 04/01/2014
[   38.894933]  ffff8800ba372280 ffff88013ab3f808 ffffffff8078a62a
ffff88013fc110f8
[   38.896059]  00000000ffffffff ffff88013ab3f838 ffffffff8068b7b5
ffff88013a7a3600
[   38.897172]  ffff8800bbbc2c00 ffff8801381262a0 ffff880138126300
ffff88013ab3f848
[   38.898354] Call Trace:
[   38.898763]  [<ffffffff8078a62a>] dump_stack+0x45/0x57
[   38.899436]  [<ffffffff8068b7b5>] __peernet2id+0xa5/0xb0
[   38.900099]  [<ffffffff8068b7d8>] peernet2id+0x18/0x30
[   38.900756]  [<ffffffffa003a2ba>] vxlan_fdb_info+0xfa/0x360 [vxlan]
[   38.901526]  [<ffffffff80682e57>] ? __alloc_skb+0x97/0x1e0
[   38.902216]  [<ffffffffa003a592>] vxlan_fdb_notify+0x72/0x100 [vxlan]
[   38.902994]  [<ffffffffa003b426>] vxlan_fdb_create+0x136/0x370 [vxlan]
[   38.903797]  [<ffffffffa003bf95>] vxlan_snoop+0x1c5/0x1d0 [vxlan]
[   38.904551]  [<ffffffffa003deba>] vxlan_rcv+0x35a/0x5c0 [vxlan]
[   38.905393]  [<ffffffff8069d48f>] ? dst_alloc+0x4f/0x180
[   38.906165]  [<ffffffffa003c208>] vxlan_udp_encap_recv+0x108/0x390 [vxlan]
[   38.907111]  [<ffffffffa003c100>] ? vxlan_encap_bypass.isra.37+0x160/0x160
[vxlan]
[   38.908278]  [<ffffffff806ff81b>] udp_queue_rcv_skb+0x35b/0x450
[   38.909119]  [<ffffffff806fff26>] __udp4_lib_rcv+0x126/0x750
[   38.909915]  [<ffffffff80700a7a>] udp_rcv+0x1a/0x20
[   38.910640]  [<ffffffff806ce5ae>] ip_local_deliver_finish+0xae/0x230
[   38.911529]  [<ffffffff806ce91a>] ip_local_deliver+0x9a/0xb0
[   38.912341]  [<ffffffff806ce218>] ip_rcv_finish+0x88/0x370
[   38.913277]  [<ffffffff806cec0f>] ip_rcv+0x2df/0x3c0
[   38.914000]  [<ffffffff80289343>] ? load_balance+0x233/0xa20
[   38.914807]  [<ffffffff80694b93>] __netif_receive_skb_core+0x6e3/0xa20
[   38.915714]  [<ffffffff8027661c>] ? update_rq_clock.part.81+0x1c/0x40
[   38.916613]  [<ffffffff80694eed>] __netif_receive_skb+0x1d/0x70
[   38.917461]  [<ffffffff80695d42>] process_backlog+0xc2/0x170
[   38.918291]  [<ffffffff806954ba>] net_rx_action+0x20a/0x340
[   38.919123]  [<ffffffff8025702f>] __do_softirq+0xef/0x320
[   38.919959]  [<ffffffff80257285>] run_ksoftirqd+0x25/0x60
[   38.920764]  [<ffffffff80273ecf>] smpboot_thread_fn+0x12f/0x190
[   38.921605]  [<ffffffff80273da0>] ? sort_range+0x30/0x30
[   38.922384]  [<ffffffff80270bb9>] kthread+0xc9/0xe0
[   38.923104]  [<ffffffff80270af0>] ? kthread_create_on_node+0x180/0x180
[   38.923994]  [<ffffffff80790e02>] ret_from_fork+0x42/0x70
[   38.924772]  [<ffffffff80270af0>] ? kthread_create_on_node+0x180/0x180


Seems to me that peernet2id() function should not be called while receiving
packets or then peernet2id() function should not use rtnl lock.

The issue can be reproduced with following configuration + ping (one host is
enough, real network is not needed):

ip netns add ns0
ip netns exec ns0 ip link set lo up
ip netns add ns1
ip netns exec ns1 ip link set lo up
ip netns add ns2
ip netns exec ns2 ip link set lo up
ip netns add ns3
ip netns exec ns3 ip link set lo up
ip link add type veth
ip link set veth0 netns ns0
ip netns exec ns0 ip link set veth0 up
ip netns exec ns0 ip addr add 10.0.0.1/24 dev veth0
ip link set veth1 netns ns1
ip netns exec ns1 ip link set veth1 up
ip netns exec ns1 ip addr add 10.0.0.2/24 dev veth1
ip netns exec ns0 ip link add name vxlan0 type vxlan id 1000 group 224.0.0.1
local 10.0.0.1 dev veth0 learning
ip netns exec ns0 ip link set vxlan0 netns ns2
ip netns exec ns2 ip link set vxlan0 up
ip netns exec ns2 ip addr add 20.0.0.1/24 dev vxlan0
ip netns exec ns1 ip link add name vxlan1 type vxlan id 1000 group 224.0.0.1
local 10.0.0.2 dev veth1 learning
ip netns exec ns1 ip link set vxlan1 netns ns3
ip netns exec ns3 ip link set vxlan1 up
ip netns exec ns3 ip addr add 20.0.0.2/24 dev vxlan1
ip netns exec ns2 ping 20.0.0.1

-- 
You are receiving this mail because:
You are the assignee for the bug.
