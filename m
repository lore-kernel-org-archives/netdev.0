From: "James Kosin" <JKosin@intcomgrp.com>
Subject: RE: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 12:51:57 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com> <4B4CA4E5.7030800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751669Ab0ALRuQ@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4B4CA4E5.7030800@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/12/2010 11:40 AM, Eric Dumazet wrote:
> CC to netdev
>=20
> Le 12/01/2010 16:39, James Kosin a =E9crit :
>> Everyone,
>>
>> Since, a AT91_EMAC_TUND only happens when the transmitter is unable =
to
>> transfer the frame in time for a frame to be sent.  It makes sense t=
o
>> RETRY the packet in this condition in the ISR.
>> Or would this overcomplicate a simple task?
>>                 ... see below ...
>>
> ...
>=20
>>
>> ...
>> I do know there needs to be a bit more code then to handle the
>> successful case below this; but, this is enough to understand what I=
 am
>> talking about.  The UNDERRUN error should happen infrequently and in
>> ideal circumstances not happen at all.
>> =20
>=20
>=20
> If this happens once in a while, why do you want driver to retry the =
transmit ?

(a)  It would improve performance by allowing the ISR to handle the re-=
transmit in this case.
(b)  It would help in the case of small glitches that may happen from e=
xternal SDRAM without taxing the polling required to handle the re-tran=
smit of the packet... ie: overhead required to re-queue and initiate a =
packet delivery... since the packet is already scheduled for delivery n=
ow.

James
