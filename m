From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] drivers:net:wireless: Add proper locking for the
 function, b43_op_beacon_set_tim in main.c
Date: Fri, 2 Jan 2015 12:42:17 +0100
Message-ID: <20150102124217.5c1aa5ef@wiggum>
References: <1420184041-6788-1-git-send-email-xerofoify@gmail.com>
	<20150102102727.3918a684@wiggum>
	<CACna6rxP5dB7ng5pf1jeJL7TTOq4xPC9B=wmrX+yeYK-hfF5uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/K+eq=hQXwN7zrPuf_HWLNwo"; protocol="application/pgp-signature"
Cc: Nicholas Krause <xerofoify@gmail.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>,
	Kalle Valo <kvalo@codeaurora.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:52805 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbbABLmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 06:42:36 -0500
In-Reply-To: <CACna6rxP5dB7ng5pf1jeJL7TTOq4xPC9B=wmrX+yeYK-hfF5uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/K+eq=hQXwN7zrPuf_HWLNwo
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, 2 Jan 2015 12:19:12 +0100
Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:

> On 2 January 2015 at 10:27, Michael B=C3=BCsch <m@bues.ch> wrote:
> > On Fri,  2 Jan 2015 02:34:01 -0500
> > Nicholas Krause <xerofoify@gmail.com> wrote:
> >
> >> This adds proper locking for the function, b43_op_beacon_set_tim in ma=
in.c by using the mutex lock
> >> in the structure pointer wl, as embedded into this pointer as a mutex =
in order to protect against
> >> multiple access to the pointer wl when updating the templates for this=
 pointer in the function,
> >> b43_update_templates internally in the function, b43_op_beacon_set_tim.
> >>
> >> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> >> ---
> >>  drivers/net/wireless/b43/main.c | 3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b4=
3/main.c
> >> index 47731cb..d568fc8 100644
> >> --- a/drivers/net/wireless/b43/main.c
> >> +++ b/drivers/net/wireless/b43/main.c
> >> @@ -5094,8 +5094,9 @@ static int b43_op_beacon_set_tim(struct ieee8021=
1_hw *hw,
> >>  {
> >>       struct b43_wl *wl =3D hw_to_b43_wl(hw);
> >>
> >> -     /* FIXME: add locking */
> >> +     mutex_lock(&wl->mutex);
> >>       b43_update_templates(wl);
> >> +     mutex_unlock(&wl->mutex);
> >>
> >>       return 0;
> >>  }
> >
> > Thanks for the patch.
> >
> > However, this does not work. We are in atomic context here.
> > Please see the b43-dev mailing list archives for a recent thread about =
that.
>=20
> Michael: guess who it was who sent the patch doing the same back in Novem=
ber.
>=20
> Yes, the same troll.

D'oh.
Thanks for the notice.

--=20
Michael

--Sig_/K+eq=hQXwN7zrPuf_HWLNwo
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUpoQcAAoJEPUyvh2QjYsOhNAQALPbTkThjVUqnQTWNOoy+MzK
99S3RvqouOPehHInvjiZppcb4lncZqdpDCvzDivkH1ydYMMz5QSoTGuyhM2zuJG1
RChyFnXrg1TTgifFwibFlwhWmX5p9gwA3DMYjw7yQDiiD7uJgSyvoRq27vxUfGYy
UZbYm3Z4bnaXg8e6lzqPQE9Dq4VkZgQu7UpphX//wyjtJV2qMV56V6zX9+NPCwEp
jYYdNZ9T0HJAZLRrTeBYu4rifHyjlLye/fmV//2SEBUyos8IcpZb3t+AUg4kQBWB
uj8MszF7T+InRUeCykLWVTmJ5f/t3UYyZ9naTdrc4Og6uDbGEETTt0TEBz7bP9ZC
o6NRnZkCbzZwablqh7tq0IigLTBSL+YjYGXpU+m9QQpvcnb4LJ/LSTr2VyTUJgmB
rwKEcfNMMaT84a8hpTXmORYgHVJ2EgiiIbrVnxfebOSILYtcbXHQKw5HoWl4JeqC
hmgfbN3uJNSg9kfFtVpdhyXO1BK0298MV/ErpgAzpVYhBELSurky3rVt6uz1upJI
5A+RWkK9dBFoc6dd33KsJfNDilMFR/q2QEUH20UvlQ3h4XWctcYMXXxIz/qTv31H
e1Nya8FHigSmsEECveSl5Dyyb610Qxy1ybZdJFULuFkgo+oZVR4J+mVPn4OQzP6k
g2oR4hr/9Jq6vgrndJAR
=qRse
-----END PGP SIGNATURE-----

--Sig_/K+eq=hQXwN7zrPuf_HWLNwo--
