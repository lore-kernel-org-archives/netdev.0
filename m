From: Ben Greear <greearb@candelatech.com>
Subject: skb_warn_bad_offload related to IPv6 in 3.9.9+
Date: Thu, 11 Jul 2013 11:52:27 -0700
Message-ID: <51DEFEEB.1080408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33164 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab3GKSw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 14:52:28 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r6BIqRoI026328
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 11:52:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This kernel has local patches applied...but I don't think it has anything
that would cause this....

The wanlink module is something we added.  It is now GPL, but code is
not upstream.  I don't think it's in directly related to the splat though...

Only saw one splat, and system remains stable as far as we can tell.

------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-3.9.dev.y/net/core/dev.c:2179 skb_warn_bad_offload+0xc2/0xcb()
Hardware name: X7DBU
e1000e: caps=(0x00000000700003a9, 0x0000000000000000) len=2942 data_len=1428 gso_size=1428 gso_type=16 ip_summed=1
Modules linked in: iptable_raw xt_CT bridge tcp_lp veth nls_utf8 cifs 8021q garp stp mrp llc nf_nat_ipv4 nf_nat fuse macvlan wanlink(O) pktgen nfsv3 nfs_acl 
nfsv4 auth_rpcgss nfs fscache lockd sunrpc w83793 w83627hf hwmon_vid coretemp i5k_amb mperf kvm_intel i5000_edac edac_core iTCO_wdt ioatdma gpio_ich shpchp 
iTCO_vendor_support e1000e lpc_ich kvm ptp dca pps_core i2c_i801 microcode pcspkr uinput ipv6 floppy radeon i2c_algo_bit hwmon drm_kms_helper ttm drm i2c_core 
[last unloaded: iptable_nat]
Pid: 1587, comm: kwanlink/0 Tainted: G         C O 3.9.9+ #104
Call Trace:
  <IRQ>  [<ffffffff81096291>] warn_slowpath_common+0x85/0x9f
  [<ffffffff8109634e>] warn_slowpath_fmt+0x46/0x48
  [<ffffffff815110d9>] skb_warn_bad_offload+0xc2/0xcb
  [<ffffffff81512cd5>] __skb_gso_segment+0x34/0xa2
  [<ffffffff81513233>] dev_hard_start_xmit+0x1c3/0x3b8
  [<ffffffff8152de81>] sch_direct_xmit+0x75/0x154
  [<ffffffff8151367b>] try_dev_queue_xmit+0x253/0x493
  [<ffffffff815138cb>] dev_queue_xmit+0x10/0x12
  [<ffffffffa0175707>] ip6_finish_output2+0x2cf/0x339 [ipv6]
  [<ffffffffa017580f>] ip6_finish_output+0x9e/0xa3 [ipv6]
  [<ffffffffa017376f>] ? __ipv6_neigh_lookup_noref+0x9a/0x9a [ipv6]
  [<ffffffffa0176724>] ip6_output+0x8b/0x93 [ipv6]
  [<ffffffffa01814b8>] ? ip6_pol_route+0x398/0x398 [ipv6]
  [<ffffffffa01736d3>] dst_output+0xf/0x11 [ipv6]
  [<ffffffffa0173778>] ip6_forward_finish+0x9/0xb [ipv6]
  [<ffffffffa0175433>] NF_HOOK.clone.0+0x30/0x35 [ipv6]
  [<ffffffffa01761d5>] ip6_forward+0x6b7/0x732 [ipv6]
  [<ffffffffa017f3b3>] ? ip6_route_input+0xaa/0xb5 [ipv6]
  [<ffffffffa01767a1>] ? ipv6_is_mld+0x75/0x75 [ipv6]
  [<ffffffffa0176841>] ip6_rcv_finish+0xa0/0xa4 [ipv6]
  [<ffffffffa0176bbf>] NF_HOOK.clone.1+0x4c/0x53 [ipv6]
  [<ffffffffa0176ecf>] ipv6_rcv+0x309/0x342 [ipv6]
  [<ffffffff8150fb2e>] __netif_receive_skb_core+0x4e7/0x558
  [<ffffffff8150fbed>] __netif_receive_skb+0x4e/0x5e
  [<ffffffff8150fcf8>] process_backlog+0xfb/0x1dc
  [<ffffffff815123d3>] net_rx_action+0xc2/0x267
  [<ffffffff810da28d>] ? ktime_get+0x4a/0x84
  [<ffffffff8109da08>] __do_softirq+0x114/0x254
  [<ffffffff815d299c>] call_softirq+0x1c/0x30
  <EOI>  [<ffffffff81011d3e>] do_softirq+0x46/0x83
  [<ffffffff8109dcb1>] _local_bh_enable_ip+0x7a/0x9b
  [<ffffffff8109dce0>] local_bh_enable_ip+0xe/0x10
  [<ffffffff815cacb9>] _raw_spin_unlock_bh+0x24/0x26
  [<ffffffffa0d63d67>] wle_tx_pkts+0x85a/0xe8f [wanlink]
  [<ffffffff815c9106>] ? schedule_hrtimeout_range_clock+0xe1/0x108
  [<ffffffffa0d64440>] do_task+0xa4/0x225 [wanlink]
  [<ffffffffa0d64708>] wl_thread_task+0x147/0x1ed [wanlink]
  [<ffffffffa0d645c1>] ? do_task+0x225/0x225 [wanlink]
  [<ffffffff810b496d>] kthread+0xb5/0xbd
  [<ffffffff810b48b8>] ? kthread_freezable_should_stop+0x60/0x60
  [<ffffffff815d15ac>] ret_from_fork+0x7c/0xb0
  [<ffffffff810b48b8>] ? kthread_freezable_should_stop+0x60/0x60
---[ end trace d5734e2ef6e4f61a ]---
-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
