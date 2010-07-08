From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bug handling devices with weird names
Date: Thu, 8 Jul 2010 10:27:47 -0700
Message-ID: <20100708102747.66d0ad78@s6510>
References: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?ISO-8859-1?B?TWFydO1u?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35687 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758312Ab0GHR1u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 13:27:50 -0400
In-Reply-To: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jul 2010 19:08:07 +0200
Mart=EDn Ferrari <martin.ferrari@gmail.com> wrote:

> According to dev_valid_name (net/core/dev.c), a valid device name is
> one that doesn't include spaces, slashes, and is not "." or "..". But
> if I create a device called "foo:", some operations fail:
>=20
> # ip link add name foo: type dummy
> # ip link list foo:
> 155: foo:: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN ioctl(SIO=
CGIFXQLEN)
> failed: No such device
>=20
>     link/ether 92:7f:4d:0d:8f:57 brd ff:ff:ff:ff:ff:ff
>=20
> Strace reveals that the problem occurs when executing an ioctl:
>=20
> ioctl(4, SIOCGIFTXQLEN, {ifr_name=3D"foo:", ???}) =3D -1 ENODEV (No s=
uch device)
>=20
> ifconfig gets completely lost, of course:
>=20
> $ /sbin/ifconfig foo:
> foo:: error fetching interface information: Device not found
>=20
> ioctl(5, SIOCGIFFLAGS, {ifr_name=3D"foo:", ???}) =3D -1 ENODEV (No su=
ch device)
>=20
>=20
> So, is this fixable or iproute should stop using the ioctl interface?
> (dunno if netlink provides everything already)

Colons are used for the old IP aliasing. IP aliasing was an older way o=
f handling
multiple addresses per interface, and is not necessary anymore. The syn=
tax is
retained for legacy compatibility.
