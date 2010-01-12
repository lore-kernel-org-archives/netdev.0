From: "James Kosin" <JKosin@intcomgrp.com>
Subject: RE: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 14:03:46 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD36740289741C@MAILSRV.intcomgrp.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com> <4B4CA4E5.7030800@gmail.com> <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com> <4B4CBA93.4090909@gmail.com> <3DBBD805E3BA064A87F551C0E8BD367402897418@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "James Kosin" <JKosin@intcomgrp.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server109h.appriver.com ([72.32.253.92]:4285 "EHLO
	server109.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754597Ab0ALTCF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 14:02:05 -0500
Content-class: urn:content-classes:message
In-Reply-To: <3DBBD805E3BA064A87F551C0E8BD367402897418@MAILSRV.intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/2010 1:50 PM, James Kosin wrote:
> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-owner@v=
ger.kernel.org] On Behalf Of Eric Dumazet
> Sent: Tuesday, January 12, 2010 1:08 PM
> To: James Kosin
> Cc: linux-kernel@vger.kernel.org; Linux Netdev List
> Subject: Re: arm: Optimization for ethernet MAC handling at91_ether.c
>=20
> Le 12/01/2010 18:51, James Kosin a =E9crit :
>> On 1/12/2010 11:40 AM, Eric Dumazet wrote:
>=20
>=20
> I know.  Actually, I am using the hardware; and the part is capable o=
f more than this driver is displaying.
>=20
> 1)  The part is able to queue up two packets (1) actively being trans=
mitted, and (1) queued up behind that packet.  The driver doesn't explo=
it this; probably because this would cause some confusion, since we wou=
ldn't really know which packet failed when this happens.
>=20
> 2)  TX performance is so..so.  With bing on another computer using '-=
z' option it is reporting a fairly good value of 74Mbps.  I'll have to =
try with a re-compiled kernel at some point to give better feedback if =
we can improve this more.
>=20
> Your interpretation makes some sense on the transmit side.  The RX cu=
rrently has a DMA queue that extends to a depth of 9 (currently).  So g=
etting one transmit out before checking the RX may improve things a bit=
=2E
>=20

Scratch that.  The interrupt doesn't queue up or send another packet di=
rectly.  So, it wouldn't help on performance here.  But, may in other i=
mplementations that queue/transmit packets in the ISR.  At least in the=
 case where the transmitter is limited to one.

James
