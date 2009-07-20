From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getaddrinfo - too many recvmsg calls
Date: Mon, 20 Jul 2009 09:55:20 +0200
Message-ID: <4A6422E8.9000001@gmail.com>
References: <dffc28000907200005p7effca1cif4060b15be99e84@mail.gmail.com> <200907201014.18063.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Zsolt SZALAI <zs.szalai@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50505 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbZGTHz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 03:55:29 -0400
In-Reply-To: <200907201014.18063.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont a =E9crit :
> On Monday 20 July 2009 10:05:56 ext Zsolt SZALAI wrote:
>> The sanitycheck is now really simple, just a
>>     addrinfo hints =3D { 0, AF_INET, 0, 0, 0, NULL, NULL, NULL };
>>     int result =3D getaddrinfo(ipAddress, NULL, &hints, &addresses);
>> call.
>=20
> What the heck is this supposed to do?
> This piece of code tries to resolve <ipAddress> as numerical IPv4 add=
ress *or*=20
> a DNS hostname.
>=20
> If you want to check that a string is a valid IP address, call inet_p=
ton(). If=20
> you want to check that an IP address is assigned to the system, creat=
e a=20
> socket and bind to that address.
>=20

Yes, but beware of ip_nonlocal_bind option (/proc/sys/net/ipv4/ip_nonlo=
cal_bind).

If set to one, bind() will not tell you if address is assigned to the s=
ystem.
