From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with
 bridge-nf-call-ip(6)tables=0
Date: Thu, 05 Jan 2012 00:13:29 +0100
Message-ID: <4F04DD19.601@nod.at>
References: <4F025A07.2000304@nod.at> <1325597164-13459-1-git-send-email-richard@nod.at> <1325597164-13459-2-git-send-email-richard@nod.at> <20120103081521.2fec3a29@nehalam.linuxnetplumber.net> <4F033E11.5060707@nod.at> <4F0361D7.3000602@pandora.be> <4F03650D.8050200@nod.at> <4F049290.3090803@pandora.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB4BE8FEDA6EBD4B15340840A"
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F049290.3090803@pandora.be>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB4BE8FEDA6EBD4B15340840A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 04.01.2012 18:55, schrieb Bart De Schuymer:
> Op 3/01/2012 21:29, Richard Weinberger schreef:
>> Am 03.01.2012 21:15, schrieb Bart De Schuymer:
>>> The documentation is probably not explicit enough, but I would keep t=
he
>>> behavior as it is now. Setting bridge-nf-call-iptables to 0 makes
>>> iptables behave as if bridge-netfilter was not enabled at compilation=
=2E
>>> Anyway, your patch is almost certainly flawed since the fact that
>>> skb->nf_bridge can be NULL is used as part of the logic in
>>> br_netfilter.c: it indicates that bridge-nf-call-iptables was 0 when =
the
>>> packet was first processed by bridge-netfilter and should therefore n=
ot
>>> be given to iptables in any other netfilter hook.
>> Thanks for the explanation!
>>
>> Wouldn't it make sense to check for bridge-nf-call-iptables in
>> xt_physdev?
>> So that the user gets warned that his iptables rule will never match..=
=2E
>=20
> We don't want to introduce module dependencies between the bridge modul=
e
> and the iptables physdev match.

CONFIG_NETFILTER_XT_MATCH_PHYSDEV depends anyway on
CONFIG_BRIDGE_NETFILTER...

> We could add a message to the syslog whenever these proc settings are
> changed (in br_netfilter.c::brnf_sysctl_call_tables()).
>=20

Let's export brnf_call_iptables and brnf_call_ip6tables, such that
physdev_mt_check() can notify the user that his iptables rule will have
no effect.

Thanks,
//richard


--------------enigB4BE8FEDA6EBD4B15340840A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPBN0eAAoJEN9758yqZn9eNVoIAKsFri6hfQdyZKl9FsCcHC4r
kJGjdm2AWAocQb8/yYajPylhrJbS5WK103SjfUXFfRuPdTAr8VBiazo8zrqqy7Oy
+s7iLv1k/tQpS8GcSom67fZOIpRnjshRNMaFIw0IBk1A7CBbJU1HzQaqplSCMAJS
NeiCVaJbWfOFafiKC8VZDv8gIro0WbroNPJwC+DhzhnDi8Zq2534K4nB1R53JR0W
wMOJa+QWi5OslHas9a3ZCo7trLxcp+lYpAa9/Q/4u+A82GSMV9t2IRtvcDSAb72o
cBhI9WTzi2rGUVmL6RBqsXiFFgbSVtCr8GW0n5c4s0OmyyOzAkC9gZqjQjnCVlM=
=kali
-----END PGP SIGNATURE-----

--------------enigB4BE8FEDA6EBD4B15340840A--
