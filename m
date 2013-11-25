From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 00/16] wl1251 patches from linux-n900 tree
Date: Mon, 25 Nov 2013 20:54:41 +0100
Message-ID: <201311252054.41177@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <CAMP44s1ADLHagfPa8kmx_wSyqvLf7pcN_UuOqoPShYx2HPUQXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart25202074.IUOrPMC6Og";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-wireless Mailing List" <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	freemangordon@abv.bg, aaro.koskinen@iki.fi,
	Pavel Machek <pavel@ucw.cz>, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMP44s1ADLHagfPa8kmx_wSyqvLf7pcN_UuOqoPShYx2HPUQXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart25202074.IUOrPMC6Og
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Friday 08 November 2013 15:20:07 Felipe Contreras wrote:
> On Sat, Oct 26, 2013 at 3:33 PM, Pali Roh=C3=A1r <pali.rohar@gmail.com> w=
rote:
> > Hello, I'm sending wl1251 patches from linux-n900 tree [1]
> > for comments. More patches come from David's monitor &
> > packet injection work. Patches are tested with 3.12 rc5
> > kernel on Nokia N900.
> >=20
> > [1] - https://gitorious.org/linux-n900/linux-n900
>=20
> How did you test these patches? I get a panic loop immediately
> after I bring the interface loop in monitor mode (v3.12).

Hi!

now I can reproduce this crash with 3.12-rc5 kernel. Problem
looks like irrelevant to this patch series and is present in 3.12
kernel. There is possible NULL pointer dereference.

With this patch I'm not able to reproduce this bug:

diff --git a/drivers/net/wireless/ti/wl1251/event.c b/drivers/net/wireless/=
ti/wl1251/event.c
index 192cebd..db01053 100644
=2D-- a/drivers/net/wireless/ti/wl1251/event.c
+++ b/drivers/net/wireless/ti/wl1251/event.c
@@ -124,7 +124,7 @@ static int wl1251_event_process(struct wl1251 *wl, stru=
ct event_mailbox *mbox)
 			return ret;
 	}
=20
=2D	if (vector & SYNCHRONIZATION_TIMEOUT_EVENT_ID) {
+	if (wl->vif && vector & SYNCHRONIZATION_TIMEOUT_EVENT_ID) {
 		wl1251_debug(DEBUG_EVENT, "SYNCHRONIZATION_TIMEOUT_EVENT");
=20
 		/* indicate to the stack, that beacons have been lost */


=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart25202074.IUOrPMC6Og
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlKTqwEACgkQi/DJPQPkQ1IYlgCbBXWPEf1rkwMHfL9n2UzzPj0u
c6MAn3PfzdwsEcI+W7WM+vAoodK+JOgQ
=LVAq
-----END PGP SIGNATURE-----

--nextPart25202074.IUOrPMC6Og--
