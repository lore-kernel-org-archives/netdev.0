From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Tue, 18 Dec 2007 13:47:14 +0100
Message-ID: <1197982034.4885.120.camel@johannes.berg>
References: <1197483844.6558.158.camel@johannes.berg>
	 <20071214050808.GE5698@jm.kir.nu> <1197634385.16079.34.camel@johannes.berg>
	 <20071218041810.GB5698@jm.kir.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iBKqh71Z208HIBR6UlH8"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071218041810.GB5698-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-iBKqh71Z208HIBR6UlH8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Unfortunately not. Does that really matter? It seems that the
> > verification whether the frame was encrypted would either be "always
> > require encryption when pairwise keys in use" (which this patch doesn't
> > do right now but could trivially be done) or simply "don't care since i=
t
> > doesn't really matter".
>=20
> In theory, yes, this does matter and the implementation does not comply
> with the standard if we do not verify this for WPA/WPA2/IEEE 802.11 RSN.

Ouch, ok.

> However, I do not believe there is any real security issue in not doing
> so and even worse, some client implementations end up using unencrypted
> EAPOL frames when they should really be encrypted..

That was what I was thinking. I guess being lax caused those
implementations to "work" to a point where now it can't be changed?

> hostapd has a place in the implementation where this information could
> be processed, but I did not actually ever enable such validation because
> of the potential interoperability issues. Likewise, wpa_supplicant does
> not validate this either.

Ok.

> In other words, this would be kind of nice to have feature in the kernel
> interface, but not really something that would be strictly required from
> security view point.

Right. I don't see how we can do this though of course it ought to be
possible with some sort of out-of-band data even on the regular data
interface. I still think the regular data interface is a better place
for these frames because of fragmentation/encryption/aggregation issues.

> > Actually, 802.1X doesn't specify that, as I said previously it
> > *recommends* it in C.3.3 (not C.1.1 as the 802.11 specs lead you to
> > believe). Also, a patch to do this was rejected by Stephen Hemminger, s=
o
> > I decided to only pass up EAPOL frames that are either for our own
> > unicast address or the link-local eapol address, both of which won't be
> > bridged.
>=20
> It is a "must" requirement, but apparently only in informative clause of
> IEEE 802.1X. However, this is a real issue and if the bridging code
> cannot be changed to do this, so dropping multicast/broadcast EAPOL
> frames in mac80211 (in both RX and TX direction) sounds reasonable
> workaround to prevent cases where wireless clients could otherwise mess
> with other IEEE 802.1X authentications (e.g., for the wired port of an
> AP).

It's a tad more complicated than that. The patch as it stands will allow
a station to mess with other 802.1X authentications when it has already
authenticated its own virtual port. It also drops frames in a way that
when the own virtual port is not authenticated it cannot do this. I
believe that the former is an issue with the linux bridging code and if
somebody wants to deploy linux-based 802.1X they need to install the
appropriate ebtables rules on all equipment.

> I added the C.3.3 vs. C.1.1 issue to my pending comments for the next
> IEEE 802.11 maintenance task group (TGmb). Should you find any other
> issues with IEEE Std 802.11-2007, I can add them to that list so that
> they can eventually be fixed.

Thanks. I'll let you know. I have one request for clarification
actually:
The standard always talks about DTIM count and how stations can use that
to know when the next DTIM beacon is sent. However, in one sentence
where it talks about timing, it also says that TSF=3D=3D0 is not only a TBT=
T
but also a DTIM beacon. Is that intentional? No implementations I know
of seem to require TSF=3D=3D0 to be DTIM but rather use the DTIM count to
sync.

johannes

--=-iBKqh71Z208HIBR6UlH8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2fBUaVg1VMiehFYAQI/5w//SfJbwGGYeUjt9ubekY4vkx6PflbYb7E0
/oHJALOUlGUap90/oSaUVasrQ0ZpNBV+81qt4WNDYQK7QwHqVRXjSZlqncHRimBO
m2z7Wsdd3qrDbDp6mZ14hqgrFYYJBJU/ZUGjF5q2Dp0/JmkxYRAUjYt0BhazD49P
zSDeE2v96J9ItskYq+AOute269YSMDqmYuISm7y/n5yjXkLxndUdhH/WAUNFf9MY
cVBKKupkJ/RJTnrZTKLNWHBKiYDTOjpRBAdO7J75aFDY/cjQZDC+bz99pSxtuA0D
BCrzIbFjMHivzBNur2rwzoe+6Wt0qHcLUQZ7cm3u8eDMndgdK9joxEYu+yM1y2BQ
27mw53WTj0xrt21/6GPOTj65G8V7nC4MxfZT05SpcPOAsaXByk2WC0H9eZC9cn4m
/OnPJBCQSzYRAJGU6TBxH111MUCpV9bToYKiAcVdli2HKf6AnE0X+FWVj7bxLeNa
5uTFk1QwStOJ8IwkCmybdTMpU+CmKYSsO5xb/frwF/KQygF34farwgQJgnY9pRLH
VTZ/c9CKlmQXEVWWRsd4CLwn4wuvoh0dAppkiDwIaaMoQcq3FRS11NBhD5tgjRZw
zpnJ44X80c8l29YI/yELLkS68+cJxWjDvv4Z+hZc2Gdb6/Phxvz9ZwvaM4ta/H0x
tPZRsiQ+VG8=
=3GCz
-----END PGP SIGNATURE-----

--=-iBKqh71Z208HIBR6UlH8--
