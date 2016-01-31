From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: Supermicro AOC-STGN-i2S w intel 82599ES on Brocade ICX6610 -
 random link failures
Date: Sun, 31 Jan 2016 23:01:33 +0100
Message-ID: <20160131220133.GA6233@nik-comp.linuxbox.cz>
References: <20160125100851.GA7545@nbnik.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Cc: nik@linuxbox.cz, Stanislav Schattke <schattke@linuxbox.cz>,
	emil.s.tantilov@intel.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:37758 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294AbcAaWBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jan 2016 17:01:34 -0500
Content-Disposition: inline
In-Reply-To: <20160125100851.GA7545@nbnik.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

I've updated all three boxes to 4.1.15. I've just had link outage again,
but this time I got more detailed backtrace..

not sure, but maybe it could be of some help?

[Jan30 23:53] ixgbe 0000:03:00.0 eth0: NIC Link is Down
[  +0.097285] bond0: link status definitely down for interface eth0, disabl=
ing it
[  +0.007695] bond0: first active interface up!
[  +0.000224] ------------[ cut here ]------------
[  +0.000007] WARNING: CPU: 6 PID: 19351 at kernel/softirq.c:150 __local_bh=
_enable_ip+0x7a/0xb0()
[  +0.000031] Modules linked in: cbc ceph libceph fscache dlm sctp crc32c_i=
ntel crc32c_generic libcrc32c configfs netconsole autofs4 sunrpc ipmi_devin=
tf bridge stp llc 8021
[  +0.000002] CPU: 6 PID: 19351 Comm: kworker/u32:1 Not tainted 4.1.15lb6.0=
3 #1
[  +0.000000] Hardware name: Supermicro X10DRW/X10DRW-i, BIOS 1.0c 01/07/20=
15
[  +0.000005] Workqueue: bond0 bond_mii_monitor [bonding]
[  +0.000002]  0000000000000096 ffff8804c2213798 ffffffff814c104b 000000000=
0000096
[  +0.000001]  0000000000000000 ffff8804c22137d8 ffffffff810535a5 ffff88103=
6f03e00
[  +0.000002]  0000000000000200 ffff8804c2213830 0000000000000000 ffffffffa=
05250c0
[  +0.000000] Call Trace:
[  +0.000004]  [<ffffffff814c104b>] dump_stack+0x4f/0x74
[  +0.000002]  [<ffffffff810535a5>] warn_slowpath_common+0x95/0xe0
[  +0.000002]  [<ffffffff8105360a>] warn_slowpath_null+0x1a/0x20
[  +0.000002]  [<ffffffff81057b4a>] __local_bh_enable_ip+0x7a/0xb0
[  +0.000003]  [<ffffffffa07abc41>] bond_poll_controller+0x111/0x150 [bondi=
ng]
[  +0.000003]  [<ffffffff814242cc>] netpoll_poll_dev+0x5c/0x1b0
[  +0.000003]  [<ffffffff814072be>] ? netif_skb_features+0xfe/0x1f0
[  +0.000001]  [<ffffffff81424589>] netpoll_send_skb_on_dev+0x169/0x250
[  +0.000002]  [<ffffffffa07d3975>] vlan_dev_hard_start_xmit+0x105/0x120 [8=
021q]
[  +0.000001]  [<ffffffff81423c2c>] netpoll_start_xmit+0x15c/0x1f0
[  +0.000002]  [<ffffffff8142456b>] netpoll_send_skb_on_dev+0x14b/0x250
[  +0.000001]  [<ffffffff8142492f>] netpoll_send_udp+0x2bf/0x400
[  +0.000002]  [<ffffffffa087b234>] write_msg+0xb4/0xf0 [netconsole]
[  +0.000003]  [<ffffffff810a2154>] call_console_drivers.clone.1+0xa4/0x120
[  +0.000002]  [<ffffffff810a2454>] console_unlock+0x284/0x400
[  +0.000002]  [<ffffffff810a2e7b>] vprintk_emit+0x20b/0x4a0
[  +0.000002]  [<ffffffff810a312f>] vprintk_default+0x1f/0x30
[  +0.000001]  [<ffffffff814c0f39>] printk+0x46/0x48
[  +0.000002]  [<ffffffff81402ef6>] __netdev_printk+0x176/0x2e0
[  +0.000002]  [<ffffffff814030b3>] netdev_info+0x53/0x60
[  +0.000003]  [<ffffffffa07b30f7>] ? bond_3ad_set_carrier+0x57/0xa0 [bondi=
ng]
[  +0.000003]  [<ffffffffa07ae468>] ? bond_set_carrier+0xb8/0xd0 [bonding]
[  +0.000003]  [<ffffffffa07ae5fe>] bond_select_active_slave+0x17e/0x200 [b=
onding]
[  +0.000002]  [<ffffffffa07aeb3f>] bond_mii_monitor+0x4bf/0x700 [bonding]
[  +0.000003]  [<ffffffff8106b119>] process_one_work+0x139/0x470
[  +0.000001]  [<ffffffff8106b573>] worker_thread+0x123/0x520
[  +0.000002]  [<ffffffff8106b450>] ? process_one_work+0x470/0x470
[  +0.000001]  [<ffffffff8106b450>] ? process_one_work+0x470/0x470
[  +0.000002]  [<ffffffff810707ce>] kthread+0xde/0x100
[  +0.000001]  [<ffffffff810706f0>] ? __init_kthread_worker+0x40/0x40
[  +0.000003]  [<ffffffff814c6b52>] ret_from_fork+0x42/0x70
[  +0.000001]  [<ffffffff810706f0>] ? __init_kthread_worker+0x40/0x40
[  +0.000001] ---[ end trace c168d14d53373934 ]---
[  +1.635277] ixgbe 0000:03:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control=
: RX/TX

anyways, next step we'll do now is switch firmware update (although there's=
 only
one minor update, so I don't expect much..)

BR

nik

On Mon, Jan 25, 2016 at 11:08:51AM +0100, Nikola Ciprich wrote:
> Hello netdev readers,
>=20
> I'd like to consult following problem we're dealing with:
>=20
> I have a cluster of three nodes connected to stacked Brocade ICX6610
> switches using bonded AOC-STGN-i2S adapters (they're using 82599ES
> chipsets).
>=20
> The problem is, I see random link failures on practically all
> interfaces. Link always goes down for very short time, then adapter
> is reset and link goes up again.
>=20
> Here's dmesg snippet:
>=20
> [Jan22 22:09] ixgbe 0000:03:00.0 eth0: NIC Link is Down
> [  +0.005610] ixgbe 0000:03:00.0 eth0: initiating reset to clear Tx work =
after link loss
> [  +0.012792] bond0: link status definitely down for interface eth0, disa=
bling it
> [  +1.105826] ixgbe 0000:03:00.0 eth0: Reset adapter
> [  +0.307518] ixgbe 0000:03:00.0 eth0: detected SFP+: 3
> [  +0.145881] ixgbe 0000:03:00.0 eth0: NIC Link is Up 10 Gbps, Flow Contr=
ol: RX/TX
>=20
> since I'm using bonding, it doesn't disrupt traffic, but I'd still like to
> resolve it. We're using 5m passive SFP cables, we tried replacing one wit=
h 3m
> piece, to no avail.=20
>=20
> all three boxes are supermicro X10DRW, running vanilla x86_64 4.0.5 kerne=
l (I'll upgrade it to 4.1.16 soon)
>=20
> we were using broadcom adapter before and they were working without such =
problems
> (except for one particular port, which showed mysterious packet drops eve=
ry few
> months, thats why we switched to intel-based adapters), so I think cables=
 and switches
> should be fine, but I'm not sure of course
>=20
> I think I've seen similar problems and they were PM related, but I'm not =
sure..
>=20
> anyone seen similar problem?
>=20
> or some tips on how could I debug it?
>=20
> If I could provide more information, please let me know
>=20
> BR
>=20
> nik
>=20
> --=20
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28.rijna 168, 709 00 Ostrava
>=20
> tel.:   +420 591 166 214
> fax:    +420 596 621 273
> mobil:  +420 777 093 799
> www.linuxbox.cz
>=20
> mobil servis: +420 737 238 656
> email servis: servis@linuxbox.cz
> -------------------------------------



--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799

www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlauhD0ACgkQ3xdJJrLygV6TWwCg2LEXOsVyCA9GC5F6CTP5cOXQ
UzwAoKv5Z57DhkhXuzMcmYZA6CyENATk
=SMxX
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--
