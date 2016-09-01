From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC 1/9] ipv6: implement dataplane support for rthdr type 4
 (Segment Routing Header)
Date: Thu, 1 Sep 2016 15:11:08 +0200
Message-ID: <57C828EC.60501@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be> <1472226767-9904-2-git-send-email-david.lebrun@uclouvain.be> <9a7b8a77-5832-1038-00f8-b24f8e7b8d4c@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="P8rcjIrOGVfot8tI21eeUhG76W8QbMu3F"
To: <nicolas.dichtel@6wind.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:46062 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbcIANKt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 09:10:49 -0400
In-Reply-To: <9a7b8a77-5832-1038-00f8-b24f8e7b8d4c@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--P8rcjIrOGVfot8tI21eeUhG76W8QbMu3F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 08/31/2016 04:51 PM, Nicolas Dichtel wrote:
> Thanks for proposing this feature. It would be great to have it upstrea=
m.
>=20

Thanks for the feedback :)

> [snip]
>> +config IPV6_SEG6
>> +	bool "IPv6: Segment Routing support"
>> +	depends on IPV6
>> +	---help---
>> +	  Experimental support for IPv6 Segment Routing dataplane as defined=

>> +	  in IETF draft-ietf-6man-segment-routing-header-01. This option
>> +	  enables the processing of SR-enabled packets allowing the kernel
>> +	  to act as a segment endpoint (intermediate or egress).
>> +
>> +	  If unsure, say N.
>> +
> I don't think that the option is needed. At the end, every distribution=
s will
> turn it on.
>=20

Are you sure ? This is a rather specific feature, used in specific
environments. Not that I would mind removing the option if it makes sense=
=2E

> [snip]
>> +#ifdef CONFIG_IPV6_SEG6
>> +	{
>> +		.procname	=3D "seg6_enabled",
>> +		.data		=3D &ipv6_devconf.seg6_enabled,
>> +		.maxlen		=3D sizeof(int),
>> +		.mode		=3D 0644,
>> +		.proc_handler	=3D proc_dointvec,
>> +	},
>> +#endif
> Don't forget to document this option in Documentation/networking/ip-sys=
ctl.txt.
> Don't forget to explain how 'all' works ;-)
> It would be nice to also add it in netconf subsystem (see 'git grep net=
conf
> net/ipv6').
>=20

Right ! I didn't think of that doc file. Noted for netconf.

> [snip]
>> +#ifdef CONFIG_IPV6_SEG6
>> +static int ipv6_srh_rcv(struct sk_buff *skb)
>> +{
>> +	struct inet6_skb_parm *opt =3D IP6CB(skb);
>> +	struct in6_addr *addr =3D NULL, *last_addr =3D NULL, *active_addr =3D=
 NULL;
>> +	struct ipv6_sr_hdr *hdr;
>> +	struct net *net =3D dev_net(skb->dev);
>> +	int cleanup =3D 0;
>> +	struct inet6_dev *idev;
>> +	int accept_seg6;
> nit: better to follow the 'reverse christmas tree' scheme when declarin=
g variables.
>=20

Noted


>> +
>> +	ip6_route_input(skb);
> The destination address has now changed and the packet is routed again.=

> skb->nfct is not updated, it is intentional? I'm asking me if it's conc=
eptually
> right.
>=20

I fail to see any usecase where conntrack would run on SR-enabled
packets. Things such as NAT would just defeat the purpose.

David


--P8rcjIrOGVfot8tI21eeUhG76W8QbMu3F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlfIKOwACgkQjbzn67sZ6ANN8gCfQegX4gbqm3SCvy0wqlv32SwV
NKAAniE+vbt3RVgzW0ixVT4vcoetgWmF
=wSf7
-----END PGP SIGNATURE-----

--P8rcjIrOGVfot8tI21eeUhG76W8QbMu3F--
