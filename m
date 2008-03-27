From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 08:03:25 +0100
Message-ID: <47EB46BD.2080001@cosmosbay.com>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: denys@visp.net.lb, netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080326.234049.256533912.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: "Denys Fedoryshchenko" <denys@visp.net.lb>
> Date: Thu, 27 Mar 2008 08:35:06 +0200
>=20
>> It seems i am having very bad luck with 2.6.27. As Linus told, it ha=
ve to be=20
>> released soon, but it is crashing like hell on high network load.
>=20
> That's amazing, you've taken a trip into the future and are running
> 2.6.27 already, please let me borrow your time machine :-)
>=20
> More seriously, there is obviously something very unique to your
> setup or else everyone would be reporting this crash, and we have
> to find out what that might be.
>=20
> There seems to be bunch of netfilter stuff in your traces, but
> the top of the trace is somewhere totally unrelated.  This is
> a common reoccurance in your crash traces, making them less
> useful than they could be.
>=20
> I know you asked before what can be done to improve the traces,
> but I'm not an x86 expert so I have no idea how to help you
> in that area.
>=20
> Patrick, could you see if you can make any sense of his log?
> I see conttrack a lot in the backtraces.

I can see rt_garbage_collect() involved here. This one might explain ve=
ry long=20
delays in softirq processing, and eventually crashes...

Denys, could you post :

grep . /proc/sys/net/ipv4/route/*

rtstat -c1 -i10

So that we can check if you should first change route cache tunables :)

>=20
> Thanks.
>=20
>> Here is a message i got over syslog on last crash (it was 2.6.25-rc6=
-git6),=20
>> available also at http://www.nuclearcat.com/files/crash_2.6.25.txt
>>
>> Mar 26 02:27:14 ROUTER [ 4698.694693] BUG: NMI Watchdog detected LOC=
KUP
>> Mar 26 02:27:14 ROUTER on CPU1, ip c02ad109, registers:
>> Mar 26 02:27:14 ROUTER [ 4698.694693] Process snmpd (pid: 2327, ti=3D=
c092e000=20
>> task=3Df7459080 task.ti=3Df70b7000)
>> Mar 26 02:27:14 ROUTER=20
>> Mar 26 02:27:14 ROUTER [ 4698.694693] Stack:=20
>> Mar 26 02:27:14 ROUTER c092eb14=20
>> Mar 26 02:27:14 ROUTER c011991e=20
>> Mar 26 02:27:14 ROUTER f750d600=20
>> Mar 26 02:27:14 ROUTER f750d600=20
>> Mar 26 02:27:14 ROUTER c0378058=20
>> Mar 26 02:27:14 ROUTER 00000001=20
>> Mar 26 02:27:14 ROUTER c092eb34=20
>> Mar 26 02:27:14 ROUTER c0119b3b=20
>> Mar 26 02:27:14 ROUTER=20
>> Mar 26 02:27:14 ROUTER [ 4698.694693]       =20
>> Mar 26 02:27:14 ROUTER 00000000=20
>> Mar 26 02:27:14 ROUTER 00000001=20
>> Mar 26 02:27:14 ROUTER 00000082=20
>> Mar 26 02:27:14 ROUTER f708af88=20
>> Mar 26 02:27:14 ROUTER c0378058=20
>> Mar 26 02:27:14 ROUTER 00000001=20
>> Mar 26 02:27:14 ROUTER c092eb3c=20
>> Mar 26 02:27:14 ROUTER c0119bfe=20
>> Mar 26 02:27:14 ROUTER=20
>> Mar 26 02:27:14 ROUTER [ 4698.694693]       =20
>> Mar 26 02:27:14 ROUTER c092eb50=20
>> Mar 26 02:27:14 ROUTER c012f19c=20
>> Mar 26 02:27:14 ROUTER 00000000=20
>> Mar 26 02:27:14 ROUTER f708af88=20
>> Mar 26 02:27:14 ROUTER c0378058=20
>> Mar 26 02:27:14 ROUTER c092eb74=20
>> Mar 26 02:27:14 ROUTER c011652a=20
>> Mar 26 02:27:14 ROUTER 00000000=20
>> Mar 26 02:27:14 ROUTER=20
>> Mar 26 02:27:14 ROUTER [ 4698.694693] Call Trace:
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011991e>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER task_rq_lock+0x31/0x58
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119b3b>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER try_to_wake_up+0x19/0xd1
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119bfe>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER default_wake_function+0xb/0xd
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c012f19c>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER autoremove_wake_function+0xf/0x33
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011652a>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER __wake_up_common+0x2f/0x5a
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01189b8>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER __wake_up+0x28/0x3b
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01201a3>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER wake_up_klogd+0x2e/0x31
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c012033d>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER release_console_sem+0x197/0x19f
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0120747>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER vprintk+0x295/0x2e5
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f899634c>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER death_by_timeout+0x8b/0xa3 [nf_conntrack]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8999d08>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER tcp_packet+0x931/0x9e5 [nf_conntrack]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01207ac>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER printk+0x15/0x17
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011fb65>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER warn_on_slowpath+0x2a/0x51
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011764a>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER __update_rq_clock+0x1c/0x126
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0116ab3>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER update_curr+0x48/0x64
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f89961ed>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER nf_ct_invert_tuple+0x63/0x6f [nf_conntrack]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8996cca>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER nf_conntrack_tuple_taken+0xf8/0x100 [nf_connt=
rack]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f899850c>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER __nf_ct_helper_find+0x2c/0x90 [nf_conntrack]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8996b95>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER nf_conntrack_alter_reply+0x4a/0x87 [nf_conntr=
ack]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8974976>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER nf_nat_setup_info+0x3cc/0x55a [nf_nat]
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011701c>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER dequeue_rt_entity+0x88/0x171
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0117127>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER dequeue_rt_stack+0x22/0x27
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0117425>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER enqueue_task_rt+0x19/0x2c
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011617f>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER enqueue_task+0xd/0x18
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01161c0>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER activate_task+0x1e/0x2b
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119bb1>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER try_to_wake_up+0x8f/0xd1
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119c1b>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER wake_up_process+0xf/0x11
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c013dfa1>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER softlockup_tick+0x9d/0x10b
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0126f5c>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER run_local_timers+0x17/0x19
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01272fa>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER update_process_times+0x24/0x49
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0135f4c>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER tick_periodic+0x62/0x6e
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0135f71>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER tick_handle_periodic+0x19/0x68
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c010e87b>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER smp_apic_timer_interrupt+0x6c/0x81
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0104344>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER apic_timer_interrupt+0x28/0x30
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c02ad202>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER _spin_lock_bh+0x20/0x22
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c02751fa>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER rt_garbage_collect+0x132/0x27a
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0262d95>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER dst_alloc+0x19/0x63
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0276eb1>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER ip_route_input+0x6b9/0xbd9
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0278898>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER ip_rcv_finish+0x2c/0x29a
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0278ef8>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER ip_rcv+0x202/0x22c
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c025ee4e>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER netif_receive_skb+0x33e/0x3a9
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c02612c2>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER process_backlog+0x62/0xb5
>> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0260d27>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER net_rx_action+0x8f/0x191
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c01240a7>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER __do_softirq+0x64/0xcd
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0105f0a>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER do_softirq+0x55/0x89
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0123f88>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER local_bh_enable+0x61/0x6d
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0257689>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER lock_sock_nested+0x83/0x8b
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0292e58>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER udp_destroy_sock+0xd/0x20
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0257b9e>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER sk_common_release+0x15/0x60
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c02924a4>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER udp_lib_close+0x8/0xa
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0299006>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER inet_release+0x42/0x48
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c025625b>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER sock_release+0x14/0x60
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c02565d9>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER sock_close+0x29/0x30
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c015a6a2>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER __fput+0x93/0x135
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c015a8e2>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER fput+0x17/0x19
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c01583dc>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER filp_close+0x47/0x51
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0159414>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER sys_close+0x68/0x9d
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0103876>]=20
>> Mar 26 02:27:14 ROUTER ?=20
>> Mar 26 02:27:14 ROUTER sysenter_past_esp+0x5f/0x85
>> Mar 26 02:27:14 ROUTER [ 4698.694694]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> Mar 26 02:27:14 ROUTER [ 4698.694694] Code:=20
>> Mar 26 02:27:14 ROUTER 94=20
>> Mar 26 02:27:14 ROUTER c0=20
>> Mar 26 02:27:14 ROUTER 84=20
>> Mar 26 02:27:14 ROUTER c0=20
>> Mar 26 02:27:14 ROUTER b9=20
>> Mar 26 02:27:14 ROUTER 01=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 75=20
>> Mar 26 02:27:14 ROUTER 09=20
>> Mar 26 02:27:14 ROUTER f0=20
>> Mar 26 02:27:14 ROUTER 81=20
>> Mar 26 02:27:14 ROUTER 02=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 01=20
>> Mar 26 02:27:14 ROUTER 30=20
>> Mar 26 02:27:14 ROUTER c9=20
>> Mar 26 02:27:14 ROUTER 5d=20
>> Mar 26 02:27:14 ROUTER 89=20
>> Mar 26 02:27:14 ROUTER c8=20
>> Mar 26 02:27:14 ROUTER c3=20
>> Mar 26 02:27:14 ROUTER 55=20
>> Mar 26 02:27:14 ROUTER ba=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 01=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 89=20
>> Mar 26 02:27:14 ROUTER e5=20
>> Mar 26 02:27:14 ROUTER f0=20
>> Mar 26 02:27:14 ROUTER 66=20
>> Mar 26 02:27:14 ROUTER 0f=20
>> Mar 26 02:27:14 ROUTER c1=20
>> Mar 26 02:27:14 ROUTER 10=20
>> Mar 26 02:27:14 ROUTER 38=20
>> Mar 26 02:27:14 ROUTER f2=20
>> Mar 26 02:27:14 ROUTER 74=20
>> Mar 26 02:27:14 ROUTER 06=20
>> Mar 26 02:27:14 ROUTER f3=20
>> Mar 26 02:27:14 ROUTER 90=20
>> Mar 26 02:27:14 ROUTER unparseable log message: "<8a> "
>> Mar 26 02:27:14 ROUTER 10=20
>> Mar 26 02:27:14 ROUTER eb=20
>> Mar 26 02:27:14 ROUTER f6=20
>> Mar 26 02:27:14 ROUTER 5d=20
>> Mar 26 02:27:14 ROUTER c3=20
>> Mar 26 02:27:14 ROUTER 55=20
>> Mar 26 02:27:14 ROUTER 89=20
>> Mar 26 02:27:14 ROUTER e5=20
>> Mar 26 02:27:14 ROUTER f0=20
>> Mar 26 02:27:14 ROUTER 81=20
>> Mar 26 02:27:14 ROUTER 28=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 00=20
>> Mar 26 02:27:14 ROUTER 01=20
>> Mar 26 02:27:14 ROUTER 74=20
>> Mar 26 02:27:14 ROUTER 05=20
>> Mar 26 02:27:14 ROUTER e8=20
>> Mar 26 02:27:14 ROUTER 64=20
>> Mar 26 02:27:14 ROUTER fd=20
>> Mar 26 02:27:14 ROUTER=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
