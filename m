From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with
 bridge-nf-call-ip(6)tables=0
Date: Tue, 03 Jan 2012 18:42:41 +0100
Message-ID: <4F033E11.5060707@nod.at>
References: <4F025A07.2000304@nod.at> <1325597164-13459-1-git-send-email-richard@nod.at> <1325597164-13459-2-git-send-email-richard@nod.at> <20120103081521.2fec3a29@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBDF9393B90E3ECC436D4C566"
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120103081521.2fec3a29@nehalam.linuxnetplumber.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBDF9393B90E3ECC436D4C566
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 03.01.2012 17:15, schrieb Stephen Hemminger:
> On Tue,  3 Jan 2012 14:26:04 +0100
> Richard Weinberger <richard@nod.at> wrote:
>=20
>> If net.bridge.bridge-nf-call-iptables or net.bridge.bridge-nf-call-ip6=
tables
>> are set to zero xt_physdev has no effect because skb->nf_bridge has no=
t been set up.
>>
>> Signed-off-by: Richard Weinberger <richard@nod.at>
>=20
> I am not sure if this is a valid configuration. The setting of sysctl i=
s saying
> "don't do iptables on bridge (since I won't be using it)" and then you =
are later
> doing iptables and expecting the settings as if the iptables setup was =
being
> done.

I don't think so.

Also rules like this one are broken:
iptables -A INPUT -i bridge0 -m physdev --physdev-in eth0 -j ...

No firewalling is done on the bridge, xt_physdev is only using some meta
information.

At least a big fat warning would be nice that xt_physdev does not work
if bridge-nf-call-iptables=3D0.
It took me some time to figure out why my firewall rule set gone nuts on
RHEL6...

> Instead, you should just enable the net.bridge.bridge-nf-call-iptables =
sysctl.
> If a distro chooses to disable it then you may have to do it explicitly=
=2E

Fedora and RHEL have net.bridge.bridge-nf-call-iptables=3D0 per default
due to KVM network performance issues.
I'm sure I'm not the only user of xt_physdev on RHEL and friends.

Thanks,
//richard


--------------enigBDF9393B90E3ECC436D4C566
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPAz4WAAoJEN9758yqZn9eXDgH/RmvXgoPKEQMuYnqs5w8wS11
ZSqJ3y36HGRvNuanMHj9Gqt1mGDhIS0SYSD0qIpX1ulDKeEg+WepphTDkxAqn//3
3WpSEVFPkDRccSy9Qm9/FZpkqNmjEsB0271iOcdb3XB16fkiO3DE3fA81mIQ9zSL
pyISulmVm43sGKsFFFrAi1VwezKEeUbDT7nwSUzcjhffpahYX7fPVv8uHYGh1mB2
79nfGNIxgQFXpbMUzr8Y1V3V2aNtzEa/GAwDHkPlHj29dVwzCVZjFZ6uRzqeXlzk
0o9cfMx0RNWwJ90KhmraDLbD4hDy5de6E0/z4Ms3H+jrtkXmstX54tHvwLa98bo=
=7mt9
-----END PGP SIGNATURE-----

--------------enigBDF9393B90E3ECC436D4C566--
