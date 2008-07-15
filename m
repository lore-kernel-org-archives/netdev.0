From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 11:37:01 +0200
Message-ID: <1216114621.3535.18.camel@johannes.berg>
References: <1215769627.3483.107.camel@johannes.berg>
	 <20080715.021637.103260952.davem@davemloft.net>
	 <1216113923.3535.14.camel@johannes.berg>
	 <20080715.022854.55875400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JrPZzy9lLpE7gY2+S9VF"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080715.022854.55875400.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-JrPZzy9lLpE7gY2+S9VF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-07-15 at 02:28 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Tue, 15 Jul 2008 11:25:23 +0200
>=20
> > > It seems to me that a simple synchronize_net() call near the end of
> > > agg queue removal would solve your problem as-is, wouldn't it?
> >=20
> > Well, as far as I can tell we can't do that there because it's in
> > tasklet context/called under spinlocks so it has to be atomic. I think.
>=20
> Right, my bad.

Also, I don't actually think it is sufficient since select_queue isn't
called under rcu lock, so even if we synchronize_net() somewhere there
we can still end up not having waited long enough, no?

> It seems that there can end up being holes in the queue
> space on mac80211, which slightly complicates matters.

Yes, but why does it complicate matters? From mac80211's POV it's just
that select_queue must have known about the removed queue when the
requeue is done. And we can defer the requeue to a workqueue.

johannes

--=-JrPZzy9lLpE7gY2+S9VF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfG+5AAoJEKVg1VMiehFYPVIP/RFO0w0Xw5RYsbOgOHyEHAHP
I/iJ3oi1vQdOvTK2aymo/ZiDjRAEWpveWpioPbhdwg7XJGddXncgSA3vXPcOSHR3
VaCad0DTM0IdimQGSUbs3j28hWThiTEbbUJVV36QGo99q+dup9yTPSYTX/607Pt9
2ktND/pRkLhyCk/i8KBRm7aE/Vsbh8rT7H7NcDiJDAr+6e3M7mtPajE1V+Flz7mF
p6ww6pLWNr/wG31kS92ZB510aI/+0OjwraSWceYXq5Q8SajL18XtS7A04UxmfnDo
YsDjmxkrynBFAmCDGBc18NKgNL16T9HP/EEHeiMpWVfKmTNo879BqsHBPn9iY2Sk
KiwHxGwyYN78buCqEFvK7XxKWL7SHJRwF+fHZ4zbEvl6JblPMK5mY0nJTdXhX1PM
hGCQRkL21j5ANoT8p7JnyKxuRJrCP6QSv3c/P8zrEWqBPQhaHVKjRHFUWb5WAC7l
BRnOjYFoVfecjF0UH6jK9yFPuRY9CH5I2btVEtGRxuB900AhOgdVuDYLRJMDwagA
zwO6s9dbz0AWVeCkS5Gdh56X7Wq9zKqSwJIRjxauJg4cg4VotFINstIRMp81LRsk
kvE2WacuKcDbwnq00QFoYNzM5hj12AeXeJLWCCaWC4s2EWnKTAbiWuG/aPBhqJ4u
KybqWJQqgNzQzk+WAQr7
=AZe8
-----END PGP SIGNATURE-----

--=-JrPZzy9lLpE7gY2+S9VF--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
