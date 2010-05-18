From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic
Date: Tue, 18 May 2010 07:49:54 +0200
Message-ID: <1274161794.2567.33.camel@edumazet-laptop>
References: <4BF21646.60008@gmail.com> <4BF21BD3.60901@gmail.com>
	 <4BF21DAD.6050609@gmail.com> <1274159136.2567.24.camel@edumazet-laptop>
	 <4BF222C8.6000200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Justin P. Mattock" <justinmattock@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Bart De Schuymer <bdschuym@pandora.be>
To: senthilkumaar2021 <senthilkumaar2021@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34835 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755826Ab0ERFt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:49:58 -0400
Received: by wwi17 with SMTP id 17so211399wwi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 22:49:56 -0700 (PDT)
In-Reply-To: <4BF222C8.6000200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 mai 2010 =C3=A0 10:46 +0530, senthilkumaar2021 a =C3=A9crit=
 :
> Hi
>=20
> thanks fro the reply
>=20
> i was able to capture only part of the message
>=20
> Machine was running squid 2.7stable6 with tproxy4
> in bridge mode on Linux kernel 2.6.28.5 and the server had
>  kernel panic for every 10 to 12 hours. The logged error:
>=20
>     [<ffffffffa0152a4b>] bnx2_poll_work+0xea0/0xfb9 [bnx2]
>     [<ffffffff81029713>] enqueue_task+0x50/0x5b
>     [<ffffffff8104d2ab>] getnstimeofday+0x53/0xb2
>    [<ffffffffa0152f31>] bnx2_poll+0xd1/0x1ae [bnx2]
>      [<ffffffff8120724a>] net_rx_action+0x9d/0x158
>      [<ffffffff8103af44>] __do_softirq+0x7a/0x13d
>      [<ffffffffa0151b6e>] bnx2_msi+0x40/0x47 [bnx2]
>      [<ffffffff8100cf5c>] call_softirq+0x1c/0x28
>      [<ffffffff8100ddc0>] do_softirq+0x2c/0x68
>      [<ffffffff8103ae84>] irq_exit+0x3f/0x85
>      [<ffffffff8100e06f>] do_IRQ+0x14a/0x16b
>     [<ffffffff8100c216>] ret_from_intr+0x0/0xa
>     <EOI> <0> [<ffffffff81174711>] acpi_idle_enter_bm+0x2a3/0x30e
>     [<ffffffff81174707>] acpi_idle_enter_bm+0x299/0x30e
>    [<ffffffff8106bac3>] rcu_needs_cpu+0x35/0x44
>     [<ffffffff811e8269>] cpuidle_idle_call+0x7f/0xbe
>      [<ffffffff8100abd4>] cpu_idle+0x4a/0x6d
>     Code: 5e 5b 5d 31 c0 c3 41 55 41 54 55 53 48 89 fb 48 83 ec 68 4c=
 8b
>      a7 98 00 00
>     00 4c 8b 6f 20 48 8b b7 d0 00 00 00 8b 8f bc 00 00 00 <41> f6 44 =
24
>      18 01 74 12
>      8a 47 7d 83 e0 f8 83 c8 03 88 47 7d 41
>     RIP [<ffffffffa02c405f>] br_nf_pre_routing_finish+0x25/0x2af [bri=
dge]
>     RSP <ffffffff8155fb40>
>     CR2: 0000000000000018
>     Kernel panic - not syncing: Fatal exception in interrupt
>=20
>  The kernel panic occurred in CentOS as well as Fedora 8 64 bit.
>=20
>  When we checked this with squid community, they replied it as the
>  problem of the Network Card. When the NIC was changed to Intel from
>  Broadcom, RAM replaced with new sets and kernel updated to 2.6.30.5,=
 the
>  find it attached). This happens once in two days. We have been tryin=
g to
>  resolve this for over 3 weeks now but in vain, any help on this is m=
uch
>  appreciated.
>=20
>  hardware detail_
>=20
>  CPU : 3.0 GHz
> RAM : 4 GB RAM
>  HDD : 4 x 150 GB
>=20
>  OS : Fedora 8 64 bit
>  FS : ReiserFS
> Max request rate : 400 per second

You could try to adapt commit e94c67436e

Maybe its same problem...

commit e94c67436efa22af7d8b7d19c885863246042543
Author: Bart De Schuymer <bdschuym@pandora.be>
Date:   Thu May 13 14:55:34 2010 +0200

    netfilter: bridge-netfilter: fix crash in br_nf_forward_finish()
   =20
    [ 4593.956206] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000018
    [ 4593.956219] IP: [<ffffffffa03357a4>] br_nf_forward_finish+0x154/=
0x170 [bridge]
    [ 4593.956232] PGD 195ece067 PUD 1ba005067 PMD 0
    [ 4593.956241] Oops: 0000 [#1] SMP
    [ 4593.956248] last sysfs file:
    /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:08/ATK0110:0=
0/hwmon/hwmon0/temp2_label
    [ 4593.956253] CPU 3
    ...
    [ 4593.956380] Pid: 29512, comm: kvm Not tainted 2.6.34-rc7-net #19=
5 P6T DELUXE/System Product Name
    [ 4593.956384] RIP: 0010:[<ffffffffa03357a4>]  [<ffffffffa03357a4>]=
 br_nf_forward_finish+0x154/0x170 [bridge]
    [ 4593.956395] RSP: 0018:ffff880001e63b78  EFLAGS: 00010246
    [ 4593.956399] RAX: 0000000000000608 RBX: ffff880057181700 RCX: fff=
f8801b813d000
    [ 4593.956402] RDX: 0000000000000000 RSI: 0000000000000002 RDI: fff=
f880057181700
    [ 4593.956406] RBP: ffff880001e63ba8 R08: ffff8801b9d97000 R09: fff=
fffffa0335650
    [ 4593.956410] R10: 0000000000000000 R11: 0000000000000000 R12: fff=
f8801b813d000
    [ 4593.956413] R13: ffffffff81ab3940 R14: ffff880057181700 R15: 000=
0000000000002
    [ 4593.956418] FS:  00007fc40d380710(0000) GS:ffff880001e60000(0000=
) knlGS:0000000000000000
    [ 4593.956422] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
    [ 4593.956426] CR2: 0000000000000018 CR3: 00000001ba1d7000 CR4: 000=
00000000026e0
    [ 4593.956429] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
    [ 4593.956433] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
    [ 4593.956437] Process kvm (pid: 29512, threadinfo ffff8801ba566000=
, task ffff8801b8003870)
    [ 4593.956441] Stack:
    [ 4593.956443]  0000000100000020 ffff880001e63ba0 ffff880001e63ba0 =
ffff880057181700
    [ 4593.956451] <0> ffffffffa0335650 ffffffff81ab3940 ffff880001e63b=
d8 ffffffffa03350e6
    [ 4593.956462] <0> ffff880001e63c40 000000000000024d ffff8800571817=
00 0000000080000000
    [ 4593.956474] Call Trace:
    [ 4593.956478]  <IRQ>
    [ 4593.956488]  [<ffffffffa0335650>] ? br_nf_forward_finish+0x0/0x1=
70 [bridge]
    [ 4593.956496]  [<ffffffffa03350e6>] NF_HOOK_THRESH+0x56/0x60 [brid=
ge]
    [ 4593.956504]  [<ffffffffa0335282>] br_nf_forward_arp+0x112/0x120 =
[bridge]
    [ 4593.956511]  [<ffffffff813f7184>] nf_iterate+0x64/0xa0
    [ 4593.956519]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [=
bridge]
    [ 4593.956524]  [<ffffffff813f722c>] nf_hook_slow+0x6c/0x100
    [ 4593.956531]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [=
bridge]
    [ 4593.956538]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridg=
e]
    [ 4593.956545]  [<ffffffffa032f86d>] __br_forward+0x6d/0xc0 [bridge=
]
    [ 4593.956550]  [<ffffffff813c5d8e>] ? skb_clone+0x3e/0x70
    [ 4593.956557]  [<ffffffffa032f462>] deliver_clone+0x32/0x60 [bridg=
e]
    [ 4593.956564]  [<ffffffffa032f6b6>] br_flood+0xa6/0xe0 [bridge]
    [ 4593.956571]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridg=
e]
   =20
    Don't call nf_bridge_update_protocol() for ARP traffic as skb->nf_b=
ridge isn't
    used in the ARP case.
   =20
    Reported-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 93f80fe..4442099 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -643,10 +643,10 @@ static int br_nf_forward_finish(struct sk_buff *s=
kb)
 			skb->pkt_type =3D PACKET_OTHERHOST;
 			nf_bridge->mask ^=3D BRNF_PKT_TYPE;
 		}
+		nf_bridge_update_protocol(skb);
 	} else {
 		in =3D *((struct net_device **)(skb->cb));
 	}
-	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
=20
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,


