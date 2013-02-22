From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: batman-adv: gpf in batadv_slide_own_bcast_window
Date: Fri, 22 Feb 2013 18:06:21 +0100
Message-ID: <20130222170621.GU3523@ritirata.org>
References: <5127A2AF.9030502@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="jfWagoTHmfL/c8Ax"
Cc: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:38997 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758095Ab3BVRHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 12:07:25 -0500
Content-Disposition: inline
In-Reply-To: <5127A2AF.9030502@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jfWagoTHmfL/c8Ax
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sasha and thank you very much for reporting this issue.

IIRC this is similar to a bug you already reported in the past.
This bug should be the result of a race condition batman-adv has in the
hard-interface handling code (this is why it has been triggered while remov=
ing
eth0).

Now that the rtnl-deadlock has been solved I think we can try to further
investigate on this bug and try to find a solution..though it will not be e=
asy
as it probably requires another lock to protect the hard-interface during t=
his
operations.

If you have any fix proposal feel free to contribute!

Cheers,

On Fri, Feb 22, 2013 at 11:54:07AM -0500, Sasha Levin wrote:
> Hi all,
>=20
> While fuzzing with trinity inside a KVM tools guest running latest -next =
kernel
> I've stumbled on the following:
>=20
> [ 3148.615130] batman_adv: <98>\<AE><A4><C7>^?: Removing interface: eth0
> [ 3148.991938] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGE=
ALLOC
> [ 3148.993736] Dumping ftrace buffer:
> [ 3148.997554]    (ftrace buffer empty)
> [ 3148.998426] Modules linked in:
> [ 3148.999135] CPU 3
> [ 3148.999606] Pid: 6, comm: kworker/u:0 Tainted: G        W    3.8.0-nex=
t-20130222-sasha-00038-gba27e20-dirty #11
> [ 3149.001223] RIP: 0010:[<ffffffff83d217d8>]  [<ffffffff83d217d8>] batad=
v_slide_own_bcast_window+0xb8/0x2b0
> [ 3149.001223] RSP: 0018:ffff8800b9f4fc58  EFLAGS: 00010246
> [ 3149.001223] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 000000000=
0000001
> [ 3149.001223] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 000000000=
0000001
> [ 3149.001223] RBP: ffff8800b9f4fcb8 R08: 0000000000000002 R09: ffff8800b=
9f63950
> [ 3149.001223] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800a=
bad2238
> [ 3149.001223] R13: 6b6b6b6b6b6b865b R14: ffff88004c13cda0 R15: 000000000=
0000001
> [ 3149.001223] FS:  0000000000000000(0000) GS:ffff8800bbc00000(0000) knlG=
S:0000000000000000
> [ 3149.001223] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3149.001223] CR2: 00007f006711f1d0 CR3: 000000008258e000 CR4: 000000000=
00406e0
> [ 3149.001223] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> [ 3149.001223] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
> [ 3149.001223] Process kworker/u:0 (pid: 6, threadinfo ffff8800b9f4e000, =
task ffff8800b9f63000)
> [ 3149.001223] Stack:
> [ 3149.001223]  ffffffff83d21760 ffff8800b9f63000 ffff8800abad2238 000000=
0000000000
> [ 3149.001223]  ffff880068f6c438 0000035e00000001 ffff8800b9f4fc98 000000=
0000000000
> [ 3149.001223]  ffff8800abad2238 ffff88004c13c2a0 ffff88004c13cda0 000000=
0000000001
> [ 3149.001223] Call Trace:
> [ 3149.001223]  [<ffffffff83d21760>] ? batadv_slide_own_bcast_window+0x40=
/0x2b0
> [ 3149.001223]  [<ffffffff83d10ee4>] batadv_iv_ogm_schedule+0x254/0x300
> [ 3149.001223]  [<ffffffff83d10c90>] ? batadv_iv_ogm_queue_add+0x710/0x710
> [ 3149.001223]  [<ffffffff811178bf>] ? local_bh_enable_ip+0xef/0x150
> [ 3149.001223]  [<ffffffff83d25a15>] batadv_send_outstanding_bat_ogm_pack=
et+0xc5/0xf0
> [ 3149.001223]  [<ffffffff81133ce6>] process_one_work+0x366/0x6a0
> [ 3149.001223]  [<ffffffff81133ba8>] ? process_one_work+0x228/0x6a0
> [ 3149.001223]  [<ffffffff811345a8>] worker_thread+0x238/0x370
> [ 3149.001223]  [<ffffffff81134370>] ? rescuer_thread+0x310/0x310
> [ 3149.001223]  [<ffffffff8113eb73>] kthread+0xe3/0xf0
> [ 3149.001223]  [<ffffffff8113ea90>] ? flush_kthread_work+0x1f0/0x1f0
> [ 3149.001223]  [<ffffffff83dc203c>] ret_from_fork+0x7c/0xb0
> [ 3149.001223]  [<ffffffff8113ea90>] ? flush_kthread_work+0x1f0/0x1f0
> [ 3149.001223] Code: 31 4b fd 85 c0 74 24 48 c7 c2 50 cd bd 84 be 02 03 0=
0 00 48 c7 c7 b4 da bd 84 c6 05 14 ab 16 02 01 e8 ed 16
> 46 fd 0f 1f 44 00 00 <49> 8b 55 00 48 89 55 b8 e8 0b 55 41 fd 85 c0 74 37=
 80 3d ee aa
> [ 3149.001223] RIP  [<ffffffff83d217d8>] batadv_slide_own_bcast_window+0x=
b8/0x2b0
> [ 3149.001223]  RSP <ffff8800b9f4fc58>
> [ 3149.105631] ---[ end trace ba69e369627c73e7 ]---
>=20
> Rip points to:
>=20
>         for (i =3D 0; i < hash->size; i++) {
>                 head =3D &hash->table[i];
>=20
>                 rcu_read_lock();
>                 hlist_for_each_entry_rcu(orig_node, head, hash_entry) { <=
--- here
>                         spin_lock_bh(&orig_node->ogm_cnt_lock);
>                         word_index =3D hard_iface->if_num * BATADV_NUM_WO=
RDS;
>                         word =3D &(orig_node->bcast_own[word_index]);
>=20
>=20
> Thanks,
> Sasha

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--jfWagoTHmfL/c8Ax
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRJ6WNAAoJEADl0hg6qKeOnIkP/31GF+kWLmpE5o0tjrje3ecQ
68bOZ1zvZ+Xrc9afN5ejHOcsZVr6foyl/cqyDcDO9jxVIIxVbW/8YkFhE9e7/WGc
XWqij8kQgpC8CnLpV/+ABzRzYqmIq/JX3uxJNoSd7qB4wpmCO8cmMNl+hSWJT502
GxHVrA+R756pE2BMx8Py6YkS1+tzRPBdf1XJhdYHB5TedrYmn7R7O1DxfCILJ0gQ
pdZ6s0GIoHeBTIle0CQIluHsDB0DksLGInkv8t7d5unNddFeeoUV9R/ej+6xpqxt
n05e/nMrCUVZ9kc+kbQlqzJuglkNmxZzp1BJD9jQOV5g9CE6cdq9tGMZptTH5M7c
IABYn9F5NJVCdWSpjDKamJhaxzy0B9xxXhCd/cterQIw/p7xo4hqgnpYO5DN1llN
Q3pD6+chaENDAFdW0amfYecAEG5yb0RJQnYFoiJU0VOQndkOiakSEqA5gT1Qdf+o
qZ5pdTDh4yNOlmPj8K9KtBLBXMizVMFbmzk+vaJ02u7LAfLR4n9GFCw4CCH8e4QV
PPRpDF/rzyv/VdcHAOOnxOaA5iBJ5k96nA5G5s1boVpURPC95CTlb+0HIVrV3wjG
4WsncBDyxGE6cbzmUgADy2IqrKVp+s9ME5dGWsd5zjcBcba/HX+JCiENc06t6gG2
s1N0wC1P94JF1efSvvnW
=kbJz
-----END PGP SIGNATURE-----

--jfWagoTHmfL/c8Ax--
