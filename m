From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Sat, 14 May 2011 14:54:16 +0800
Message-ID: <4DCE2718.1030103@cn.fujitsu.com>
References: <20110504181813.GA17547@redhat.com> <20110505152644.GA8459@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	herbert@gondor.hengli.com.au
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50482 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab1ENGyS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 02:54:18 -0400
In-Reply-To: <20110505152644.GA8459@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw wrote, at 05/05/2011 11:26 PM:
> On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
>> BTW, I just noticed that net-next spits out
>> many of the following when I run any VMs:
> [...]
>> tap0: Features changed: 0x40004040 -> 0x401b4849
>=20
> Before this message, userspace called ioctl(TIOCSETOFFLOAD)
> turning offloads on.
>=20
>> tap0: Dropping NETIF_F_SG since no checksum feature.
>> tap0: Dropping NETIF_F_GSO since no SG feature.
>> tap0: Features changed: 0x401b4849 -> 0x40004040
>=20
> And then it probably called ioctl(TIOCSETOFFLOAD) again, disabling th=
em.

[263958.167861] tap1: Dropping NETIF_F_SG since no checksum feature.
[263958.167866] tap1: Dropping NETIF_F_GSO since no SG feature.
[263958.167871] tap1: Features changed: 0x401b4849 -> 0x40004040

See same warning message using tunctl to create a tap device on net-nex=
t tree.
But on RHEL6, no warning message.

strace shows no TUNSETOFFLOAD to be used.
Seems that checksum feature is not set when creating tap0 interface.

#strace tunctl -u root -t tap1
open("/dev/net/tun", O_RDWR)            =3D 3
ioctl(3, TUNSETIFF, 0x7fff789ada10)     =3D 0
ioctl(3, TUNSETOWNER, 0)                =3D 0
ioctl(3, TUNSETPERSIST, 0x1)            =3D 0
fstat(1, {st_mode=3DS_IFCHR|0620, st_rdev=3Dmakedev(136, 0), ...}) =3D =
0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x7f66aeed9000
write(1, "Set 'tap1' persistent and owned "..., 41Set 'tap1' persistent=
 and owned by uid 0
) =3D 41
exit_group(0)                           =3D ?


--=20
Best Regards
-----
Shan Wei
