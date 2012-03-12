From: Roberto Suarez Soto <robe@allenta.com>
Subject: High ksoftirq CPU load, high latency, __xfrm4_find_bundle likely
 culprit?
Date: Mon, 12 Mar 2012 16:50:35 +0100
Message-ID: <4F5E1B4B.2070807@allenta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns313441.ovh.net ([188.165.228.125]:49667 "EHLO
	mohawk.allenta.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab2CLP5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 11:57:16 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mohawk.allenta.com (Postfix) with ESMTP id EEE6AC84C75
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 16:50:23 +0100 (CET)
Received: from mohawk.allenta.com ([127.0.0.1])
	by localhost (mohawk.allenta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fPvpyj+Nr4YA for <netdev@vger.kernel.org>;
	Mon, 12 Mar 2012 16:50:22 +0100 (CET)
Received: from [192.168.1.246] (protagoras.allenta.com [212.51.59.18])
	by mohawk.allenta.com (Postfix) with ESMTPSA id 40A8EBBFCC4
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 16:50:22 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	we've got a load problem in one of our IPSec gateways, running openswa=
n=20
1:2.6.28+dfsg-5+squeeze1 and kernel 2.6.32-5-686-bigmem (Debian Squeeze=
). The=20
symptoms are:

	- High ksoftirqd load
	- High network latency (pings up to 200ms in the same switch)
	- At those times, "perf top" shows a high CPU usage for syscalls=20
__xfrm4_find_bundle, des3_ede_decrypt and des3_ede_encrypt

	We've already discarded NIC problems, and traffic is not so high as to=
=20
justify these problems. In particular, we have a bond0 for the two NICs=
 that=20
deal with LAN traffic, and when the problem appears the stats are quite=
 tame:=20
3k-4k packets per second, 3MBytes/s.

	We're migrating away from 3DES to mitigate this problem, but the real =
culprit=20
seems to be __xfrm4_find_bundle. Is there something wrong? Is it a bug,=
 or=20
something that we've not tuned properly?

	Thanks,

--=20
         Roberto Suarez Soto                             Allenta Consul=
ting
         robe@allenta.com                                   www.allenta=
=2Ecom
                                                            +34 881 922=
 600

Este correo electr=F3nico contiene informaci=F3n estrictamente confiden=
cial y
es de uso exclusivo del destinatario, quedando prohibida a cualquier ot=
ra
persona su revelaci=F3n, copia, distribuci=F3n, o el ejercicio de cualq=
uier
acci=F3n relativa a su contenido. Si ha recibido este mensaje por error=
, por
favor conteste a su remitente mediante correo electr=F3nico y proceda a
borrarlo de su sistema. Rogamos nos comunique inmediatamente sobre
cualquier inconveniente que pueda tener usted en relaci=F3n al env=EDo =
de este
tipo de correo electr=F3nico.

Sus datos personales ser=E1n tratados de forma confidencial y no ser=E1=
n
cedidos a terceros ajenos a ALLENTA CONSULTING, S.L. En cualquier caso,
podr=E1 ejercer los derecho de oposici=F3n, acceso, rectificaci=F3n y c=
ancelaci=F3n
de acuerdo con lo establecido en la Ley Org=E1nica 15/99, de 13 de dici=
embre,
de Protecci=F3n de Datos de Car=E1cter Personal dirigi=E9ndose a ALLENT=
A
CONSULTING, S.L. en C/Enrique Mari=F1as 36, 2=BA piso, oficina 8, 15009=
 =96 A
Coru=F1a  o en la direcci=F3n de electr=F3nico info@allenta.com
