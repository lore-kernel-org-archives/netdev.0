From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: WARNING while bringing up macvlan
Date: Fri, 28 Mar 2008 15:05:20 +0200
Message-ID: <20080328125409.M80978@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:53182 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbYC1NFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 09:05:40 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id AF465BDCA2
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 15:05:20 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To trigger just run:
ip link add link eth0 eth2 type macvlan
ip link set eth2 up

i have enabled
CONFIG_DEBUG_KERNEL=y
CONFIG_SCHED_DEBUG=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_RODATA=y


[ 1212.916288] ------------[ cut here ]------------
[ 1212.916322] WARNING: at kernel/mutex.c:353 mutex_trylock+0x3c/0xef()
[ 1212.916354] Modules linked in: macvlan softdog nf_nat_pptp 
nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre hangcheck_timer 
xt_tcpudp ipt_TTL ipt_ttl xt_NOTRACK iptable_raw iptable_mangle ifb e1000e 
em_nbyte cls_tcindex act_gact cls_rsvp sch_htb cls_fw act_mirred em_u32 
sch_red sch_sfq sch_tbf sch_teql cls_basic act_police sch_gred act_pedit 
sch_hfsc cls_rsvp6 sch_ingress em_meta em_text act_ipt sch_dsmark sch_prio 
sch_netem act_simple cls_u32 em_cmp sch_cbq cls_route xt_TCPMSS iptable_nat 
nf_conntrack_ipv4 ipt_LOG ipt_MASQUERADE ipt_REDIRECT nf_nat nf_conntrack 
nfnetlink iptable_filter ip_tables x_tables 8021q tun tulip r8169 sky2 
via_velocity via_rhine sis900 ne2k_pci 8390 skge tg3 8139too e1000 e100 
usb_storage mtdblock mtd_blkdevs usbhid uhci_hcd ehci_hcd ohci_hcd usbcore
[ 1212.916781] Pid: 2572, comm: ip Not tainted 2.6.25-rc7-git1-build-0026 #34
[ 1212.916818]  [<c0121038>] warn_on_slowpath+0x41/0x51
[ 1212.916859]  [<c012f652>] ? __kernel_text_address+0x1b/0x27
[ 1212.916895]  [<c010493a>] ? dump_trace+0xce/0xda
[ 1212.916927]  [<c0109ea6>] ? save_stack_address+0x0/0x2c
[ 1212.916965]  [<c013afc8>] ? mark_held_locks+0x41/0x5c
[ 1212.916999]  [<c015cdef>] ? kmem_cache_alloc+0x69/0xa1
[ 1212.917033]  [<c013b12d>] ? trace_hardirqs_on+0xcb/0x102
[ 1212.917067]  [<c02ba549>] mutex_trylock+0x3c/0xef
[ 1212.917099]  [<c0272796>] rtnl_trylock+0xd/0xf
[ 1212.917131]  [<c0268bc8>] __dev_set_promiscuity+0x15/0xa9
[ 1212.917164]  [<c0268c97>] __dev_set_rx_mode+0x3b/0x75
[ 1212.917196]  [<c026c1ab>] dev_unicast_add+0x79/0x94
[ 1212.917228]  [<f8a6565f>] macvlan_open+0x2c/0x73 [macvlan]
[ 1212.917264]  [<c026b6f6>] dev_open+0x42/0x74
[ 1212.917293]  [<c026a392>] dev_change_flags+0x9f/0x14f
[ 1212.917326]  [<c0271b19>] do_setlink+0x248/0x2fd
[ 1212.917360]  [<c0272eab>] rtnl_newlink+0x24a/0x399
[ 1212.917403]  [<c02bab26>] ? mutex_lock_nested+0x1e8/0x1fa
[ 1212.917438]  [<c0272c61>] ? rtnl_newlink+0x0/0x399
[ 1212.917470]  [<c027297e>] rtnetlink_rcv_msg+0x193/0x1ad
[ 1212.917504]  [<c02727ca>] ? rtnl_lock+0xf/0x11
[ 1212.917537]  [<c02727eb>] ? rtnetlink_rcv_msg+0x0/0x1ad
[ 1212.917571]  [<c027cf52>] netlink_rcv_skb+0x30/0x82
[ 1212.917603]  [<c02727e3>] rtnetlink_rcv+0x17/0x1f
[ 1212.917635]  [<c027cd32>] netlink_unicast+0x1bb/0x220
[ 1212.917657]  [<c027d4ea>] netlink_sendmsg+0x243/0x250
[ 1212.917693]  [<c0260580>] sock_sendmsg+0xca/0xe1
[ 1212.917728]  [<c013106e>] ? autoremove_wake_function+0x0/0x33
[ 1212.917764]  [<c013106e>] ? autoremove_wake_function+0x0/0x33
[ 1212.917800]  [<c013106e>] ? autoremove_wake_function+0x0/0x33
[ 1212.917837]  [<c01f080a>] ? copy_from_user+0x2c/0x4f
[ 1212.917871]  [<c0266acd>] ? verify_iovec+0x40/0x73
[ 1212.917904]  [<c02606e6>] sys_sendmsg+0x14f/0x1aa
[ 1212.917936]  [<c0260ebf>] ? sys_recvmsg+0x117/0x17f
[ 1212.917971]  [<c013afc8>] ? mark_held_locks+0x41/0x5c
[ 1212.918012]  [<c0152cfe>] ? handle_mm_fault+0x2d0/0x2e3
[ 1212.918047]  [<c02bba34>] ? _spin_unlock+0x1d/0x20
[ 1212.918084]  [<c0261386>] sys_socketcall+0x14e/0x166
[ 1212.918117]  [<c01038e9>] ? sysenter_past_esp+0x9a/0xa5
[ 1212.918151]  [<c01038ae>] sysenter_past_esp+0x5f/0xa5
[ 1212.918187]  =======================
[ 1212.918654] ---[ end trace 06fb1c0a761da1b0 ]---

one more

[   49.772366] ------------[ cut here ]------------
[   49.772416] WARNING: at kernel/mutex.c:353 mutex_trylock+0x3c/0xef()
[   49.772447] Modules linked in: macvlan softdog nf_nat_pptp 
nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre hangcheck_timer 
xt_tcpudp ipt_TTL ipt_ttl xt_NOTRACK iptable_raw iptable_mangle ifb e1000e 
em_nbyte cls_tcindex act_gact cls_rsvp sch_htb cls_fw act_mirred em_u32 
sch_red sch_sfq sch_tbf sch_teql cls_basic act_police sch_gred act_pedit 
sch_hfsc cls_rsvp6 sch_ingress em_meta em_text act_ipt sch_dsmark sch_prio 
sch_netem act_simple cls_u32 em_cmp sch_cbq cls_route xt_TCPMSS iptable_nat 
nf_conntrack_ipv4 ipt_LOG ipt_MASQUERADE ipt_REDIRECT nf_nat nf_conntrack 
nfnetlink iptable_filter ip_tables x_tables 8021q tun tulip r8169 sky2 
via_velocity via_rhine sis900 ne2k_pci 8390 skge tg3 8139too e1000 e100 
usb_storage mtdblock mtd_blkdevs usbhid uhci_hcd ehci_hcd ohci_hcd usbcore
[   49.774284] Pid: 2415, comm: ip Not tainted 2.6.25-rc7-git1-build-0026 #34
[   49.774354]  [<c0121038>] warn_on_slowpath+0x41/0x51
[   49.774427]  [<c013b963>] ? __lock_acquire+0x45c/0xabd
[   49.774510]  [<c012f652>] ? __kernel_text_address+0x1b/0x27
[   49.774597]  [<c010493a>] ? dump_trace+0xce/0xda
[   49.774680]  [<c0109ea6>] ? save_stack_address+0x0/0x2c
[   49.774769]  [<c013afc8>] ? mark_held_locks+0x41/0x5c
[   49.774853]  [<c015cdef>] ? kmem_cache_alloc+0x69/0xa1
[   49.774938]  [<c013b12d>] ? trace_hardirqs_on+0xcb/0x102
[   49.775022]  [<c02ba549>] mutex_trylock+0x3c/0xef
[   49.775088]  [<c0272796>] rtnl_trylock+0xd/0xf
[   49.775154]  [<c0268bc8>] __dev_set_promiscuity+0x15/0xa9
[   49.775221]  [<c0268c97>] __dev_set_rx_mode+0x3b/0x75
[   49.775286]  [<c026c1ab>] dev_unicast_add+0x79/0x94
[   49.775352]  [<f8a6565f>] macvlan_open+0x2c/0x73 [macvlan]
[   49.775448]  [<c026b6f6>] dev_open+0x42/0x74
[   49.775512]  [<c026a392>] dev_change_flags+0x9f/0x14f
[   49.775578]  [<c0271b19>] do_setlink+0x248/0x2fd
[   49.775645]  [<c0272eab>] rtnl_newlink+0x24a/0x399
[   49.775722]  [<c02bab26>] ? mutex_lock_nested+0x1e8/0x1fa
[   49.775807]  [<c0272c61>] ? rtnl_newlink+0x0/0x399
[   49.775890]  [<c027297e>] rtnetlink_rcv_msg+0x193/0x1ad
[   49.775957]  [<c02727ca>] ? rtnl_lock+0xf/0x11
[   49.776040]  [<c02727eb>] ? rtnetlink_rcv_msg+0x0/0x1ad
[   49.776124]  [<c027cf52>] netlink_rcv_skb+0x30/0x82
[   49.776190]  [<c02727e3>] rtnetlink_rcv+0x17/0x1f
[   49.776255]  [<c027cd32>] netlink_unicast+0x1bb/0x220
[   49.776322]  [<c027d4ea>] netlink_sendmsg+0x243/0x250
[   49.776391]  [<c0260580>] sock_sendmsg+0xca/0xe1
[   49.776451]  [<c013106e>] ? autoremove_wake_function+0x0/0x33
[   49.776538]  [<c013106e>] ? autoremove_wake_function+0x0/0x33
[   49.776625]  [<c013106e>] ? autoremove_wake_function+0x0/0x33
[   49.776713]  [<c01f080a>] ? copy_from_user+0x2c/0x4f
[   49.776797]  [<c0266acd>] ? verify_iovec+0x40/0x73
[   49.776881]  [<c02606e6>] sys_sendmsg+0x14f/0x1aa
[   49.776947]  [<c0260ebf>] ? sys_recvmsg+0x117/0x17f
[   49.777032]  [<c013afc8>] ? mark_held_locks+0x41/0x5c
[   49.777124]  [<c0152cfe>] ? handle_mm_fault+0x2d0/0x2e3
[   49.777210]  [<c02bba34>] ? _spin_unlock+0x1d/0x20
[   49.777296]  [<c0261386>] sys_socketcall+0x14e/0x166
[   49.777363]  [<c01038e9>] ? sysenter_past_esp+0x9a/0xa5
[   49.777447]  [<c01038ae>] sysenter_past_esp+0x5f/0xa5
[   49.777517]  =======================
[   49.777560] ---[ end trace e18ee8b62e9cda31 ]---




--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

