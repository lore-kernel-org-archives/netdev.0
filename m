From: Matthew Thode <mthode@mthode.org>
Subject: Re: getting a list of naked interface names from iproute2
Date: Tue, 17 Feb 2015 22:45:06 -0600
Message-ID: <54E418D2.3020406@mthode.org>
References: <54E28630.4020200@mthode.org> <20150217102358.67b9d826@uryu.home.lan>
Reply-To: mthode@mthode.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lCJEItucIE1EvOHCbBm3Dl5Ov5wbHgxMS"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-82-208-22.static.grandenetworks.net ([216.82.208.22]:41023
	"EHLO mx1.mthode.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbBREpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 23:45:16 -0500
In-Reply-To: <20150217102358.67b9d826@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lCJEItucIE1EvOHCbBm3Dl5Ov5wbHgxMS
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/17/2015 09:23 AM, Stephen Hemminger wrote:
> On Mon, 16 Feb 2015 18:07:12 -0600
> Matthew Thode <mthode@mthode.org> wrote:
>=20
>> iproute2 seems to like to add @ and : info to it's output.  This makes=

>> parsing it hard for things like neutron (openstack).  I have a patch t=
o
>> slightly update it (still missing some things, I'll link it at the end=

>> if interested).  Is there a better way of getting interface names from=

>> iproute2 without having to strip out at characters like '@' and ':'?
>>
>> changeset in neutron: https://review.openstack.org/#/c/154128/
>> link to current code:
>> https://github.com/openstack/neutron/blob/master/neutron/agent/linux/i=
p_lib.py#L110-L131
>>
>> I'd appreciate your help, I'd rather not have to go through each link
>> type to pull it's delimiter, but if needed I guess it's needed.
>>
>=20
> Stop screenscraping, and use a real API.
> All of the above would work better:
>   1. Libc if_nameindex
>   2. Legacy ioctl(SIOCGIFCONF)
>   3. Netlink  NLMMSG_REQ (RTM_GETLINK)
>   4. Sysfs /sys/class/net
>=20
Do you happen to know a way to request it for a specific namespace?
going over the links in /sys/class/net only gets you the current
namespace (was the easiest method to do in python2.7).

--=20
Matthew Thode


--lCJEItucIE1EvOHCbBm3Dl5Ov5wbHgxMS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJU5BjSAAoJEGSje+quGaTo7dEP/0YUZ/v/NZMctKC571GnZlVL
jvjHikY+BvJM522ni6iggP59Ov82QSUfIKop6QwAlpxXjNfgpxc3Va21pQEVGOhD
9jMOMiTStdUjZhkJTGaSUFSerbZEOoeenI5CS8zTlg9cOSPWJicNhptNXTJTfl0H
2+Yz/dUJfzA1w6HJcPb/7Avozo2Ml8JLrZ5RF1HunIRm9bcY1k7tOwz6uRuPUAzN
v2KSwIx3/euqird35uIB5XgAsIUOnKYAVcKAS37rHiXV82NAYDhGkuwUdxNbe+ym
eBB78XJHRiHTJEaTdR27ZP3ikP9HrXY4tA8Jpv9rqgqIWYeD5bAccPaYNCKlziO5
nn9vAr+PTxx+XeA90U3F7pVCx2YbQUmphI4rKmF0f3dfBuoUj+JY06gJnWT3fMXx
gC1ltkS1TExMb1HUo9mMKQ9AA/B7J7XIOQxhVpZBAbWiin5PIBMgCVeRqn3w4h8R
3ifQI3TNyUZpWqjp1t/HrMXIZzh+umbY2UHdVzwEWIL5Xo5swIkTnQ/HGC4LsJhg
Jjg+TE2WUOxTLoECzT36uuXhZZsTcW0fUkFOf/Q4Siygf7G0P27nIZVzgeRag9jB
6Vlu1RC4SNKojjWruUV+TVpK/+586GzQ59O7FEqAfp3SYgWs+KJhkZwDcxL524aQ
YynnuDJcxNptfLSRfCDs
=0G9P
-----END PGP SIGNATURE-----

--lCJEItucIE1EvOHCbBm3Dl5Ov5wbHgxMS--
