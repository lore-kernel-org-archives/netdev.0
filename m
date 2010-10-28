From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: delay rx_ring freeing
Date: Thu, 28 Oct 2010 05:21:33 -0700
Message-ID: <1288268493.27890.5.camel@jtkirshe-MOBL1>
References: <1286799439.2737.21.camel@edumazet-laptop>
	 <EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
	 <1288239858.2658.72.camel@edumazet-laptop>
	 <1288267354.2649.369.camel@edumazet-laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-YF0JiTrFVDPQqEaRZIBf"
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Brattain, Ross B" <ross.b.brattain@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5887 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932830Ab0J1MVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 08:21:42 -0400
In-Reply-To: <1288267354.2649.369.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YF0JiTrFVDPQqEaRZIBf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-10-28 at 05:02 -0700, Eric Dumazet wrote:
> Le jeudi 28 octobre 2010 =C3=A0 06:24 +0200, Eric Dumazet a =C3=A9crit :
> > Le mercredi 27 octobre 2010 =C3=A0 16:35 -0600, Tantilov, Emil S a =C3=
=A9crit :
>=20
> > > Eric,
> > >=20
> > > We are seeing intermittent hangs on ia32 arch which seem to point to =
this patch:
> > >=20
> > > BUG: unable to handle kernel NULL pointer dereference at 00000040
> > >  IP: [<f7f6b537>] ixgbe_get_stats64+0x47/0x120 [ixgbe]
> > >  *pdpt =3D 000000002dc83001 *pde =3D 000000032d7e5067
> > >  Oops: 0000 [#2] SMP
> > >  last sysfs file: /sys/devices/system/cpu/cpu23/cache/index2/shared_c=
pu_map
> > >  Modules linked in: act_skbedit cls_u32 sch_multiq ixgbe mdio netcons=
ole configfs autofs4 8021q garp stp llc sunrpc ipv6 e
> > > xt3 jbd dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath p=
ower_meter hwmon sg ses enclosure dcdbas pcspkr serio_raw iTCO_wdt iTCO_ven=
dor_support io
> > > atdma dca i7core_edac edac_core bnx2 ext4 mbcache jbd2 sr_mod cdrom s=
d_mod crc_t10dif pata_acpi ata_generic ata_piix megaraid_sas dm_mod [last u=
nloaded: mperf
> > > ]
> > >=20
> > >  Pid: 1939, comm: irqbalance Tainted: G      D W   2.6.36-rc7-upstrea=
m-net-next-2.6-ixgbe-queue-i386-g55e1a84 #1 09CGW2/Po
> > > werEdge T610
> > >  EIP: 0060:[<f7f6b537>] EFLAGS: 00010206 CPU: 0
> > >  EIP is at ixgbe_get_stats64+0x47/0x120 [ixgbe]
> > >  EAX: 00000000 EBX: ecc45e4c ECX: ebea0400 EDX: 00000000
> > >  ESI: ebea0000 EDI: 00000018 EBP: f7f846a0 ESP: ecc45d88
> > >  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > >  Process irqbalance (pid: 1939, ti=3Decc44000 task=3Defc63a50 task.ti=
=3Decc44000)
> > >  Stack:
> > >  ecc45e4c 00000000 ebea0400 ebea0000 ecc45e4c ebea0000 ecc45f04 f7f84=
6a0
> > >  <0> c0750593 ebea0000 edfec340 ebea0000 000002b5 c075063a edfec340 c=
0993eec
> > >  <0> ebe78000 0000021c 00000000 00000009 00000000 00000000 00000000 0=
0000000
> > >  Call Trace:
> > >  [<c0750593>] ? dev_get_stats+0x33/0xc0
> > >  [<c075063a>] ? dev_seq_printf_stats+0x1a/0x180
> > >  [<c07507aa>] ? dev_seq_show+0xa/0x20
> > >  [<c052398f>] ? seq_read+0x22f/0x3d0
> > >  [<c0523760>] ? seq_read+0x0/0x3d0
> > >  [<c054fdde>] ? proc_reg_read+0x5e/0x90
> > >  [<c054fd80>] ? proc_reg_read+0x0/0x90
> > >  [<c050a1dd>] ? vfs_read+0x9d/0x160
> > >  [<c049d4ef>] ? audit_syscall_entry+0x20f/0x230
> > >  [<c050a971>] ? sys_read+0x41/0x70
> > >  [<c0409cdf>] ? sysenter_do_call+0x12/0x28
> > >  Code: 60 4f 7e c8 8b 44 24 08 8b b8 20 06 00 00 85 ff 7e 63 c7 44 24=
 04 00 00 00 00 66 90 8b 54 24 04 8b 4c 24 08 8b 84 9
> > > 1 00 05 00 00 <8b> 50 40 eb 06 8d 74 26 00 89 ca f6 c2 01 0f 85 ae 00=
 00 00 8b
> > >  EIP: [<f7f6b537>] ixgbe_get_stats64+0x47/0x120 [ixgbe] SS:ESP 0068:e=
cc45d88
> > >  CR2: 0000000000000040
> > >  ---[ end trace 51ea89f4e57f54f1 ]---
> > >=20
> > > Emil
>=20
> I believe I now understand the problem, please try following patch.
>=20
> Thanks
>=20
>=20
>=20
> [PATCH] ixgbe: delay rx_ring freeing
>=20
> "cat /proc/net/dev" uses RCU protection only.
>=20
> Its quite possible we call a driver get_stats() method while device is
> dismantling and freeing its data structures.
>=20
> So get_stats() methods must be very careful not accessing driver private
> data without appropriate locking.
>=20
> In ixgbe case, we access rx_ring pointers. These pointers are freed in
> ixgbe_clear_interrupt_scheme() and set to NULL, this can trigger NULL
> dereference in ixgbe_get_stats64()
>=20
> A possible fix is to use RCU locking in ixgbe_get_stats64() and defer
> rx_ring freeing after a grace period in ixgbe_clear_interrupt_scheme()
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Tantilov, Emil S <emil.s.tantilov@intel.com>
> ---
>  drivers/net/ixgbe/ixgbe.h      |    1=20
>  drivers/net/ixgbe/ixgbe_main.c |   34 +++++++++++++++++++++----------
>  2 files changed, 25 insertions(+), 10 deletions(-)
>=20

Thanks Eric, I have added this patch to my queue.

--=-YF0JiTrFVDPQqEaRZIBf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAABAgAGBQJMyWrMAAoJECTsCADr/EWUddgH/Rb9Hscf79TAlGbHr9fypPjq
cCihvax4bILcDLaYbstfQhcupbiw49wKE6OQTZDM8S5dcz0urhj83hkB6G2v7FAO
oi2TbySoYgm9ReHJxdKqEQ4+nfEl9dvW1by+nDWXGZzKssc6oRD6RwePtk0xcWnd
9WFVYrWdbzpCLRl8iT3E1mEPWZzZ28cY3DKBVDJaKRoozfgxjecwB9RBD1zUZJCm
ygTyEcjagGrklHMjZoLFhs8J6gTnXdkIv/jM71raFViSRDh/TKvYK+DNUWOKVRMd
gCqNSAHAEahyqTrx5Lv9R2TUUCcfk8g+kgyUIQ/LevbZDSmrxrQWGL6F1S0BNL4=
=nYDe
-----END PGP SIGNATURE-----

--=-YF0JiTrFVDPQqEaRZIBf--

