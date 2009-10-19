From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IPv4: skip loopback checksums in ip_rcv()
Date: Mon, 19 Oct 2009 23:10:57 +0200
Message-ID: <4ADCD5E1.7060400@gmail.com>
References: <200910192134.02125.schmto@hrz.tu-chemnitz.de> <4ADCCF1A.7070301@gmail.com> <200910192256.52780.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33344 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757195AbZJSVKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 17:10:54 -0400
In-Reply-To: <200910192256.52780.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Torsten Schmidt a =E9crit :
> Eric Dumazet wrotes:
>> This is bogus IMHO.
>>
>> One bit could be corrupted in iph, and ntohl(iph->daddr) becomes 0x7=
fxxyyzz,
>> we then accept a bogus frame. This is a RFC violation.
>>
>> This also slows down non loopback devices, adding an extra test.
>>
>> ip_fast_csum() is really fast (about 16 instructions).
>=20
> Yes, you are right. So it would be better to only skip csum if *dev i=
s=20
> our loopback interface ? Right ?

An application could send a bogus IP packet using RAW interface, and we=
 still should
check IP checksum before delivering this packet, even on loopback devic=
e.

