From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: ibss.c backtrace when batman-adv adds wireless
	interface
Date: Wed, 03 Feb 2016 18:09:40 +0100
Message-ID: <9390290.k4UIzlfAE4@bentobox>
References: <CA+5PVA4HVjsEw+j+HMDzO0gnQb4xTRwbAu4H2do3MU41QWvOvw@mail.gmail.com>
 <CA+5PVA55MSh-kKCLGcUV2uMkx+SqwuXY0WbONS8Q0mxh4+_gcw@mail.gmail.com>
 <1454514090.3083.8.camel@sipsolutions.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2938792.7NMr289Flz";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1454514090.3083.8.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart2938792.7NMr289Flz
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Wednesday 03 February 2016 16:41:30 Johannes Berg wrote:
> On Wed, 2016-02-03 at 10:26 -0500, Josh Boyer wrote:
> > On Wed, Feb 3, 2016 at 10:24 AM, Josh Boyer <jwboyer@fedoraproject.=
or
> > g> wrote:
> > > Hi All,
> > >=20
> > > We've had a user report the backtrace below when loading batman-a=
dv=20
> > > on
> > > his machine.  It looks like the cfg80211 layer is complaining abo=
ut
> > > a
> > > null bss returned, but I cannot tell if the rtlwifi driver or
> > > batman-adv is in error here.
> > >=20
> > > Thoughts?
> >=20
> > Sorry, forgot to include the link to the actual bug report:
> >=20
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D1304428
> >=20
> > Reporter says this is new with 4.3.y and did not happen on e.g.
> > 4.2.8.
> >=20
>=20
> AFAICT this should be a driver (or perhaps mac80211) issue, but I don=
't
> see any information about the driver used.

It doesn't really look like it is batman-adv specific. batman-adv also =
doesn't
be active because the message "batman_adv: bat0: Adding interface: " is=

missing.

batman-adv is also not responsible for the underlying device. So it wil=
l not
join IBSS and thus should not trigger the "wlp0s26u1u4: Selected IBSS B=
SSID"
seen in the log.

But that said, I already saw weirder things happen because of memory
corruptions. So I will not say that batman-adv cannot be the culprit bu=
t right
now I don't see how.

The user can also try (when he thinks that batman-adv is to blame) to b=
isect
the batman-adv versions via the git of the out-of-tree module [1]. The =
version [2]
from=204.1 should be roughly v2015.0 (b6ff92aa334083dee8a1f5f0c5aa0f7c4c2=
584cf),
v4.2 should be v2015.1 (95b64b1cef38340f48f4eba99689e0fb1feddcd0) and v=
4.3 should
not be newer than v2015.2 (e25bd38b0f8b4aeca85ef24884fa5eadd6270709). S=
o bisecting
between b6ff92aa334083dee8a1f5f0c5aa0f7c4c2584cf and
e25bd38b0f8b4aeca85ef24884fa5eadd6270709 (~6 steps) should cover it. I =
personally
would recommend to start on 4.2.8 with v2015.2
(e25bd38b0f8b4aeca85ef24884fa5eadd6270709)

Kind regards,
=09Sven=09

[1] https://git.open-mesh.org/batman-adv.git
[2] https://www.open-mesh.org/projects/open-mesh/wiki/Download#batman-a=
dv-in-the-Linux-tree

--nextPart2938792.7NMr289Flz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJWsjRUAAoJEF2HCgfBJntGJdgQAM0G9gPeRlEr4E/hDFpY/15a
bB4k288TzNgtLOPV0P9NYufj85KMEpAxhnqxIdIUj8Zy29V/vALYSzyD81ElEJUw
XTijOtanGfz7m51o+Pddr/Xh7CPjKaV2kYwXTcH+kWqw66CCp5N5oDorwTabCt4b
bhKPRZmbmk/Vktxhj6t66Lx2Y7xGnryjucYWL9mPfe7SOqb5RATmFjoOSBRZVYk5
YI36pD3YeXoP3n9PEOrfanz53nPiwd/5P5EbBgjjB7ANQe9mj5lowQFE3cv+84NS
WhYvisvRddGkRRcL5n7A+gblTluhRB7JZamajJSp+AWnhhxt4rHZMZtcrdKSTQVp
C+oape5Of5wU18uH5qtByutb+j8elh1WzFCyje0q7N3Ez4kBRcquPLoev/pdsdkx
XJyf21c8JhvkgFE/F/6XQaiqm6whL7cqPWgydX3vgF9oeB4tgWL5R0Ayq4b5QArQ
yD7Chf+Ucd0gE+8WRBk+rTtf1bMqUJAbueTErsEwxEO5ZopWidSdCLI/PxFhq9bw
rjfF0GZ9buwKTQ7wDeRRMjppg+VpuHmEqqNmCtjQIVQdA96SFV5Ssy2TzU7e7Hbd
8pyQTiAVQmin4yor2VgQG11W+Z26Af/DvEBwZdmRqG2ezdO0GtNx+9ud7mn9EXuQ
BP8r3BBHUNmkJmA2Z+gW
=Q/7S
-----END PGP SIGNATURE-----

--nextPart2938792.7NMr289Flz--
