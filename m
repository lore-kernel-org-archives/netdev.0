From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] wl1251: add a missing spin_lock_init()
Date: Thu, 31 Aug 2017 16:47:43 +0200
Message-ID: <20170831144743.GA21261@amd>
References: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
 <20170830.101143.2305098064824357647.davem@davemloft.net>
 <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
 <20170830.105447.125174575140677062.davem@davemloft.net>
 <87fuc8s5v9.fsf@kamboji.qca.qualcomm.com>
 <20170831065204.GA17812@amd>
 <87y3q0q7ln.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87y3q0q7ln.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

=46rom: Cong Wang <xiyou.wangcong@gmail.com>

wl1251: add a missing spin_lock_init()
   =20
This fixes the following kernel warning:
   =20
 [ 5668.771453] BUG: spinlock bad magic on CPU#0, kworker/u2:3/9745
 [ 5668.771850]  lock: 0xce63ef20, .magic: 00000000, .owner: <none>/-1,
 .owner_cpu: 0
 [ 5668.772277] CPU: 0 PID: 9745 Comm: kworker/u2:3 Tainted: G        W
 4.12.0-03002-gec979a4-dirty #40
 [ 5668.772796] Hardware name: Nokia RX-51 board
 [ 5668.773071] Workqueue: phy1 wl1251_irq_work
 [ 5668.773345] [<c010c9e4>] (unwind_backtrace) from [<c010a274>]
 (show_stack+0x10/0x14)
 [ 5668.773803] [<c010a274>] (show_stack) from [<c01545a4>]
 (do_raw_spin_lock+0x6c/0xa0)
 [ 5668.774230] [<c01545a4>] (do_raw_spin_lock) from [<c06ca578>]
 (_raw_spin_lock_irqsave+0x10/0x18)
 [ 5668.774658] [<c06ca578>] (_raw_spin_lock_irqsave) from [<c048c010>]
 (wl1251_op_tx+0x38/0x5c)
 [ 5668.775115] [<c048c010>] (wl1251_op_tx) from [<c06a12e8>]
 (ieee80211_tx_frags+0x188/0x1c0)
 [ 5668.775543] [<c06a12e8>] (ieee80211_tx_frags) from [<c06a138c>]
 (__ieee80211_tx+0x6c/0x130)
 [ 5668.775970] [<c06a138c>] (__ieee80211_tx) from [<c06a3dbc>]
 (ieee80211_tx+0xdc/0x104)
 [ 5668.776367] [<c06a3dbc>] (ieee80211_tx) from [<c06a4af0>]
 (__ieee80211_subif_start_xmit+0x454/0x8c8)
 [ 5668.776824] [<c06a4af0>] (__ieee80211_subif_start_xmit) from
 [<c06a4f94>] (ieee80211_subif_start_xmit+0x30/0x2fc)
 [ 5668.777343] [<c06a4f94>] (ieee80211_subif_start_xmit) from
 [<c0578848>] (dev_hard_start_xmit+0x80/0x118)
=2E..
   =20
    by adding the missing spin_lock_init().
   =20
Reported-by: Pavel Machek <pavel@ucw.cz>
Cc: Kalle Valo <kvalo@codeaurora.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Pavel Machek <pavel@ucw.cz>
Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
Signed-off-by: Pavel Machek <pavel@ucw.cz>
Cc: stable@kernel.org

---

> >> Yeah, you are right there. I did actually ponder which I tree should
> >> commit it back in July but due to various reasons decided differently.
> >
> > Can we still get the fix to v4.13-final? :-).
>=20
> I'm not planning to submit pull requests to 4.13 anymore. If you think
> this is so important that it needs to be applied in the last minute (I
> don't) you could always try to convince Dave to take it directly.
>=20
> Or better yet, push it to the stable tree. If the merge window opens on
> Sunday I suspect that the commit will be in Linus' tree sometime next
> week. Then you can submit the request to the stable team to take it.

I don't think we should use stable tree as an excuse for not fixing
the bugs in mainline. Original patch is from Jul 6, thats 7 weeks ago.

Dave, Linus -- can you still take the patch?

Thanks,
								Pavel


diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/t=
i/wl1251/main.c
index 08f0477..9915d83 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -1571,6 +1571,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
=20
 	wl->state =3D WL1251_STATE_OFF;
 	mutex_init(&wl->mutex);
+	spin_lock_init(&wl->wl_lock);
=20
 	wl->tx_mgmt_frm_rate =3D DEFAULT_HW_GEN_TX_RATE;
 	wl->tx_mgmt_frm_mod =3D DEFAULT_HW_GEN_MODULATION_TYPE;



--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmoIY8ACgkQMOfwapXb+vKSWQCdE/a4LL+Pa55ni6WOlhCa+Vv1
XzcAnRKBGbrsApwcPZdfM1KC+sn3FXaq
=4uNE
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--
