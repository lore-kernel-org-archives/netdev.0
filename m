From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice regression?
Date: Fri, 30 Nov 2007 09:07:53 +0100
Message-ID: <474FC4D9.3020506@cosmosbay.com>
References: <pan.2007.11.29.23.42.52.661624@wizards.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Holger Hoffstaette <holger@wizards.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60312 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932355AbXK3IIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 03:08:01 -0500
In-Reply-To: <pan.2007.11.29.23.42.52.661624@wizards.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Hoffstaette a =E9crit :
> Hi -
>=20
> This regular Linux user and lkml lurker just noticed data corruption =
in
> ftp'ed files and narrowed it down to vsftpd using sendfile(). So far =
this
> has never caused problems in the past; I have not noticed this with
> 2.6.22.x but may have missed it. I do remember reading about some cha=
nges
> to the underlying splice stuff since .23 so that may have something t=
o do
> with it.
>=20
> The scenario:
>=20
> - created a file with known bit pattern on Linux server
> - ftp-got this file to Windows client: file has bad crc (yes, binary)
> - verified with another client: same result
>=20
> I have thus far eliminated (to the best of my knowledge) NICs, switch=
es,
> cables, the Windows FTP clients, the hard disk in the server (SATA, e=
xt3):
> nothing suspicious in any logs. Box is an AMD Sempron 2600+ with 1.5 =
GB
> RAM, added rt8169 card, Gentoo, vsftpd stable 2.0.5 - nothing fancy.
> Transferring the file with samba (interestingly with sendfile enabled=
) and
> via ftp but from /dev/shm repeatably works fine; pulling from disk cr=
eates
> bad crc, every time. The file is readable and can be copied, verified=
 etc.
> over and over so I'm sure that I'm not falling prey to a false positi=
ve.
> ifconfig indicates no dropped or otherwise corrupted packets.
> I noticed this first with 2.6.4-rc3, but also just tried the latest s=
table
> 2.6.23.9 with the same config, with no change in behaviour. After set=
ting
> vsftpd to use_sendfile=3DNO, gigs can be transferred without corrupti=
on.
>=20
> The data corruption is sporadic, but absolutely repeatable. The file =
with
> the known good pattern just contains multiple lines of:
>=20
> 012345678901234567890123456789012345678901234567890
> 012345678901234567890123456789012345678901234567890
> 012345678901234567890123456789012345678901234567890
> ..etc..
>=20
> A corrupted file is missing random characters, so that the corrupted =
lines
> looks like this (line numbers added by me):
>=20
> 19785: 012345678901234567890123456789012345678901234567890
> 19786: 01234567890123456789012345678901234567890123678901234567890
> 19787: 012345678901234567890123456789012345678901234567890
>=20
> or:
>=20
> 20074: 012345678901234567890123456789012345678901234567890
> 20075: 01234567890123456789012345678901234567890123012345678901234567=
890123456789012345678901234567890
> 20076: 012345678901234567890123456789012345678901234567890
>=20
> Again, other network or hd traffic shows no signs of gremlins; the bo=
x is
> perfectly stable, and turning sendfile on or off triggers/untriggers =
the
> corruption reliably.  I will try 2.6.22.x over the weekend, and befor=
e I
> bother lkml with dmesg/.config etc. I wanted to fish for initial thou=
ghts.
>=20

CC to netdev, it might concern network guys

Could you try with a test file containing unique patterns ?

like a 80 MB file :

#include <stdio.h>
main()
{
unsigned long ul;
for (ul =3D 0 ; ul < 10000000 ; ul++)
    printf("%8lu", ul);
return 0;
}


Thank you

