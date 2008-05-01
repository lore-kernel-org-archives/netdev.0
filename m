From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 11:48:19 +0200
Message-ID: <1209635299.4008.21.camel@johannes.berg>
References: <1209632886.4008.8.camel@johannes.berg>
	 <20080501.022041.213526595.davem@davemloft.net>
	 <1209634349.4008.15.camel@johannes.berg>
	 <20080501.024320.212547875.davem@davemloft.net>
	 (sfid-20080501_114312_341550_5D240026)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9FwqanWlyx98cv0+ZK1Y"
Cc: mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080501.024320.212547875.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20080501_114312_341550_5D240026)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-9FwqanWlyx98cv0+ZK1Y
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I looked at the mac80211 code, the problem is the skb_push() you
> guys do in this situation.

Thanks.

> Things like loopback, which also orphan then reinject, don't trigger
> this problem because the re-input path trims things, never adds.
>=20
> The good news is that this is easy to fix.
>=20
> Since you've orphaned the SKB, simply adjust skb->truesize as you
> do pushes.  Like this:
>=20
> mac80211: Adjust truesize in ieee80211_tx_status() when reinjecting.
>=20
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
=20
> +	/* This is safe because the buffer has been orphaned.  */
> +	skb->truesize +=3D sizeof(*rthdr);

Hmm. The disconnect between truesize and skb->len+sizeof(*skb) was
usually 17 or 19 bytes and sizeof(*rthdr) is only 11. On the other hand,
I don't see where the other bytes should be coming from. I'll give this
a try, thanks.

johannes

--=-9FwqanWlyx98cv0+ZK1Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmR4aVg1VMiehFYAQJfSA/+K3cDycwgM/DBgs36PXLy4f7dISGXwQwb
o2N+zTSne27dUZyAF9Q+48IKr+hZWOT75ciLXQkAj9eFah5mB19LzsKoB8DNJUKK
/lOMY8t+2zPGpHxNwZ6jw2qtolvsLlB4p+SwNOuEqfMxttF6tpWLbIvv75DeJ79B
Vvkkljwq3Ev5/reYosnLjqkVpqnXPkmJFZ+WGKUJp5gVRgw/eH57s/VbHHHBHXj6
FoNDrgcswrZ7XHeOwATaXfzW5At/YBMbcMpsPXkfzbRXbN4Gp3pqukCC1I9D2yfw
LZNShCuyD00fSBpUwDJR3tVe3VT4l2QnbHwX4lrrCn9KNe4ULgWXx5eSoTVCxZzt
JSyx2jhKwvfKX92C2X882wX76EX4ezmxigZAC0YGq5DEKC31//KeqmH/VN8hKHLR
5rh8QeHzI28afj9mWr04pXXL5QHVOwTXLN7+gixsRnzlWreRja2xUgg4dnG/lisB
AS0uGzJ4EzVhhsdiFLc/uEUYHkmYNEhWzUTAHL/yUqeiFOEyXTCBF5kEv7P+fOxP
lw3F4B2Pm26ZDMjFNtDo/b2oLEy9DuAYi50Fl/jMUbb2MqI7oTMZBJhRT12OAOBt
0TJUde9INOap3ewdbpJdoUyuRkAPW65Y+RuA16SlfiFpPUnF5mvZHiRndbrukALc
DvXN55geSvI=
=S0Ch
-----END PGP SIGNATURE-----

--=-9FwqanWlyx98cv0+ZK1Y--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
