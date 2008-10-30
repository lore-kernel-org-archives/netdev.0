From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: UDP/bnx2: inconsistent lock state (Re: linux-next: Tree for October
 30)
Date: Thu, 30 Oct 2008 14:21:29 +0100
Message-ID: <4909B4D9.20807@cosmosbay.com>
References: <a4423d670810300340i27cd7fe3wea42767431ad3574@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406080100080809030805"
Cc: mchan@broadcom.com, linux-next@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48023 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbYJ3NVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 09:21:47 -0400
In-Reply-To: <a4423d670810300340i27cd7fe3wea42767431ad3574@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070406080100080809030805
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

Alexander Beregalov a =C3=A9crit :
> bnx2 0000:03:00.0: irq 38 for MSI/MSI-X
> bnx2: eth0: using MSI
> bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive &
> transmit flow control ON
>=20
> [ INFO: inconsistent lock state ]
> 2.6.28-rc2-next-20081030 #4
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  (&table->hash[i].lock){-+..}, at: [<ffffffff804ea8c5>]
> __udp4_lib_rcv+0x2a5/0x640
> {softirq-on-W} state was registered at:
>   [<ffffffff80257ea0>] __lock_acquire+0x2fd/0xc72
>   [<ffffffff8025889a>] lock_acquire+0x85/0xa9
>   [<ffffffff80525527>] _spin_lock+0x3c/0x70
>   [<ffffffff804eaca2>] udp_lib_unhash+0x2b/0x90
>   [<ffffffff804ab315>] sk_common_release+0x2f/0x83
>   [<ffffffff804e9631>] udp_lib_close+0x9/0xb
>   [<ffffffff804f1274>] inet_release+0x58/0x5f
>   [<ffffffff804a889e>] sock_release+0x20/0xc1
>   [<ffffffff804a8973>] sock_close+0x34/0x3a
>   [<ffffffff8029e8ee>] __fput+0xc5/0x164
>   [<ffffffff8029e9a2>] fput+0x15/0x17
>   [<ffffffff8029be90>] filp_close+0x67/0x72
>   [<ffffffff8023864a>] put_files_struct+0x74/0xc8
>   [<ffffffff802386e5>] exit_files+0x47/0x4f
>   [<ffffffff80239f28>] do_exit+0x27a/0x8b7
>   [<ffffffff8023a5e4>] do_group_exit+0x7f/0xaf
>   [<ffffffff8023a626>] sys_exit_group+0x12/0x14
>   [<ffffffff8020b6fb>] system_call_fastpath+0x16/0x1b
>   [<ffffffffffffffff>] 0xffffffffffffffff
> irq event stamp: 56806
> hardirqs last  enabled at (56806): [<ffffffff8023bf15>]
> _local_bh_enable_ip+0xba/0xe3
> hardirqs last disabled at (56805): [<ffffffff8023beaf>]
> _local_bh_enable_ip+0x54/0xe3
> softirqs last  enabled at (56786): [<ffffffff8023c0ec>] __do_softirq+0x=
f8/0x104
> softirqs last disabled at (56791): [<ffffffff8020cbac>] call_softirq+0x=
1c/0x28
>=20
> other info that might help us debug this:
> no locks held by swapper/0.
>=20
> stack backtrace:
> Pid: 0, comm: swapper Not tainted 2.6.28-rc2-next-20081030 #4
> Call Trace:
>  <IRQ>  [<ffffffff80256a9c>] valid_state+0x179/0x18c
>  [<ffffffff80256fda>] mark_lock+0x14d/0x37a
>  [<ffffffff80257e25>] __lock_acquire+0x282/0xc72
>  [<ffffffff804c9a91>] ? rt_intern_hash+0x442/0x45c
>  [<ffffffff8023bf47>] ? local_bh_enable_ip+0x9/0xb
>  [<ffffffff8025889a>] lock_acquire+0x85/0xa9
>  [<ffffffff804ea8c5>] ? __udp4_lib_rcv+0x2a5/0x640
>  [<ffffffff80525527>] _spin_lock+0x3c/0x70
>  [<ffffffff804ea8c5>] ? __udp4_lib_rcv+0x2a5/0x640
>  [<ffffffff804ea8c5>] __udp4_lib_rcv+0x2a5/0x640
>  [<ffffffff804eac75>] udp_rcv+0x15/0x17
>  [<ffffffff804cc1ec>] ip_local_deliver+0xad/0x13d
>  [<ffffffff804cc107>] ip_rcv+0x4b7/0x4ef
>  [<ffffffff804b3efb>] netif_receive_skb+0x213/0x23a
>  [<ffffffff8042fa7c>] bnx2_poll_work+0x92e/0xaa5
>  [<ffffffff8024f935>] ? getnstimeofday+0x3a/0x96
>  [<ffffffff8025011e>] ? do_settimeofday+0x7f/0x131
>  [<ffffffff8025001e>] ? update_wall_time+0x38e/0x40f
>  [<ffffffff80256ea9>] ? mark_lock+0x1c/0x37a
>  [<ffffffff802694f4>] ? __rcu_read_lock+0xa0/0xaf
>  [<ffffffff8042fe41>] bnx2_poll+0x128/0x20d
>  [<ffffffff804b2935>] net_rx_action+0xd2/0x1f4
>  [<ffffffff8023c064>] __do_softirq+0x70/0x104
>  [<ffffffff8020cbac>] call_softirq+0x1c/0x28
>  [<ffffffff8020e1d5>] do_softirq+0x39/0x8a
>  [<ffffffff8023bc89>] irq_exit+0x45/0xa2
>  [<ffffffff8020e4e6>] do_IRQ+0x16a/0x19c
>  [<ffffffff8020bc8b>] ret_from_intr+0x0/0xf
>  <EOI>  [<ffffffff80212d69>] ? mwait_idle+0x3e/0x48
>  [<ffffffff80212d60>] ? mwait_idle+0x35/0x48
>  [<ffffffff8020a8db>] ? cpu_idle+0x59/0xc2
>  [<ffffffff8051feb4>] ? start_secondary+0x263/0x26b

Thanks for the report Alexander

We need to use spin_lock_bh()/spin_unlock_bh() in udp_lib_unhash()

Previous code was doing a write_lock_bh()/write_unlock_bh(), I cannot
believe I missed this obvious thing...

[PATCH] udp: Should use spin_lock_bh()/spin_unlock_bh() in udp_lib_unhash=
()

Spotted by Alexander Beregalov

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------070406080100080809030805
Content-Type: text/plain;
 name="udp_lib_unhash.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="udp_lib_unhash.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3VkcC5jIGIvbmV0L2lwdjQvdWRwLmMKaW5kZXggYzNl
Y2VjOC4uZjc2MGI4NiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdWRwLmMKKysrIGIvbmV0L2lw
djQvdWRwLmMKQEAgLTk3MCwxMiArOTcwLDEyIEBAIHZvaWQgdWRwX2xpYl91bmhhc2goc3Ry
dWN0IHNvY2sgKnNrKQogCXVuc2lnbmVkIGludCBoYXNoID0gdWRwX2hhc2hmbihzb2NrX25l
dChzayksIHNrLT5za19oYXNoKTsKIAlzdHJ1Y3QgdWRwX2hzbG90ICpoc2xvdCA9ICZ1ZHB0
YWJsZS0+aGFzaFtoYXNoXTsKIAotCXNwaW5fbG9jaygmaHNsb3QtPmxvY2spOworCXNwaW5f
bG9ja19iaCgmaHNsb3QtPmxvY2spOwogCWlmIChza19kZWxfbm9kZV9pbml0X3JjdShzaykp
IHsKIAkJaW5ldF9zayhzayktPm51bSA9IDA7CiAJCXNvY2tfcHJvdF9pbnVzZV9hZGQoc29j
a19uZXQoc2spLCBzay0+c2tfcHJvdCwgLTEpOwogCX0KLQlzcGluX3VubG9jaygmaHNsb3Qt
PmxvY2spOworCXNwaW5fdW5sb2NrX2JoKCZoc2xvdC0+bG9jayk7CiB9CiBFWFBPUlRfU1lN
Qk9MKHVkcF9saWJfdW5oYXNoKTsKIAo=
--------------070406080100080809030805--
