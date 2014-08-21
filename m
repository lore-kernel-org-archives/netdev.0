From: Benjamin Block <bebl@mageta.org>
Subject: Re: BUG: lockdep (inconsistent usage) in netlink
Date: Thu, 21 Aug 2014 22:43:46 +0200
Message-ID: <53F65A02.2080503@mageta.org>
References: <20140821185209.GC25021@kalium.Speedport_W723_V_Typ_A_1_01_001>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="W42ubg0jBjkp7ddkr4UsfwftoP0KBmJE7"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org, Lan Tianyu <tianyu.lan@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821185209.GC25021@kalium.Speedport_W723_V_Typ_A_1_01_001>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--W42ubg0jBjkp7ddkr4UsfwftoP0KBmJE7
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/21/2014 08:52 PM, Benjamin Block wrote:
> Hello,
>=20
> while rebooting one of my dev-machines I stumbled over this
> lockdep-mess-up:
>=20
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> [ INFO: inconsistent lock state ]
>> 3.17.0-rc1-00001-gb83ca8c #2 Tainted: G           O =20
>> ---------------------------------
>> inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
>> swapper/0/0 [HC1[1]:SC0[0]:HE0:SE1] takes:
>>  (&(&list->lock)->rlock#3){?.-...}, at: [<ffffffff819580db>] skb_queue=
_tail+0x2b/0x60
>> {HARDIRQ-ON-W} state was registered at:
>>   [<ffffffff8111c9f7>] __lock_acquire+0x877/0x1c90
>>   [<ffffffff8111e45a>] lock_acquire+0xca/0x120
>>   [<ffffffff81afc744>] _raw_spin_lock_bh+0x44/0x80
>>   [<ffffffff819a8918>] netlink_poll+0xf8/0x1c0
>>   [<ffffffff8194e031>] sock_poll+0x161/0x190
>>   [<ffffffff81271ffb>] SyS_epoll_ctl+0x51b/0xd10
>>   [<ffffffff81afd452>] system_call_fastpath+0x16/0x1b
>> irq event stamp: 1699744
>> hardirqs last  enabled at (1699741): [<ffffffff8189b1d4>] cpuidle_ente=
r_state+0xc4/0x190
>> hardirqs last disabled at (1699742): [<ffffffff81afdfaa>] common_inter=
rupt+0x6a/0x6f
>> softirqs last  enabled at (1699744): [<ffffffff810d7fda>] _local_bh_en=
able+0x4a/0x50
>> softirqs last disabled at (1699743): [<ffffffff810d88f0>] irq_enter+0x=
30/0x70
>>
>> other info that might help us debug this:
>>  Possible unsafe locking scenario:
>>
>>        CPU0
>>        ----
>>   lock(&(&list->lock)->rlock#3);
>>   <Interrupt>
>>     lock(&(&list->lock)->rlock#3);
>>
>>  *** DEADLOCK ***
>>
>> no locks held by swapper/0/0.
>>
>> stack backtrace:
>> CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O   3.17.0-rc1-0000=
1-gb83ca8c #2
>> Hardware name: ASUS All Series/Q87T, BIOS 0216 10/16/2013
>>  ffffffff8295a5b0 ffff8802158039a8 ffffffff81af20fa 0000000000000000
>>  ffffffff822164e0 ffff880215803a08 ffffffff81aee400 0000000000000000
>>  ffffffff00000000 ffff880200000001 ffffffff8105ac0f ffffffff82d2abe0
>> Call Trace:
>>  <IRQ>  [<ffffffff81af20fa>] dump_stack+0x4e/0x68
>>  [<ffffffff81aee400>] print_usage_bug+0x1ec/0x1fd
>>  [<ffffffff8105ac0f>] ? save_stack_trace+0x2f/0x50
>>  [<ffffffff8111b600>] ? print_irq_inversion_bug+0x200/0x200
>>  [<ffffffff8111c061>] mark_lock+0x191/0x2b0
>>  [<ffffffff8111c96a>] __lock_acquire+0x7ea/0x1c90
>>  [<ffffffff8111ca94>] ? __lock_acquire+0x914/0x1c90
>>  [<ffffffff8111b600>] ? print_irq_inversion_bug+0x200/0x200
>>  [<ffffffff8111ca94>] ? __lock_acquire+0x914/0x1c90
>>  [<ffffffff8111e45a>] lock_acquire+0xca/0x120
>>  [<ffffffff819580db>] ? skb_queue_tail+0x2b/0x60
>>  [<ffffffff81afc590>] _raw_spin_lock_irqsave+0x50/0x90
>>  [<ffffffff819580db>] ? skb_queue_tail+0x2b/0x60
>>  [<ffffffff819580db>] skb_queue_tail+0x2b/0x60
>>  [<ffffffff819a774f>] __netlink_sendskb+0x21f/0x250
>>  [<ffffffff819a7d63>] netlink_broadcast_filtered+0x273/0x3b0
>>  [<ffffffff819a7ebd>] netlink_broadcast+0x1d/0x20
>>  [<ffffffff8152fb8a>] ? nla_reserve+0x2a/0x40
>>  [<ffffffff81589728>] acpi_bus_generate_netlink_event+0x160/0x178
>>  [<ffffffff815a8db9>] acpi_button_notify+0xe1/0xec
>>  [<ffffffff81580648>] acpi_device_notify+0x19/0x1b
>>  [<ffffffff81580662>] acpi_device_notify_fixed+0x18/0x1c
>>  [<ffffffff8158f039>] acpi_ev_fixed_event_detect+0xe6/0x10d
>>  [<ffffffff8159157a>] acpi_ev_sci_xrupt_handler+0x19/0x3f
>>  [<ffffffff8157c1a9>] acpi_irq+0x16/0x31
>>  [<ffffffff81131e2a>] handle_irq_event_percpu+0x6a/0x1d0
>>  [<ffffffff81131fd8>] handle_irq_event+0x48/0x70
>>  [<ffffffff8113534f>] ? handle_fasteoi_irq+0x2f/0x160
>>  [<ffffffff811353e7>] handle_fasteoi_irq+0xc7/0x160
>>  [<ffffffff8104cd94>] handle_irq+0x134/0x150
>>  [<ffffffff810f4876>] ? atomic_notifier_call_chain+0x16/0x20
>>  [<ffffffff81054dec>] ? __exit_idle+0x2c/0x30
>>  [<ffffffff81affe7e>] do_IRQ+0x5e/0x100
>>  [<ffffffff81afdfaf>] common_interrupt+0x6f/0x6f
>>  <EOI>  [<ffffffff8189b1df>] ? cpuidle_enter_state+0xcf/0x190
>>  [<ffffffff8189b1d4>] ? cpuidle_enter_state+0xc4/0x190
>>  [<ffffffff8189b387>] cpuidle_enter+0x17/0x20
>>  [<ffffffff81111ae1>] cpu_startup_entry+0x3a1/0x3c0
>>  [<ffffffff81ae92a4>] rest_init+0xc4/0xd0
>>  [<ffffffff81ae91e5>] ? rest_init+0x5/0xd0
>>  [<ffffffff825718a1>] ? ftrace_init+0xa8/0x13b
>>  [<ffffffff8255103a>] start_kernel+0x461/0x46e
>>  [<ffffffff82550939>] ? set_init_arg+0x57/0x57
>>  [<ffffffff825505af>] x86_64_start_reservations+0x2a/0x2c
>>  [<ffffffff825506ae>] x86_64_start_kernel+0xfd/0x101
>=20
> Sadly I couldn't reproduce it. This looks all to be very general
> functions and my best guess is, netlink_poll() needs to be irq-save.
> Thing is, the corresponding code is quite old and I can't really bisec
> it, because the none-reproducibility.
>

Thinking more about it.. this seems to be unlikely. More like the
acpi-irq chain should not do netlink-events still in irq-context - just
guessing here, sry :).

I tracked around a little and came up with more recent commits in that
call-chain:

commit 0bf6368ee8f25826d0645c0f7a4f17c8845356a4
	- adds acpi_bus_generate_netlink_event to the chain

Again, all other places around the chain seems quit old or unrelated.

>=20
> There is only the small ipv6-fib patch applied, I send in earlier today=

> (https://lkml.org/lkml/2014/8/21/506). This should have nothing to do
> with this here.
>=20

- Benjamin


--W42ubg0jBjkp7ddkr4UsfwftoP0KBmJE7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBAgAGBQJT9loVAAoJEEbgTgVnoy6eLecL/2WHAzOqLrEHPAJFD+oVWf9I
BjmnDs8LEGdzDLScz/JCZZmnom5nn9Vy79Mr9aTrgM8NvknD/uGbmBmKQkU1+aUy
OgrTPM1zz+omaipNUVqOuPOc5NCM7k7/xE93qCs6D9uQmnMkVGGyEJBvZolCV5j1
/OfgoK/U/FpXeZRxRmPkqu6ZzyAB4ZQHngi+fMyA1tlqrbiLKNSYbtkVWnn+OzXI
Upw5GW1pBhnGqbx+EsppD/K17tvAtv5b6z1ClTWQCYZzBR7uZoLipKRWfNst7NH8
L4rnC9i+QJBZXz4C83ld8Ix8XATD98V18/cTk+NBrE/uS+kzN8Vi9BnvMRho7cCK
cNyCPwy4rZtEnQMCwdiZ2HHFQfycSYzbC1Z2QZPqAuZdnMjr7mHXbTIXe/NYfpCR
rJR4iTs2mx7aNumEpVbrsbTsMXusC7VvdOlkwYzeRWDEvo7goDNZ3AGl+gQca3LX
GwkjIZOE4y6wS/tEQyToVSjU9praX16MFDzCr7EfEQ==
=G/eH
-----END PGP SIGNATURE-----

--W42ubg0jBjkp7ddkr4UsfwftoP0KBmJE7--
