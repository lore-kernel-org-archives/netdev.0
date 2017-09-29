From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: netlink backwards compatibility in userspace tools
Date: Fri, 29 Sep 2017 17:50:32 +0000
Message-ID: <8660AD5D-BC3D-4B7A-8DF7-500E74E31045@intel.com>
References: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_D5B1A825-6305-4209-AAB3-4D4ADBA73D2E";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_D5B1A825-6305-4209-AAB3-4D4ADBA73D2E
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Sep 29, 2017, at 3:22 AM, Jason A. Donenfeld <Jason@zx2c4.com> =
wrote:
>=20
> Hi guys,
>=20
> One handy aspect of Netlink is that it's backwards compatible. This
> means that you can run old userspace utilities on new kernels, even if
> the new kernel supports new features and netlink attributes. The wire
> format is stable enough that the data marshaled can be extended
> without breaking compat. Neat.
>=20
> I was wondering, though, what you think the best stance is toward
> these old userspace utilities. What should they do if the kernel sends
> it netlink attributes that it does not recognize? At the moment, I'm
> doing something like this:
>=20
> static void warn_unrecognized(void)
> {
>    static bool once =3D false;
>    if (once)
>        return;
>    once =3D true;
>    fprintf(stderr,
>        "Warning: this program received from your kernel one or more\n"
>        "attributes that it did not recognize. It is possible that\n"
>        "this version of wg(8) is older than your kernel. You may\n"
>        "want to update this program.\n");
> }
>=20
> This seems like a somewhat sensible warning, but then I wonder about
> distributions like Debian, which has a long stable life cycle, so it
> frequently has very old tools (ancient iproute2 for example). Then,
> VPS providers have these Debian images run on top of newer kernels.
> People in this situation would undoubtedly see the above warning a lot
> and not be able to do anything about it. Not horrible, but a bit
> annoying. Is this an okay annoyance? Or is it advised to just have no
> warning at all? One idea would be to put it behind an environment
> variable flag, but I don't like too many nobs.
>=20
> I'm generally wondering about attitudes toward this kind of userspace
> program behavior in response to newer kernels.
>=20
> Thanks,
> Jason

That seems like a bit much. Consider only emitting a message with the =
use of a verbose flag - or two. Even then the message should be =
shortened - the first sentence is entirely adequate even in verbose =
mode.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_D5B1A825-6305-4209-AAB3-4D4ADBA73D2E
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJZzofoAAoJEDwO/+eO4+5uas4QAKoJcTL7A/CjgP8fDp4y+1pN
EwET5l3UNeL7Wgo1KXhmqepkqJ1eNQIjpLjyH3vMJSe4+hZHvL/xo04l+jLmioIz
gpf2/3+s88YaEf2Xz8dtq40zwrIWkx2mE+hf7c97yA7jRWKlmpWxZNL0oKxhiFTu
YeLZCPCiT4rtPAhksV9t4CiNaGQbYuDUyUCjSe9W9Antk5sId4mHJYetdB2M2fYL
z8SIlXwLfacbDtt7imWZTvWKcNGj9jwGAuGk7AFmKA/E7Nkv7OWzlqOZpAqnVWb7
7YxwRZY4X9uALo1b3iQcODnuytwJWoivfntEgOQ0ZPTt/YVGjA6UEfxapTtLFYVu
NS1eCZqYaGekQHLCyXscQRXw2mkAc3pbfV5YoozNjgWhtpIGJ0GgeCVsEcliY4V1
7H5Efma4A2mZbLx1Ml/BnthTZb7w6qO+jZCZaKanu+fzrkEYnqpn7kO8U84aXf3g
H52BObpUcpdOYUL04BmbFWdSSQfVVX9YSy7/qMaFnIajkNBjlsU2/5NzZLjTcrmV
oUsgEckRQu2wXaRg3SnUwFTigoKq684R2ITbprv2R14yIddCSBYlakpa5b4BBpn3
GaaIswfcowIUe15ebbw1L8QrDXg+JiNr0mb8CwsoEmtppvdAEeJtDZkVl+k2BRAD
ZmKlVfookOZy1NGXDWg9
=2t+D
-----END PGP SIGNATURE-----

--Apple-Mail=_D5B1A825-6305-4209-AAB3-4D4ADBA73D2E--
