From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Tue, 04 Sep 2012 22:42:09 +0200
Message-ID: <504667A1.3030500@pengutronix.de>
References: <20120904140411.GB15068@localhost> <5046361C.5070602@pengutronix.de> <87mx15zfze.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig017DAE3F4793A7467429F705"
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <87mx15zfze.fsf@xmission.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig017DAE3F4793A7467429F705
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/04/2012 10:32 PM, Eric W. Biederman wrote:
>>> FYI, another kconfig triggering a slightly different oops on tree
>>>
>>>         git://gitorious.org/linux-can/linux-can-next led-trigger
>>
>> This in turn means the problem doesn't come from the CAN patches, as
>> both trees have different CAN patches. I'm adding Eric W. Biederman on=

>> Cc as he contributed some sctp patches between v3.6 and net-next/maste=
r.
>=20
> Anything is possible, but this seems unlikely as I don't think I touche=
d
> anything close to that part of the code.
>=20
> This most definitely looks like a memory stomp somewhere.
>=20
> sk->inet_sk->inet_opt has a bad value.
>=20
> I am puzzled though what are we doing with both ipv4 and ipv6 release
> state doing on the same socket path?    Is this some crazy ipv6 socket
> doing sctp with only ipv4 addresses?

It's Wu's testcase, can you show us the code?
Eric, in case you haven't seen, this is another oops, from a slightly
different tree (a handfull of different CAN patches).

> [  233.046014] kfree_debugcheck: out of range ptr ea6000000bb8h.
> [  233.047399] ------------[ cut here ]------------
> [  233.048393] kernel BUG at /c/kernel-tests/src/stable/mm/slab.c:3074!=

> [  233.048393] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> [  233.048393] Modules linked in:
> [  233.048393] CPU 0=20
> [  233.048393] Pid: 3929, comm: trinity-watchdo Not tainted 3.6.0-rc3+ =
#4192 Bochs Bochs
> [  233.048393] RIP: 0010:[<ffffffff81169653>]  [<ffffffff81169653>] kfr=
ee_debugcheck+0x27/0x2d
> [  233.048393] RSP: 0018:ffff88000facbca8  EFLAGS: 00010092
> [  233.048393] RAX: 0000000000000031 RBX: 0000ea6000000bb8 RCX: 0000000=
0a189a188
> [  233.048393] RDX: 000000000000a189 RSI: ffffffff8108ad32 RDI: fffffff=
f810d30f9
> [  233.048393] RBP: ffff88000facbcb8 R08: 0000000000000002 R09: fffffff=
f843846f0
> [  233.048393] R10: ffffffff810ae37c R11: 0000000000000908 R12: 0000000=
000000202
> [  233.048393] R13: ffffffff823dbd5a R14: ffff88000ec5bea8 R15: fffffff=
f8363c780
> [  233.048393] FS:  00007faa6899c700(0000) GS:ffff88001f200000(0000) kn=
lGS:0000000000000000
> [  233.048393] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  233.048393] CR2: 00007faa6841019c CR3: 0000000012c82000 CR4: 0000000=
0000006f0
> [  233.048393] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
> [  233.048393] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
> [  233.048393] Process trinity-watchdo (pid: 3929, threadinfo ffff88000=
faca000, task ffff88000faec600)
> [  233.048393] Stack:
> [  233.048393]  0000000000000000 0000ea6000000bb8 ffff88000facbce8 ffff=
ffff8116ad81
> [  233.048393]  ffff88000ff588a0 ffff88000ff58850 ffff88000ff588a0 0000=
000000000000
> [  233.048393]  ffff88000facbd08 ffffffff823dbd5a ffffffff823dbcb0 ffff=
88000ff58850
> [  233.048393] Call Trace:
> [  233.048393]  [<ffffffff8116ad81>] kfree+0x5f/0xca
> [  233.048393]  [<ffffffff823dbd5a>] inet_sock_destruct+0xaa/0x13c
> [  233.048393]  [<ffffffff823dbcb0>] ? inet_sk_rebuild_header+0x319/0x3=
19
> [  233.048393]  [<ffffffff8231c307>] __sk_free+0x21/0x14b
> [  233.048393]  [<ffffffff8231c4bd>] sk_free+0x26/0x2a
> [  233.048393]  [<ffffffff825372db>] sctp_close+0x215/0x224
> [  233.048393]  [<ffffffff810d6835>] ? lock_release+0x16f/0x1b9
> [  233.048393]  [<ffffffff823daf12>] inet_release+0x7e/0x85
> [  233.048393]  [<ffffffff82317d15>] sock_release+0x1f/0x77
> [  233.048393]  [<ffffffff82317d94>] sock_close+0x27/0x2b
> [  233.048393]  [<ffffffff81173bbe>] __fput+0x101/0x20a
> [  233.048393]  [<ffffffff81173cd5>] ____fput+0xe/0x10
> [  233.048393]  [<ffffffff810a3794>] task_work_run+0x5d/0x75
> [  233.048393]  [<ffffffff8108da70>] do_exit+0x290/0x7f5
> [  233.048393]  [<ffffffff82707415>] ? retint_swapgs+0x13/0x1b
> [  233.048393]  [<ffffffff8108e23f>] do_group_exit+0x7b/0xba
> [  233.048393]  [<ffffffff8108e295>] sys_exit_group+0x17/0x17
> [  233.048393]  [<ffffffff8270de10>] tracesys+0xdd/0xe2
> [  233.048393] Code: 59 01 5d c3 55 48 89 e5 53 41 50 0f 1f 44 00 00 48=
 89 fb e8 d4 b0 f0 ff 84 c0 75 11 48 89 de 48 c7 c7 fc fa f7 82 e8 0d 0f =
57 01 <0f> 0b 5f 5b 5d c3 55 48 89 e5 0f 1f 44 00 00 48 63 87 d8 00 00=20
> [  233.048393] RIP  [<ffffffff81169653>] kfree_debugcheck+0x27/0x2d
> [  233.048393]  RSP <ffff88000facbca8>

Wu is running a bisect, let's hope that gives us a result.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig017DAE3F4793A7467429F705
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBGZ6cACgkQjTAFq1RaXHMwewCfV0PpSUbRyJ5Z8KMDwasQxf2C
1YcAoJUP4dCNX3o6W6rMSGHTjVWfrvDQ
=hJBo
-----END PGP SIGNATURE-----

--------------enig017DAE3F4793A7467429F705--
