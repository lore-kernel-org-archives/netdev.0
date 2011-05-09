From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: use batched device unregister in
 veth and macvlan
Date: Mon, 09 May 2011 22:17:31 +0200
Message-ID: <1304972251.3050.11.camel@edumazet-laptop>
References: <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
	 <1304929236.3342.8.camel@edumazet-laptop>
	 <1304932677.3342.17.camel@edumazet-laptop>
	 <20110509.114200.226765786.davem@davemloft.net>
	 <1304967935.3050.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, alex@alex.org.uk, netdev@vger.kernel.org,
	jesse@nicira.com, paulmck@linux.vnet.ibm.com,
	greearb@candelatech.com, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63864 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754372Ab1EIURj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 16:17:39 -0400
Received: by wya21 with SMTP id 21so4178068wya.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 13:17:38 -0700 (PDT)
In-Reply-To: <1304967935.3050.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 21:05 +0200, Eric Dumazet a =C3=A9crit :

> BTW, bug must be present in net-2.6, if we unload vlan module (since =
in this
> case we also had a non NULL head )

Yes, I confirm we have the bug in linux-2.6

Here eth2 provided by tg3 module

ip link add link eth2 eth2.103 type vlan id 103 gvrp on loose_binding o=
n
ip link add link eth2 eth2.104 type vlan id 104 gvrp on loose_binding o=
n
ip link set eth2.103 up
ip link set eth2.104 up
sync
sleep 5
sync
rmmod tg3

<<<BUG>>>

[ 1848.669338] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[ 1848.669388] IP: [<ffffffffa0030c9e>] garp_request_leave+0x3e/0xc0 [g=
arp]
[ 1848.669421] PGD 11d251067 PUD 11b9e0067 PMD 0=20
[ 1848.669454] Oops: 0000 [#1] SMP=20
[ 1848.669482] last sysfs file: /sys/devices/virtual/net/eth2.104/ifind=
ex
[ 1848.669512] CPU 0=20
[ 1848.669518] Modules linked in: tg3(-) 8021q garp nfsd lockd auth_rpc=
gss sunrpc libphy sg [last unloaded: x_tables]
[ 1848.669613]=20
[ 1848.669633] Pid: 11494, comm: rmmod Tainted: G        W   2.6.39-rc6=
-00261-gfd71257-dirty #580 HP ProLiant BL460c G6
[ 1848.669688] RIP: 0010:[<ffffffffa0030c9e>]  [<ffffffffa0030c9e>] gar=
p_request_leave+0x3e/0xc0 [garp]
[ 1848.669740] RSP: 0018:ffff88007a19bae8  EFLAGS: 00010286
[ 1848.669766] RAX: 0000000000000000 RBX: ffff88011b5e2000 RCX: 0000000=
000000002
[ 1848.669796] RDX: 0000000000000000 RSI: 0000000000000175 RDI: fffffff=
fa0030d5b
[ 1848.669826] RBP: ffff88007a19bb18 R08: 0000000000000001 R09: ffff880=
11bd64a00
[ 1848.669860] R10: ffff88011d34ec00 R11: 0000000000000000 R12: 0000000=
000000002
[ 1848.669890] R13: ffff88007a19bc48 R14: ffff88007a19bb88 R15: 0000000=
000000001
[ 1848.669920] FS:  0000000000000000(0000) GS:ffff88011fc00000(0063) kn=
lGS:00000000f77d76c0
[ 1848.669966] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 1848.669993] CR2: 0000000000000000 CR3: 000000011a675000 CR4: 0000000=
0000006f0
[ 1848.670023] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[ 1848.670063] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[ 1848.670115] Process rmmod (pid: 11494, threadinfo ffff88007a19a000, =
task ffff8800798595c0)
[ 1848.672098] Stack:
[ 1848.672118]  ffff88007a19bb36 ffff88011c84b800 ffff88011b5e2000 ffff=
88007a19bc48
[ 1848.672172]  ffff88007a19bb88 0000000000000006 ffff88007a19bb38 ffff=
ffffa003a5f6
[ 1848.672235]  ffff88007a19bb38 670088007a19bba8 ffff88007a19bb58 ffff=
ffffa00397e7
[ 1848.672293] Call Trace:
[ 1848.672317]  [<ffffffffa003a5f6>] vlan_gvrp_request_leave+0x46/0x50 =
[8021q]
[ 1848.672348]  [<ffffffffa00397e7>] vlan_dev_stop+0xb7/0xc0 [8021q]
[ 1848.672377]  [<ffffffff8137e427>] __dev_close_many+0x87/0xe0
[ 1848.672405]  [<ffffffff8137e507>] dev_close_many+0x87/0x110
[ 1848.672433]  [<ffffffff8137e630>] rollback_registered_many+0xa0/0x24=
0
[ 1848.672462]  [<ffffffff8137e7e9>] unregister_netdevice_many+0x19/0x6=
0
[ 1848.672492]  [<ffffffffa00389eb>] vlan_device_event+0x53b/0x550 [802=
1q]
[ 1848.672522]  [<ffffffff8143f448>] ? ip6mr_device_event+0xa8/0xd0
[ 1848.672551]  [<ffffffff81479d03>] notifier_call_chain+0x53/0x80
[ 1848.672583]  [<ffffffff81062539>] __raw_notifier_call_chain+0x9/0x10
[ 1848.672612]  [<ffffffff81062551>] raw_notifier_call_chain+0x11/0x20
[ 1848.672641]  [<ffffffff8137df82>] call_netdevice_notifiers+0x32/0x60
[ 1848.672671]  [<ffffffff8137e69f>] rollback_registered_many+0x10f/0x2=
40
[ 1848.672700]  [<ffffffff8137e85f>] rollback_registered+0x2f/0x40
[ 1848.672729]  [<ffffffff8137e8c8>] unregister_netdevice_queue+0x58/0x=
90
[ 1848.672759]  [<ffffffff8137e9eb>] unregister_netdev+0x1b/0x30
[ 1848.672788]  [<ffffffffa005d73f>] tg3_remove_one+0x6f/0x10b [tg3]



