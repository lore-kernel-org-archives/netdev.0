From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] NETDEV_UNREGISTER_BATCH seems unused nowaday ?
Date: Fri, 10 Aug 2012 11:27:04 +0200
Message-ID: <1344590824.31104.1953.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35219 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758131Ab2HJJ1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 05:27:09 -0400
Received: by bkwj10 with SMTP id j10so510365bkw.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 02:27:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETDEV_UNREGISTER_BATCH seems unused we can probably remove it.

I am tracking a device refcount issue, delaying net device dismantle by
1 second in netdev_wait_allrefs()

I guess we need to add a notifier called _after_ the final
synchronize_net() in rollback_registered_many()

[   52.022261] calling rtnetlink_dev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022266] calling fib_rules_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022270] calling arp_netdev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022274] calling ip_netdev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022277] calling fib_netdev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022280] calling ip_mr_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022284] calling ndisc_netdev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022287] calling ip6_route_dev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022290] calling ipv6_dev_notf msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022293] calling packet_netdev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022297] calling dst_dev_notifier msg/val 9 data ffff880610bea000 refcnt 15->15
[   52.022331] calling rtnetlink_dev_notifier msg/val 2 data ffff880610bea000 refcnt 15->15
[   52.022335] calling fib_rules_notifier msg/val 2 data ffff880610bea000 refcnt 15->15
[   52.022340] calling arp_netdev_notifier msg/val 2 data ffff880610bea000 refcnt 15->15
[   52.022350] calling ip_netdev_notifier msg/val 2 data ffff880610bea000 refcnt 15->15
[   52.022374] arp: arp_ifdown dev ffff880610bea000 refcnt 15
[   52.022382] calling fib_netdev_notifier msg/val 2 data ffff880610bea000 refcnt 15->14
[   52.022931] IPv4: rt_free(ffff8802fee7e180)
[   52.023394] calling ip_mr_notifier msg/val 2 data ffff880610bea000 refcnt 14->14
[   52.023402] IPv6: dst_free(ffff88060b680480) refcnt 0
[   52.023404] IPv6: dst_free(ffff880307f7cf00) refcnt 0
[   52.023407] IPv6: dst_free(ffff880307f7cd80) refcnt 0
[   52.023409] IPv6: dst_free(ffff880307f7cc00) refcnt 0
[   52.023410] IPv6: dst_free(ffff88060b680180) refcnt 0
[   52.023412] IPv6: dst_free(ffff88060810c780) refcnt 0
[   52.023414] IPv6: dst_free(ffff88060810c600) refcnt 0
[   52.023415] IPv6: dst_free(ffff88060810c480) refcnt 0
[   52.023421] calling ndisc_netdev_notifier msg/val 2 data ffff880610bea000 refcnt 14->14
[   52.023424] calling ip6_route_dev_notifier msg/val 2 data ffff880610bea000 refcnt 14->14
[   52.023432] calling ipv6_dev_notf msg/val 2 data ffff880610bea000 refcnt 14->14
[   52.023436] calling packet_netdev_notifier msg/val 2 data ffff880610bea000 refcnt 14->14
[   52.023522] dst_ifdown dst ffff8802fee7e000 dev ffff880610bea000 dst->dev ffff880311b33000 unreg 0 dev->refcnt 14
[   52.023525] calling dst_dev_notifier msg/val 2 data ffff880610bea000 refcnt 14->14
[   52.024267] calling rtnetlink_dev_notifier msg/val 6 data ffff880610bea000 refcnt 13->13
[   52.024272] calling fib_rules_notifier msg/val 6 data ffff880610bea000 refcnt 13->13
[   52.024277] calling arp_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 13->13
[   52.024279] inetdev_destroy()
[   52.024315] arp: arp_ifdown dev ffff880610bea000 refcnt 13
[   52.024421] arp: arp_ifdown dev ffff880610bea000 refcnt 12
[   52.024425] calling ip_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 13->12
[   52.024430] arp: arp_ifdown dev ffff880610bea000 refcnt 12
[   52.024434] calling fib_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 12->12
[   52.024437] calling ip_mr_notifier msg/val 6 data ffff880610bea000 refcnt 12->12
[   52.024440] calling ndisc_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 12->12
[   52.024443] calling ip6_route_dev_notifier msg/val 6 data ffff880610bea000 refcnt 12->12
[   52.024458] calling ipv6_dev_notf msg/val 6 data ffff880610bea000 refcnt 12->10
[   52.024462] calling packet_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 10->9
[   52.024465] dst_ifdown dst ffff8802fee7e000 dev ffff880610bea000 dst->dev ffff880311b33000 unreg 1 dev->refcnt 9
[   52.024468] calling dst_dev_notifier msg/val 6 data ffff880610bea000 refcnt 9->9
[   52.024564] calling rtnetlink_dev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024569] calling fib_rules_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024574] calling arp_netdev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024579] calling ip_netdev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024583] calling fib_netdev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024586] calling ip_mr_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024589] calling ndisc_netdev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024592] calling ip6_route_dev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024595] calling ipv6_dev_notf msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024598] calling packet_netdev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.024601] calling dst_dev_notifier msg/val 17 data ffff880610bea000 refcnt 7->7
[   52.028214] IPv4: dst_free(ffff8802fee7e180) refcnt 0
[   52.033207] dst_free(ffff88060816e0c0) refcnt 1
[   52.033212] adding dst ffff88060816e0c0 to garbage
[   52.033214] ------------[ cut here ]------------
[   52.033221] WARNING: at net/core/dst.c:215 __dst_free+0x57/0xf0()
[   52.033224] Hardware name: HP Z600 Workstation
[   52.033225] Modules linked in: tun ip6table_filter ip6_tables ebtable_nat ebtables xt_state ipt_REJECT fuse iptable_mangle iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bridge stp nfsd auth_rpcgss exportfs nfs lockd sunrpc asix usbnet rt61pci crc_itu_t rt2x00pci rt2x00lib eeprom_93cx6 tg3 ixgbe mdio igb
[   52.033254] Pid: 0, comm: swapper/6 Tainted: G        W    3.5.0+ #764
[   52.033255] Call Trace:
[   52.033257]  <IRQ>  [<ffffffff8103de0f>] warn_slowpath_common+0x7f/0xc0
[   52.033266]  [<ffffffff8103de6a>] warn_slowpath_null+0x1a/0x20
[   52.033270]  [<ffffffff8155d247>] __dst_free+0x57/0xf0
[   52.033277]  [<ffffffff815c96ba>] free_fib_info_rcu+0x18a/0x220
[   52.033282]  [<ffffffff810c4897>] rcu_process_callbacks+0x1f7/0x580
[   52.033287]  [<ffffffff81066869>] ? enqueue_hrtimer+0x39/0xe0
[   52.033292]  [<ffffffff81046d60>] __do_softirq+0xc0/0x260
[   52.033296]  [<ffffffff81067939>] ? hrtimer_interrupt+0x169/0x260
[   52.033301]  [<ffffffff816d006c>] call_softirq+0x1c/0x30
[   52.033306]  [<ffffffff81004225>] do_softirq+0x55/0x90
[   52.033309]  [<ffffffff8104720e>] irq_exit+0x9e/0xc0
[   52.033313]  [<ffffffff816d07ee>] smp_apic_timer_interrupt+0x6e/0x99
[   52.033316]  [<ffffffff816cf987>] apic_timer_interrupt+0x67/0x70
[   52.033318]  <EOI>  [<ffffffff81300230>] ? intel_idle+0xf0/0x150
[   52.033326]  [<ffffffff8130020f>] ? intel_idle+0xcf/0x150
[   52.033331]  [<ffffffff814ac779>] cpuidle_enter+0x19/0x20
[   52.033335]  [<ffffffff814ace0c>] cpuidle_idle_call+0xac/0x310
[   52.033340]  [<ffffffff8100b6f5>] cpu_idle+0x85/0xd0
[   52.033345]  [<ffffffff816b65de>] start_secondary+0x21b/0x21d
[   52.033347] ---[ end trace 555e476df6e4a6f3 ]---
[   52.033357] dst_free(ffff88060816e000) refcnt 1
[   52.033359] adding dst ffff88060816e000 to garbage
[   52.033360] ------------[ cut here ]------------
[   52.033363] WARNING: at net/core/dst.c:215 __dst_free+0x57/0xf0()
[   52.033365] Hardware name: HP Z600 Workstation
[   52.033366] Modules linked in: tun ip6table_filter ip6_tables ebtable_nat ebtables xt_state ipt_REJECT fuse iptable_mangle iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bridge stp nfsd auth_rpcgss exportfs nfs lockd sunrpc asix usbnet rt61pci crc_itu_t rt2x00pci rt2x00lib eeprom_93cx6 tg3 ixgbe mdio igb
[   52.033390] Pid: 0, comm: swapper/6 Tainted: G        W    3.5.0+ #764
[   52.033392] Call Trace:
[   52.033393]  <IRQ>  [<ffffffff8103de0f>] warn_slowpath_common+0x7f/0xc0
[   52.033399]  [<ffffffff8103de6a>] warn_slowpath_null+0x1a/0x20
[   52.033402]  [<ffffffff8155d247>] __dst_free+0x57/0xf0
[   52.033406]  [<ffffffff815c9740>] free_fib_info_rcu+0x210/0x220
[   52.033410]  [<ffffffff810c4897>] rcu_process_callbacks+0x1f7/0x580
[   52.033414]  [<ffffffff81066869>] ? enqueue_hrtimer+0x39/0xe0
[   52.033418]  [<ffffffff81046d60>] __do_softirq+0xc0/0x260
[   52.033421]  [<ffffffff81067939>] ? hrtimer_interrupt+0x169/0x260
[   52.033425]  [<ffffffff816d006c>] call_softirq+0x1c/0x30
[   52.033429]  [<ffffffff81004225>] do_softirq+0x55/0x90
[   52.033432]  [<ffffffff8104720e>] irq_exit+0x9e/0xc0
[   52.033436]  [<ffffffff816d07ee>] smp_apic_timer_interrupt+0x6e/0x99
[   52.033439]  [<ffffffff816cf987>] apic_timer_interrupt+0x67/0x70
[   52.033440]  <EOI>  [<ffffffff81300230>] ? intel_idle+0xf0/0x150
[   52.033447]  [<ffffffff8130020f>] ? intel_idle+0xcf/0x150
[   52.033451]  [<ffffffff814ac779>] cpuidle_enter+0x19/0x20
[   52.033455]  [<ffffffff814ace0c>] cpuidle_idle_call+0xac/0x310
[   52.033458]  [<ffffffff8100b6f5>] cpu_idle+0x85/0xd0
[   52.033462]  [<ffffffff816b65de>] start_secondary+0x21b/0x21d
[   52.033464] ---[ end trace 555e476df6e4a6f4 ]---
[   52.132982] dst_gc_task()
[   52.132986] delayed 3 performed 0
[   52.633325] IPv4: rt_free(ffff8802fee7e3c0)
[   52.633827] IPv4: rt_free(ffff8802fee7e240)
[   52.641632] IPv4: dst_free(ffff8802fee7e3c0) refcnt 0
[   52.641634] IPv4: dst_free(ffff8802fee7e240) refcnt 0
[   52.732498] dst_gc_task()
[   52.732502] delayed 3 performed 0
[   53.039739] calling rtnetlink_dev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039744] calling fib_rules_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039748] calling arp_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039751] calling ip_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039758] arp: arp_ifdown dev ffff880610bea000 refcnt 1
[   53.039762] calling fib_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039766] calling ip_mr_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039769] calling ndisc_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039772] calling ip6_route_dev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039778] calling ipv6_dev_notf msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039781] calling packet_netdev_notifier msg/val 6 data ffff880610bea000 refcnt 1->1
[   53.039785] dst_ifdown dst ffff8802fee7e000 dev ffff880610bea000 dst->dev ffff880311b33000 unreg 1 dev->refcnt 1
[   53.039788] dst_ifdown dst ffff88060816e000 dev ffff880610bea000 dst->dev ffff880311b33000 unreg 1 dev->refcnt 1
[   53.039791] dst_ifdown dst ffff88060816e0c0 dev ffff880610bea000 dst->dev ffff880610bea000 unreg 1 dev->refcnt 1
[   53.039794] calling dst_dev_notifier msg/val 6 data ffff880610bea000 refcnt 1->0
