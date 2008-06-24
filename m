From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: iw lockdep warning on wireless-testing
Date: Tue, 24 Jun 2008 10:59:15 +0200
Message-ID: <1214297955.8967.258.camel@johannes.berg>
References: <1214293174.14590.229.camel@debian.sh.intel.com>
	 (sfid-20080624_094030_856715_6751BF69)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1eNgOeETCc9LeyUU2YiT"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1214293174.14590.229.camel-F7Q/YMNgnyhhZnBKgDE8z0EOCMrvLtNR@public.gmane.org> (sfid-20080624_094030_856715_6751BF69)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-1eNgOeETCc9LeyUU2YiT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

> I begin to see below lockdep warning on wireless-testing when I use iw
> to create a monitor interface with iwl4965. Any clues?

Yeah I've seen that reported too, but I think it's in genetlink.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> [ INFO: possible circular locking dependency detected ]
> 2.6.26-rc6-wl #57
> -------------------------------------------------------
> iw/2763 is trying to acquire lock:
>  (genl_mutex){--..}, at: [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>=20
> but task is already holding lock:
>  (nlk->cb_mutex){--..}, at: [<ffffffff812137c8>] netlink_dump+0x40/0x19d
>=20
> which lock already depends on the new lock.

None of those is anything nl80211 has influence over, afaict.

>=20
> the existing dependency chain (in reverse order) is:
>=20
> -> #1 (nlk->cb_mutex){--..}:
>        [<ffffffff810518cb>] __lock_acquire+0xa4c/0xc28
>        [<ffffffff81215774>] netlink_dump_start+0xd9/0x169
>        [<ffffffff81051e5d>] lock_acquire+0x51/0x6c
>        [<ffffffff81215774>] netlink_dump_start+0xd9/0x169
>        [<ffffffff8104eab1>] debug_mutex_lock_common+0x16/0x23
>        [<ffffffff8127c622>] mutex_lock_nested+0xde/0x23f
>        [<ffffffff81215774>] netlink_dump_start+0xd9/0x169
>        [<ffffffff81216d7e>] genl_rcv_msg+0xae/0x14b
>        [<ffffffff8127c774>] mutex_lock_nested+0x230/0x23f
>        [<ffffffff81216cd0>] genl_rcv_msg+0x0/0x14b
>        [<ffffffff8121483a>] netlink_rcv_skb+0x34/0x7c
>        [<ffffffff81216fe1>] genl_rcv+0x21/0x30
>        [<ffffffff812145ec>] netlink_unicast+0x1f7/0x287
>        [<ffffffff811f7eb7>] __alloc_skb+0x84/0x132
>        [<ffffffff81214d60>] netlink_sendmsg+0x274/0x287
>        [<ffffffff811f1b49>] sock_sendmsg+0xe2/0xff
>        [<ffffffff8104582f>] autoremove_wake_function+0x0/0x2e
>        [<ffffffff81050878>] mark_held_locks+0x49/0x67
>        [<ffffffff811f1d7d>] sys_sendmsg+0x217/0x28a
>        [<ffffffff8107de49>] __do_fault+0x35d/0x3a5
>        [<ffffffff8100bf10>] tracesys+0xd5/0xda
>        [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> -> #0 (genl_mutex){--..}:
>        [<ffffffff81050226>] print_circular_bug_header+0xc8/0xcf
>        [<ffffffff810517d0>] __lock_acquire+0x951/0xc28
>        [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>        [<ffffffff81051e5d>] lock_acquire+0x51/0x6c
>        [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>        [<ffffffff8104eab1>] debug_mutex_lock_common+0x16/0x23
>        [<ffffffff8127c622>] mutex_lock_nested+0xde/0x23f
>        [<ffffffff81050a10>] trace_hardirqs_on+0xf3/0x117
>        [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>        [<ffffffff812137e3>] netlink_dump+0x5b/0x19d
>        [<ffffffff81214ef3>] netlink_recvmsg+0x180/0x2a8
>        [<ffffffff811f1a48>] sock_recvmsg+0xf0/0x10f
>        [<ffffffff8104582f>] autoremove_wake_function+0x0/0x2e
>        [<ffffffff81050878>] mark_held_locks+0x49/0x67
>        [<ffffffff811f295c>] sys_recvmsg+0x15c/0x254
>        [<ffffffff81067ac3>] audit_syscall_entry+0x12d/0x160
>        [<ffffffff8127d6da>] trace_hardirqs_on_thunk+0x35/0x3a
>        [<ffffffff8100bf10>] tracesys+0xd5/0xda
>        [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> other info that might help us debug this:
>=20
> 1 lock held by iw/2763:
>  #0:  (nlk->cb_mutex){--..}, at: [<ffffffff812137c8>] netlink_dump
> +0x40/0x19d
>=20
> stack backtrace:
> Pid: 2763, comm: iw Not tainted 2.6.26-rc6-wl #57
>=20
> Call Trace:
>  [<ffffffff8104fe63>] print_circular_bug_tail+0x69/0x72
>  [<ffffffff81050226>] print_circular_bug_header+0xc8/0xcf
>  [<ffffffff810517d0>] __lock_acquire+0x951/0xc28
>  [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>  [<ffffffff81051e5d>] lock_acquire+0x51/0x6c
>  [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>  [<ffffffff8104eab1>] debug_mutex_lock_common+0x16/0x23
>  [<ffffffff8127c622>] mutex_lock_nested+0xde/0x23f
>  [<ffffffff81050a10>] trace_hardirqs_on+0xf3/0x117
>  [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
>  [<ffffffff812137e3>] netlink_dump+0x5b/0x19d
>  [<ffffffff81214ef3>] netlink_recvmsg+0x180/0x2a8
>  [<ffffffff811f1a48>] sock_recvmsg+0xf0/0x10f
>  [<ffffffff8104582f>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff81050878>] mark_held_locks+0x49/0x67
>  [<ffffffff811f295c>] sys_recvmsg+0x15c/0x254
>  [<ffffffff81067ac3>] audit_syscall_entry+0x12d/0x160
>  [<ffffffff8127d6da>] trace_hardirqs_on_thunk+0x35/0x3a
>  [<ffffffff8100bf10>] tracesys+0xd5/0xda
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless"=
 in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=-1eNgOeETCc9LeyUU2YiT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIYLdfAAoJEKVg1VMiehFY/64P/i3aLRylN5q9z/Aif/xf9Nw0
ToZrNvROfzG5+ChRvDFGHq7JlCYdSMflPMoj6yBYxa0bgFo9QwIbRgZEqJASFq6n
Ti5KeoMD3FBwYRQZcGOtxlnkGn5gkqdpNOMqBW9iYJUjpWlPnG8ZdW2XnbJO994b
nSlYTgUdNmGWKLF/7tVQ+2Kpy+qPnsM0qDXZ6CXwwsRCko2THuKk/TCd/OYyHtVu
oyxtVZ4EOcnTHpoIHGadUyyZ6SYizzC9EicKPW6UjrGR6WdmWyPoNBdvpxBXHe31
G16AfkRgGNOsOzeVGJ6iVqd3LW/a18ZMyKInfnRArIE64EKCvMLxAnvm3DJgucT+
jbD5u/n1zKm6+S6BpvTT2qfGiiXet6/pbfgZv1LgaG1Rj9i9isOXUg/tXBPuMYJn
b6xSEYaMr1hpvi+04EgFU0ZfEvaphKVwY4fd7VQYOSQ6nkjayqzuVf/eouYMegxB
hUHSuL9S3CO1bRkVmYUZ9mCUaAOdKTxH3az0+z/Nva3yavoxZIlJV/zRLWA3Df2j
eTFhZLSFnhybCM8xqWJ07QC4Ee4d/No9iLMSLfcL+6xd2Q+1mv4Cp//vZUK6MMrO
e1APnTDsNDW1zFoJFe4MdFG0ytga5kCukYFVhTC77GT1B3/B/Vbz1EYW02x77xFv
fMl2ZyvVYi+nCatn+F1W
=BpJG
-----END PGP SIGNATURE-----

--=-1eNgOeETCc9LeyUU2YiT--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
