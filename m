From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: [BUG] vanilla 32bit 3.4.0, lockdep, =?UTF-8?Q?l=32tp=5Fxmit=5Fskb?=
 =?UTF-8?Q?=20+=20sch=5Fdirect=5Fxmit=20warning?=
Date: Mon, 04 Jun 2012 15:37:29 +0300
Message-ID: <9c27483e8fbe0d9ec77501968d152c90@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:51684 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab2FDMhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 08:37:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CBSS_PPPoE ~ # ip l2tp show tunnel
Tunnel 2, encap IP
   From 194.146.153.XX to 194.146.153.YY
   Peer tunnel 2

CBSS_PPPoE ~ # ip l2tp show session
   Session 1 in tunnel 2
   Peer session 1, tunnel 2
   interface name: tun0
   offset 0, peer offset 0

CBSS_PPPoE ~ # ip link show dev tun0
303: tun0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc pfifo_fast 
state UNKNOWN mode DEFAULT qlen 1000
     link/ether 6e:25:18:ce:8e:3b brd ff:ff:ff:ff:ff:ff
CBSS_PPPoE ~ # ip addr show dev tun0
303: tun0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc pfifo_fast 
state UNKNOWN qlen 1000
     link/ether 6e:25:18:ce:8e:3b brd ff:ff:ff:ff:ff:ff
     inet 10.0.6.2/24 scope global tun0

command was executed: ping 10.0.6.1

         [  135.292915]
         [  135.293008] 
======================================================
         [  135.293115] [ INFO: possible circular locking dependency 
detected ]
         [  135.293221] 3.4.0-build-0061 #12 Not tainted
         [  135.293316] 
-------------------------------------------------------
         [  135.293420] ping/6404 is trying to acquire lock:
         [  135.293517]  (slock-AF_INET){+.-...}, at: [<f88c83ec>] 
l2tp_xmit_skb+0x173/0x47e [l2tp_core]
         [  135.293780]
         [  135.293780] but task is already holding lock:
         [  135.293970]  (_xmit_ETHER#2){+.-...}, at: [<c02f09b9>] 
sch_direct_xmit+0x36/0x119
         [  135.294251]
         [  135.294252] which lock already depends on the new lock.
         [  135.294252]
         [  135.294532]
         [  135.294533] the existing dependency chain (in reverse order) 
is:
         [  135.294727]
         [  135.294728] -> #1 (_xmit_ETHER#2){+.-...}:
         [  135.295018]        [<c015a6d1>] lock_acquire+0x71/0x85
         [  135.295140]        [<c034ddad>] _raw_spin_lock+0x33/0x40
         [  135.295262]        [<c02e79f2>] neigh_update+0x1d9/0x385
         [  135.295384]        [<c031fff7>] arp_process+0x477/0x491
         [  135.295507]        [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
         [  135.295628]        [<c031fb2c>] arp_rcv+0xb1/0xc3
         [  135.295748]        [<c02deca7>] 
__netif_receive_skb+0x329/0x378
         [  135.295873]        [<c02dee74>] netif_receive_skb+0x4e/0x7d
         [  135.295997]        [<c02def60>] napi_skb_finish+0x1e/0x34
         [  135.296121]        [<c02df389>] napi_gro_receive+0x20/0x24
         [  135.296245]        [<f8527213>] rtl8169_poll+0x2e6/0x52c 
[r8169]
         [  135.296374]        [<c02df48f>] net_rx_action+0x90/0x15d
         [  135.296496]        [<c012b42d>] __do_softirq+0x7b/0x118
         [  135.296620]
         [  135.296620] -> #0 (slock-AF_INET){+.-...}:
         [  135.296889]        [<c015a08b>] __lock_acquire+0x9a3/0xc27
         [  135.297010]        [<c015a6d1>] lock_acquire+0x71/0x85
         [  135.297130]        [<c034ddad>] _raw_spin_lock+0x33/0x40
         [  135.297251]        [<f88c83ec>] l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
         [  135.297376]        [<f86b11fb>] l2tp_eth_dev_xmit+0x1a/0x2f 
[l2tp_eth]
         [  135.297500]        [<c02e0573>] 
dev_hard_start_xmit+0x333/0x3f2
         [  135.297623]        [<c02f09d8>] sch_direct_xmit+0x55/0x119
         [  135.297745]        [<c02e08b4>] dev_queue_xmit+0x282/0x418
         [  135.297868]        [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
         [  135.297992]        [<c031f8b0>] arp_xmit+0x22/0x24
         [  135.298113]        [<c031f8f3>] arp_send+0x41/0x48
         [  135.300267]        [<c031fa65>] arp_solicit+0x16b/0x181
         [  135.300388]        [<c02e6852>] neigh_probe+0x3c/0x52
         [  135.300509]        [<c02e6e46>] 
__neigh_event_send+0x1a3/0x1bc
         [  135.300630]        [<c02e8221>] 
neigh_resolve_output+0x59/0x149
         [  135.300750]        [<c03039e0>] 
ip_finish_output2+0x1e1/0x21c
         [  135.300871]        [<c0303a50>] ip_finish_output+0x35/0x39
         [  135.300989]        [<c03048c7>] ip_output+0x87/0x8c
         [  135.301110]        [<c03030c6>] dst_output+0x15/0x18
         [  135.301232]        [<c03042d7>] ip_local_out+0x17/0x1a
         [  135.301355]        [<c0304f59>] ip_send_skb+0x12/0x5c
         [  135.301478]        [<c0304fcd>] 
ip_push_pending_frames+0x2a/0x2e
         [  135.301603]        [<c031b98d>] raw_sendmsg+0x67a/0x749
         [  135.301726]        [<c032445f>] inet_sendmsg+0x53/0x5a
         [  135.301850]        [<c02d0162>] sock_sendmsg+0xaa/0xc2
         [  135.301974]        [<c02d0387>] __sys_sendmsg+0x182/0x20c
         [  135.302098]        [<c02d1518>] sys_sendmsg+0x36/0x4d
         [  135.302219]        [<c02d1a66>] sys_socketcall+0x214/0x27e
         [  135.302344]        [<c034e511>] syscall_call+0x7/0xb
         [  135.302467]
         [  135.302468] other info that might help us debug this:
         [  135.302468]
         [  135.302739]  Possible unsafe locking scenario:
         [  135.302739]
         [  135.302928]        CPU0                    CPU1
         [  135.303022]        ----                    ----
         [  135.303118]   lock(_xmit_ETHER#2);
         [  135.303274]                                
lock(slock-AF_INET);
         [  135.303417]                                
lock(_xmit_ETHER#2);
         [  135.303582]   lock(slock-AF_INET);
         [  135.303719]
         [  135.303719]  *** DEADLOCK ***
         [  135.303719]
         [  135.303990] 4 locks held by ping/6404:
         [  135.304087]  #0:  (sk_lock-AF_INET){+.+.+.}, at: 
[<c031b928>] raw_sendmsg+0x615/0x749
         [  135.304361]  #1:  (rcu_read_lock){.+.+..}, at: [<c0302fad>] 
rcu_read_lock+0x0/0x35
         [  135.304637]  #2:  (rcu_read_lock_bh){.+....}, at: 
[<c02dbf9c>] rcu_lock_acquire+0x0/0x30
         [  135.304913]  #3:  (_xmit_ETHER#2){+.-...}, at: [<c02f09b9>] 
sch_direct_xmit+0x36/0x119
         [  135.305209]
         [  135.305209] stack backtrace:
         [  135.305391] Pid: 6404, comm: ping Not tainted 
3.4.0-build-0061 #12
         [  135.305492] Call Trace:
         [  135.305589]  [<c034c156>] ? printk+0x18/0x1a
         [  135.305689]  [<c0158a74>] print_circular_bug+0x1ac/0x1b6
         [  135.305790]  [<c015a08b>] __lock_acquire+0x9a3/0xc27
         [  135.305890]  [<c0159500>] ? valid_state+0x1d4/0x201
         [  135.305989]  [<c019d0d6>] ? 
__slab_alloc.clone.59.clone.64+0xc4/0x2de
         [  135.306097]  [<c015a6d1>] lock_acquire+0x71/0x85
         [  135.306197]  [<f88c83ec>] ? l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
         [  135.306301]  [<c034ddad>] _raw_spin_lock+0x33/0x40
         [  135.306401]  [<f88c83ec>] ? l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
         [  135.306506]  [<f88c83ec>] l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
         [  135.306609]  [<c014f946>] ? timekeeping_get_ns+0xf/0x46
         [  135.306710]  [<f86b11fb>] l2tp_eth_dev_xmit+0x1a/0x2f 
[l2tp_eth]
         [  135.306815]  [<c02e0573>] dev_hard_start_xmit+0x333/0x3f2
         [  135.306919]  [<c02f09d8>] sch_direct_xmit+0x55/0x119
         [  135.307016]  [<c02e08b4>] dev_queue_xmit+0x282/0x418
         [  135.307112]  [<c02e0632>] ? dev_hard_start_xmit+0x3f2/0x3f2
         [  135.307220]  [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
         [  135.307322]  [<c031f8b0>] arp_xmit+0x22/0x24
         [  135.307428]  [<c02e0632>] ? dev_hard_start_xmit+0x3f2/0x3f2
         [  135.307529]  [<c031f8f3>] arp_send+0x41/0x48
         [  135.307625]  [<c031fa65>] arp_solicit+0x16b/0x181
         [  135.307721]  [<c02e6852>] neigh_probe+0x3c/0x52
         [  135.307821]  [<c02e6e46>] __neigh_event_send+0x1a3/0x1bc
         [  135.307923]  [<c02e8221>] neigh_resolve_output+0x59/0x149
         [  135.308025]  [<c0302fe0>] ? rcu_read_lock+0x33/0x35
         [  135.308125]  [<c03039e0>] ip_finish_output2+0x1e1/0x21c
         [  135.308225]  [<c02fcce6>] ? ipv4_mtu+0x36/0x65
         [  135.308326]  [<c0303a50>] ip_finish_output+0x35/0x39
         [  135.308426]  [<c03048c7>] ip_output+0x87/0x8c
         [  135.308523]  [<c0303a1b>] ? ip_finish_output2+0x21c/0x21c
         [  135.308624]  [<c03030c6>] dst_output+0x15/0x18
         [  135.308721]  [<c03042d7>] ip_local_out+0x17/0x1a
         [  135.308821]  [<c0304f59>] ip_send_skb+0x12/0x5c
         [  135.308922]  [<c0304fcd>] ip_push_pending_frames+0x2a/0x2e
         [  135.309022]  [<c031b98d>] raw_sendmsg+0x67a/0x749
         [  135.309119]  [<c032445f>] inet_sendmsg+0x53/0x5a
         [  135.309219]  [<c02d0162>] sock_sendmsg+0xaa/0xc2
         [  135.309318]  [<c015a397>] ? 
lock_release_non_nested+0x88/0x20b
         [  135.309420]  [<c01898a0>] ? might_fault+0x2d/0x79
         [  135.309520]  [<c01898e6>] ? might_fault+0x73/0x79
         [  135.309620]  [<c02d8400>] ? copy_from_user+0x8/0xa
         [  135.309717]  [<c02d8729>] ? verify_iovec+0x3e/0x75
         [  135.309817]  [<c02d0387>] __sys_sendmsg+0x182/0x20c
         [  135.309919]  [<c0159553>] ? mark_lock+0x26/0x1bb
         [  135.310019]  [<c0159bb6>] ? __lock_acquire+0x4ce/0xc27
         [  135.310120]  [<c018b700>] ? handle_pte_fault+0x284/0x93d
         [  135.310221]  [<c015a397>] ? 
lock_release_non_nested+0x88/0x20b
         [  135.310328]  [<c0188dee>] ? page_address+0x8a/0x9f
         [  135.310430]  [<c01898a0>] ? might_fault+0x2d/0x79
         [  135.310531]  [<c01a42e2>] ? fget_light+0x2b/0x7c
         [  135.310631]  [<c02d1518>] sys_sendmsg+0x36/0x4d
         [  135.310725]  [<c02d1a66>] sys_socketcall+0x214/0x27e
         [  135.310827]  [<c034e544>] ? restore_all+0xf/0xf
         [  135.310929]  [<c011e817>] ? vmalloc_sync_all+0x5/0x5
         [  135.311032]  [<c022d2ec>] ? trace_hardirqs_on_thunk+0xc/0x10
         [  135.311135]  [<c034e511>] syscall_call+0x7/0xb
---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
