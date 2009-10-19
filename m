From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: [PATCH] IPv4: skip loopback checksums in ip_rcv()
Date: Mon, 19 Oct 2009 23:34:29 +0200
Message-ID: <200910192334.29770.schmto@hrz.tu-chemnitz.de>
References: <200910192134.02125.schmto@hrz.tu-chemnitz.de> <200910192256.52780.schmto@hrz.tu-chemnitz.de> <4ADCD5E1.7060400@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jessica.hrz.tu-chemnitz.de ([134.109.132.47]:33415 "EHLO
	jessica.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757727AbZJSVe1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 17:34:27 -0400
In-Reply-To: <4ADCD5E1.7060400@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet:
> Torsten Schmidt a =E9crit :
>> Eric Dumazet wrotes:
>>> This is bogus IMHO.
>>>
>>> One bit could be corrupted in iph, and ntohl(iph->daddr) becomes 0x=
7fxxyyzz,
>>> we then accept a bogus frame. This is a RFC violation.
>>>
>>> This also slows down non loopback devices, adding an extra test.
>>>
>>> ip_fast_csum() is really fast (about 16 instructions).
>>=20
>> Yes, you are right. So it would be better to only skip csum if *dev =
is=20
>> our loopback interface ? Right ?
>=20
> An application could send a bogus IP packet using RAW interface, and =
we still should
> check IP checksum before delivering this packet, even on loopback dev=
ice.

Yes, then we should fix this comment in ip_rcv():

	RFC1122: 3.2.1.2 MUST silently discard any IP frame that fails the che=
cksum.
	Is the datagram acceptable?
	1.	Length at least the size of an ip header
	2.	Version of 4
->	3.	Checksums correctly. [Speed optimisation for later, skip loopback=
 checksums]
	4.	Doesn't have a bogus length

Right ?
