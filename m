From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (3961)
Date: Thu, 30 Jul 2009 12:08:53 +0200
Message-ID: <20090730100853.GB3686@psychotron.englab.brq.redhat.com>
References: <Pine.SOC.4.64.0907301114150.10041@math.ut.ee> <4A71630A.9080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Meelis Roos <mroos@linux.ee>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43115 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbZG3KJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 06:09:04 -0400
Content-Disposition: inline
In-Reply-To: <4A71630A.9080105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 30, 2009 at 11:08:26AM CEST, eric.dumazet@gmail.com wrote:
>Meelis Roos a =E9crit :
>> I'm running 2.6.31-rc4 on an i386 pc and got these two similar=20
>> but different in cause assertion failures  on boot. Seems to be=20
>> repeatable. I saw similar messages on a kernel around -rc3 but it ha=
d=20
>> SIT troubles so I did not test more earlier rc-s.
>>=20
>> This seems to be VLAN+IPv6 related, so some more info on the=20
>> configurartion:
>>=20
>> eth0 is plain ethernet, internal LAN, IPv6 address autoconfigured fr=
om=20
>> external 6to4 address.
>>=20
>> eth1 is ethernet, external interface. Dynamic IPv4, 6to4 tunnel is=20
>> created automatically from it. Only link-local IPv6 on this=20
>> interface. This is untagged, but it also carries VLAN 4 tagged.
>>=20
>> eth1.4 is the VLAN on eth1 that carries iptv. Dynamic IPv4, only=20
>> link-local IPv6.
>>=20
>> eth2 is plain internal LAN, like eth0 - static IPv4, IPv6 from 6to4.
>>=20
>> tun6to4 is sti tunnel for 6to4, cofigured from eth1's IP.
>>=20
>> eth0 and eth1 are 8139too, eth2 is uli526x.
>>=20
>> RTNL: assertion failed at net/core/dev.c (3961)
>> Pid: 0, comm: swapper Not tainted 2.6.31-rc4 #327
>> Call Trace:
>>  [<c127fd2b>] ? printk+0x1d/0x32
>>  [<c120c43c>] dev_unicast_sync+0x3b/0xfe
>>  [<f8a0b19d>] vlan_dev_set_rx_mode+0x2f/0x45 [8021q]
>>  [<c120bab5>] __dev_set_rx_mode+0x88/0x9e
>>  [<c1211c48>] dev_mc_add+0x52/0x7c
>>  [<f890d5d1>] igmp6_group_added+0x5e/0x160 [ipv6]
>>  [<f8900923>] ? fib6_clean_node+0x0/0x9f [ipv6]
>>  [<f890d9e6>] ipv6_dev_mc_inc+0x2b9/0x2dc [ipv6]
>>  [<f88f6745>] addrconf_join_solict+0x43/0x56 [ipv6]
>>  [<f88f197d>] ipv6_dev_ac_inc+0x15c/0x1ab [ipv6]
>>  [<f88f5f55>] addrconf_join_anycast+0x82/0x9b [ipv6]
>>  [<f88f75b4>] __ipv6_ifa_notify+0xd6/0x153 [ipv6]
>>  [<f88f8584>] ? addrconf_dad_timer+0x0/0x120 [ipv6]
>>  [<f88f7662>] ipv6_ifa_notify+0x31/0x4c [ipv6]
>>  [<f88f76a3>] addrconf_dad_completed+0x26/0xb7 [ipv6]
>>  [<f88f8607>] addrconf_dad_timer+0x83/0x120 [ipv6]
>>  [<f89fd942>] ? garp_join_timer+0x0/0x79 [garp]
>>  [<f89fd9a5>] ? garp_join_timer+0x63/0x79 [garp]
>>  [<c102dbff>] run_timer_softirq+0x152/0x1ca
>>  [<c1029b9b>] __do_softirq+0x69/0xe6
>>  [<c1029b32>] ? __do_softirq+0x0/0xe6
>>  <IRQ>  [<c10298a2>] ? irq_exit+0x36/0x7b
>>  [<c1012a71>] ? smp_apic_timer_interrupt+0x70/0x8c
>>  [<c10032a1>] ? apic_timer_interrupt+0x31/0x38
>>  [<c1008b67>] ? default_idle+0x36/0x5c
>>  [<c1001cbb>] ? cpu_idle+0x72/0x9f
>>  [<c1278d08>] ? rest_init+0x74/0x87
>>  [<c13c9af9>] ? start_kernel+0x278/0x28e
>>  [<c13c9312>] ? i386_start_kernel+0x40/0x56
>> ADDRCONF(NETDEV_UP): eth2: link is not ready
>> powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3000+ processors (1=
 cpu=20
>> cores) (version 2.20.00)
>> powernow-k8:    0 : fid 0xa (1800 MHz), vid 0x6
>> powernow-k8:    1 : fid 0x2 (1000 MHz), vid 0x12
>> Marking TSC unstable due to cpufreq changes
>> RTNL: assertion failed at net/core/dev.c (3961)
>> Pid: 2744, comm: avahi-daemon Not tainted 2.6.31-rc4 #327
>> Call Trace:
>>  [<c127fd2b>] ? printk+0x1d/0x32
>>  [<c120c43c>] dev_unicast_sync+0x3b/0xfe
>>  [<f8a0b19d>] vlan_dev_set_rx_mode+0x2f/0x45 [8021q]
>>  [<c120bab5>] __dev_set_rx_mode+0x88/0x9e
>>  [<c1211c48>] dev_mc_add+0x52/0x7c
>>  [<f890d5d1>] igmp6_group_added+0x5e/0x160 [ipv6]
>>  [<c1202560>] ? sock_alloc_send_pskb+0x9c/0x267
>>  [<f890d9e6>] ipv6_dev_mc_inc+0x2b9/0x2dc [ipv6]
>>  [<f890eb15>] ipv6_sock_mc_join+0x15d/0x1ce [ipv6]
>>  [<f8902565>] do_ipv6_setsockopt+0x8a7/0xc2e [ipv6]
>>  [<c11ff715>] ? sock_recvmsg+0xdf/0x108
>>  [<c11ff877>] ? sock_sendmsg+0xd8/0x100
>>  [<c10384fe>] ? autoremove_wake_function+0x0/0x54
>>  [<c108eb47>] ? file_update_time+0x9e/0xd0
>>  [<c11ffba2>] ? sys_sendto+0x10d/0x146
>>  [<f890293f>] ipv6_setsockopt+0x53/0xb0 [ipv6]
>>  [<f8905951>] udpv6_setsockopt+0x4c/0x67 [ipv6]
>>  [<c1201262>] sock_common_setsockopt+0x22/0x38
>>  [<c11ff150>] sys_setsockopt+0x79/0xa8
>>  [<c1200cd1>] sys_socketcall+0x129/0x18a
>>  [<c1002bbb>] sysenter_do_call+0x12/0x26
>>=20
>>=20
>
>Thanks for your detailed report Meelis
>
>Seems because of following commit.
>
>So assumption that dev_unicast_sync() is always called with RTNL is cu=
rrently
>false.

Right, apparently I missed this path (called from dev_mcast.c which cou=
ld not be
rtnl protected). I'll make a patch to add the original spin lock protec=
tion.

Jirka
>
>
>commit ccffad25b5136958d4769ed6de5e87992dd9c65c
>Author: Jiri Pirko <jpirko@redhat.com>
>Date:   Fri May 22 23:22:17 2009 +0000
>
>    net: convert unicast addr list
>
>    This patch converts unicast address list to standard list_head usi=
ng
>    previously introduced struct netdev_hw_addr. It also relaxes the
>    locking. Original spinlock (still used for multicast addresses) is=
 not
>    needed and is no longer used for a protection of this list. All
>    reading and writing takes place under rtnl (with no changes).
>
>    I also removed a possibility to specify the length of the address
>    while adding or deleting unicast address. It's always dev->addr_le=
n.
>
>    The convertion touched especially e1000 and ixgbe codes when the
>    change is not so trivial.
>
>    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
