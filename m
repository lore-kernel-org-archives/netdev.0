From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Wed, 12 Dec 2012 12:27:16 +0400
Message-ID: <20121212122716.1e71f644.bircoph@gmail.com>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	<20121013163639.87abca00.bircoph@gmail.com>
	<1350135860.21172.14606.camel@edumazet-glaptop>
	<20121014031119.a60263d6.bircoph@gmail.com>
	<20121021032543.09d1844f.bircoph@gmail.com>
	<1350823941.13333.2167.camel@edumazet-glaptop>
	<20121022073636.98462bc6.bircoph@gmail.com>
	<1350888489.8609.322.camel@edumazet-glaptop>
	<20121023012759.ca7f91d6.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__12_Dec_2012_12_27_16_+0400_GLqUUcNHCf1h4znH"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51704 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab2LLI1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 03:27:32 -0500
Received: by mail-lb0-f174.google.com with SMTP id gi11so346707lbb.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 00:27:30 -0800 (PST)
In-Reply-To: <20121023012759.ca7f91d6.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__12_Dec_2012_12_27_16_+0400_GLqUUcNHCf1h4znH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Tue, 23 Oct 2012 01:27:59 +0400 Andrew Savchenko wrote:
> On Mon, 22 Oct 2012 08:48:09 +0200 Eric Dumazet wrote:
[...]
> > Some driver or protocol stack is messing with skb->truesize, as
> > your /proc/net/udp file contains anomalies :
> >=20
> > $ cat /proc/net/udp
> >   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retr=
nsmt   uid  timeout inode ref pointer drops
> > ...
> >   323: 074A070A:007B 00000000:0000 07 FFFDF700:00000000 00:00000000 000=
00000   123        0 254469 2 ffff88003d581880 0
> > ...
> >   323: 00FCA8C0:007B 00000000:0000 07 FFFFF900:00000000 00:00000000 000=
00000     0        0 5187 2 ffff880039993880 0
> >=20
> > Its clearly not possible to get tx_queue =3D 0xFFFDF700 or 0xFFFFF900
> >=20
> > So what drivers handle following IP addresses : 192.168.252.0 , 10.7.74=
.7  ?
>=20
> 192.168.252.0 is handled by eth0 interface running on Realtek
> Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (10ec:8139) NIC.
> Kernel driver 8139too. This interface handles multiple subnetworks:
>=20
> # ip addr show eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast stat=
e UNKNOWN qlen 1000=20
> link/ether 00:80:48:30:ca:f3 brd ff:ff:ff:ff:ff:ff
> inet 10.51.15.126/25 brd 10.51.15.127 scope global eth0
> inet 192.168.252.0/31 scope global eth0
>=20
> 10.7.74.7 is an l2tp connection handled by ppp over l2tp:
> CONFIG_PPPOL2TP=3Dy
> It is running on top of eth0 described above.
>=20
> # ip addr show ppp0
> 65: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1400 qdisc pfifo_=
fast state UNKNOWN qlen 3
> link/ppp=20
> inet 10.7.74.7 peer 10.7.2.18/32 scope global ppp0

I updated kernel on this system to 3.7.0 and udp anomaly is still
present:

$ cat /proc/net/udp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt=
   uid  timeout inode ref pointer drops            =20
    0: 00000000:06A5 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5326 2 ffff88003dbf0a80 0         =20
    8: 00000000:7EAD 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5157 2 ffff8800398c2000 0         =20
   89: 00000000:90FE 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5101 2 ffff88003dbd3500 0         =20
  160: 0100007F:2745 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4598 2 ffff88003d612700 0         =20
  184: 0100007F:035D 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4774 2 ffff88003d612a80 0         =20
  217: 00000000:857E 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5195 2 ffff8800398c2700 0         =20
  318: 00000000:A9E3 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4782 2 ffff88003d612e00 0         =20
  335: 7E0F330A:01F4 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5303 2 ffff8800398c2e00 0         =20
  348: 00000000:0801 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5186 2 ffff8800398c2380 0         =20
  387: 7E0F330A:DE28 1400320A:06A5 01 00000000:00000000 00:00000000 0000000=
0     0        0 5332 4 ffff88003dbf0e00 0         =20
  400: 010013AC:0035 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4842 2 ffff88003d613880 0         =20
  400: 0100007F:0035 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4841 2 ffff88003d613500 0         =20
  414: 00000000:0043 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5273 2 ffff8800398c2a80 0         =20
  458: 00000000:006F 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4483 2 ffff88003d612000 0         =20
  459: 00000000:0270 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4507 2 ffff88003d612380 0         =20
  466: 00000000:0277 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4802 2 ffff88003d613180 0         =20
  470: 076A070A:007B 00000000:0000 07 FFFF4600:00000000 00:00000000 0000000=
0   123        0 5552 2 ffff880039974380 0         =20
  470: 010213AC:007B 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4986 2 ffff88003dbd3180 0         =20
  470: 010013AC:007B 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4985 2 ffff88003dbd2e00 0         =20
  470: 00FCA8C0:007B 00000000:0000 07 FFFFFB00:00000000 00:00000000 0000000=
0     0        0 4984 2 ffff88003dbd2a80 0         =20
  470: 7E0F330A:007B 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4983 2 ffff88003dbd2700 0         =20
  470: 0100007F:007B 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4982 2 ffff88003dbd2380 0         =20
  470: 00000000:007B 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 4975 2 ffff88003d613c00 0         =20
  484: FF0013AC:0089 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5316 2 ffff88003dbf0000 0         =20
  484: 010013AC:0089 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5315 2 ffff88003dbd3880 0         =20
  484: FF0213AC:0089 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5312 2 ffff8800398c3c00 0         =20
  484: 010213AC:0089 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5311 2 ffff8800398c3880 0         =20
  484: 00000000:0089 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5308 2 ffff8800398c3180 0         =20
  485: FF0013AC:008A 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5318 2 ffff88003dbf0700 0         =20
  485: 010013AC:008A 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5317 2 ffff88003dbf0380 0         =20
  485: FF0213AC:008A 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5314 2 ffff88003dbd3c00 0         =20
  485: 010213AC:008A 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5313 2 ffff88003dbd2000 0         =20
  485: 00000000:008A 00000000:0000 07 00000000:00000000 00:00000000 0000000=
0     0        0 5309 2 ffff8800398c3500 0

The bug hasn't shown up yet, I'll need to wait for about a week to see
if it is reproducible.

Best regards,
Andrew Savchenko

--Signature=_Wed__12_Dec_2012_12_27_16_+0400_GLqUUcNHCf1h4znH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlDIP+8ACgkQ2anJBBcsZw2c5gCfa0YkkXaV6eCilQ9bMOaBck6d
lvQAoMXN9E1HlR5wbPCwlRbBXtbrqt/r
=z/oJ
-----END PGP SIGNATURE-----

--Signature=_Wed__12_Dec_2012_12_27_16_+0400_GLqUUcNHCf1h4znH--
