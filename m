From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Fri, 14 Dec 2007 13:13:05 +0100
Message-ID: <1197634385.16079.34.camel@johannes.berg>
References: <1197483844.6558.158.camel@johannes.berg>
	 <20071214050808.GE5698@jm.kir.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/gHZ9GdwrRe0/87jatql"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071214050808.GE5698-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-/gHZ9GdwrRe0/87jatql
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Is there any way for an user space application to figure out whether a
> received EAPOL frame was encrypted? In theory, WPA/WPA2 Authenticators
> (e.g., hostapd) should verify that the frame was encrypted if pairwise
> keys are set (whereas IEEE 802.1X Authenticator accepts unencrypted
> EAPOL frames).

Unfortunately not. Does that really matter? It seems that the
verification whether the frame was encrypted would either be "always
require encryption when pairwise keys in use" (which this patch doesn't
do right now but could trivially be done) or simply "don't care since it
doesn't really matter".

> Did you/someone already verify that the Linux bridge code does not
> bridge EAPOL frames? The use of a separate interface for this removed
> the need for doing such filtering based on ethertype, but with EAPOL
> frames using the same netdev with other data frames, the bridge code
> should filter these out (mainly the PAE group addressed ones, but if I
> remember correctly, IEEE 802.1X specified all frames using EAPOL
> ethertype not to be bridged).

Actually, 802.1X doesn't specify that, as I said previously it
*recommends* it in C.3.3 (not C.1.1 as the 802.11 specs lead you to
believe). Also, a patch to do this was rejected by Stephen Hemminger, so
I decided to only pass up EAPOL frames that are either for our own
unicast address or the link-local eapol address, both of which won't be
bridged.

> I haven't looked into the current implementations and/or proposed
> patches on for TX part, but I would assume that it is possible to select
> whether an EAPOL frame will be encrypted when injecting it(?).

Yes, by setting the F_WEP flag on any frame you decide whether it will
be encrypted (if possible) or not. Right now, the corresponding hostapd
patch always sets that flag.

johannes

--=-/gHZ9GdwrRe0/87jatql
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2JzUKVg1VMiehFYAQKhYg//emKtpHa7lXGTCL0rHiHuOJmok3Mtc2M3
LFA9nr9Ba/rnUs1y2hJzl6e4nK7LclQmdDgCN4o8xomN7oUXV3buR9BAaEOzpDvT
IPgKAMqAsBLUoDGJITBo/eCefz6iXpuA0mZlxSaRWoqPICoUcuss/7s9VZFiUPYt
GxO2N+HkRs2oqst0pZ/sDi9+vORiQsoWpafsXuVD1XjJSGX9xp45eY9hW0BzKIGY
KquXCThilS0HWnCedJu7BtKKGGaByChKaJH1y4R+0b9u6gFWwmBu4llBInFegvRA
qIIA7Z2DyurstHmUQXkjDTQQnAkBvlNm1RZiAHcD5nwkwwgMqaSCeR4IuqrSS5vy
YccQkftqzzrCmzMUPPJVm8FpEZSAKeM1SWo0/viX+BulShmlsf3mEweAL2YY9sdc
Jxz3FvRFxnSOS/g9JLNCkGl86qFuS5+YXVUyZaBzIXM6n1GKsIyWZhcyY+wcwGhv
6ze21ATnFsHGb3PSKgowGivlacKyneqTePlSAFrAWVlZyLkDm/tTRVTs07Z3xL+R
HoIqOdgoxHFItou//H7DEncpi3uXB2zIaBDsIWZVTJR6bLosy5Uh5uF9u4uVzoWv
vUH3EJv8DV3ImQLJoTXLBM9LptA8+a8+VLPFVMxIjaUVNXXbmSWUyQ4d3onbYyyr
6vitoKFLufc=
=NuBE
-----END PGP SIGNATURE-----

--=-/gHZ9GdwrRe0/87jatql--
