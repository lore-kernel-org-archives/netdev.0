From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Fri, 16 Dec 2016 11:26:55 +0100
Message-ID: <201612161126.55249@pali>
References: <201611111820.52072@pali> <1481816017.2090.2.camel@Pali-Nokia-N900> <76365770-f5ba-9565-3fca-710518f64d81@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3012255.dWKzLERT7X";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        "linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <76365770-f5ba-9565-3fca-710518f64d81-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart3012255.dWKzLERT7X
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 15 December 2016 21:12:47 Arend Van Spriel wrote:
> On 15-12-2016 16:33, Pali Roh=C3=A1r wrote:
> > On Thu Dec 15 09:18:44 2016 Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> >> (Adding Luis because he has been working on request_firmware()
> >> lately)
> >>=20
> >> Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> >>>>> So no, there is no argument against... request_firmware() in
> >>>>> fallback mode with userspace helper is by design blocking and
> >>>>> waiting for userspace. But waiting for some change in DTS in
> >>>>> kernel is just nonsense.
> >>>>=20
> >>>> I would just mark the wlan device with status =3D "disabled" and
> >>>> enable it in the overlay together with adding the NVS & MAC
> >>>> info.
> >>>=20
> >>> So if you think that this solution make sense, we can wait what
> >>> net wireless maintainers say about it...
> >>>=20
> >>> For me it looks like that solution can be:
> >>>=20
> >>> extending request_firmware() to use only userspace helper
> >>=20
> >> I haven't followed the discussion very closely but this is my
> >> preference what drivers should do:
> >>=20
> >> 1) First the driver should do try to get the calibration data and
> >> mac
> >>=20
> >>        address from the device tree.
> >=20
> > Ok, but there is no (dynamic, device specific) data in DTS for
> > N900. So 1) is noop.
>=20
> Uhm. What do you mean? You can propose a patch to the DT bindings [1]
> to get it in there and create your N900 DTB or am I missing
> something here. Are there hardware restrictions that do not allow
> you to boot with your own DTB.

What is [1]?

N900's bootloader does not support DTB and it does not pass any DTB. It=20
boots kernel in ATAGs mode. What we are doing is appending DTB compiled=20
from kernel sources to end of zImage.

But that appended DTB cannot contains device specific nodes (e.g.=20
calibration data for device) as zImage is there for any N900 device, not=20
just only one.

> >> 2) If they are not in DT the driver should retrieve the
> >> calibration data
> >>=20
> >>        with request_firmware(). BUT with an option for user space
> >>        to implement that with a helper script so that the data
> >>        can be created dynamically, which I believe openwrt does
> >>        with ath10k calibration data right now.
> >=20
> > Currently there is flag for request_firmware() that it should
> > fallback to user helper if direct VFS access not find needed
> > firmware.
> >=20
> > But this flag is not suitable as /lib/firmware already provides
> > default (not device specific) calibration data.
> >=20
> > So I would suggest to add another flag/function which will primary
> > use user helper.
>=20
> I recall Luis saying that user-mode helper (fallback) should be
> discouraged, because there is no assurance that there is a user-mode
> helper so you might just be pissing in the wind. The idea was to have
> a dedicated API call that explicitly does the request towards
> user-space.
>=20
> By the way, are we talking here about wl1251 device or driver as you
> also mentioned wl12xx? I did not read the entire thread.

Yes, we are talking about wl1251 device, which is in Nokia N900 and=20
wl1251.ko and wl1251_spi.ko drivers.

I mentioned wl12xx as it already uses similar approach with mac address=20
via request_firmware(). And as those drivers are very similar plus from=20
one manufactor and in same kernel folder I mentioned similar API for=20
consistency...

=2D-=20
Pali Roh=C3=A1r
pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org

--nextPart3012255.dWKzLERT7X
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhTwW8ACgkQi/DJPQPkQ1Ie+ACfaU2DC+p2J0e1YY2rYeziDmV2
uaEAn0+7iL3GAKK+JA+mrNDKCpajq9Ge
=1AHA
-----END PGP SIGNATURE-----

--nextPart3012255.dWKzLERT7X--
