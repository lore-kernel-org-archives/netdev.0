From: Gilder <gilder@interia.pl>
Subject: Problem with ARPING broadcasting
Date: 27 Jul 2010 15:34:56 +0200
Message-ID: <20100727133456.1AE93313C62@f48.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1804289383-1280237696=:46131"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo.poczta.interia.pl ([217.74.65.205]:54678 "EHLO
	smtpo.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab0G0NrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 09:47:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0-1804289383-1280237696=:46131
Content-Type: TEXT/plain; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

New version of ARPing commited at 2010-04-12 by YOSHIFUJI Hideaki has a pro=
blem with sending proper network packet's - broadcast address isn't ff:ff:f=
f:ff:ff:ff but ff:XX:ff:XX:00:XX ( where XX is current device MAC fragments=
 ). =0A=0AThat cause a problem, that not all devices respond to that arp-br=
oadcast. =0A=0AI've attached small patchfile to solving this problem.

------------------------------------------------------------------------ Wakacje na kredyt bez odsetek? Sprawdz mozliwosci kart kredytowych MultiBanku!	
http://linkint.pl/f27a7

--0-1804289383-1280237696=:46131
Content-Type: APPLICATION/octet-stream
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <arping.patch4DBB919C@91D3195.3D3D024F>
Content-Disposition: ATTACHMENT; FILENAME="arping.patch"

337,339c337,340=0A< =09for (p =3D ba, ch =3D 0; p < ba + balen; p++, ch++) =
{=0A< =09    *p =3D strtoul(brdcast->value + ch * 3, NULL, 16);=0A< =09}=0A=
---=0A> =0A> =09for (p =3D ba, ch =3D 0; p < ba + balen; p++, ch +=3D 3)=0A=
> =09=09*p++ =3D strtoul(brdcast->value + ch * 3, NULL, 16);=0A> =0A
--0-1804289383-1280237696=:46131--
