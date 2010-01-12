From: "James Kosin" <JKosin@intcomgrp.com>
Subject: RE: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 13:42:19 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD367402897418@MAILSRV.intcomgrp.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com> <4B4CA4E5.7030800@gmail.com> <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com> <4B4CBA93.4090909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754036Ab0ALSkg@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4B4CBA93.4090909@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----Original Message-----
=46rom: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-owner@v=
ger.kernel.org] On Behalf Of Eric Dumazet
Sent: Tuesday, January 12, 2010 1:08 PM
To: James Kosin
Cc: linux-kernel@vger.kernel.org; Linux Netdev List
Subject: Re: arm: Optimization for ethernet MAC handling at91_ether.c

Le 12/01/2010 18:51, James Kosin a =E9crit :
> On 1/12/2010 11:40 AM, Eric Dumazet wrote:

>> If this happens once in a while, why do you want driver to retry the=
 transmit ?
>=20
> (a)  It would improve performance by allowing the ISR to handle the r=
e-transmit in this case.
> (b)  It would help in the case of small glitches that may happen from=
 external SDRAM without taxing the polling required to handle the re-tr=
ansmit of the packet... ie: overhead required to re-queue and initiate =
a packet delivery... since the packet is already scheduled for delivery=
 now.
>=20

OK, but then this also adds an extra check for each tx completion.

I dont have this piece of hardware, but seeing it has a one skb tx queu=
e (!),
I suppose TX performance is not very good anyway...


at91ether_interrupt() should probably handle tx completion before rx, t=
o feed
next frame faster.


---

I know.  Actually, I am using the hardware; and the part is capable of =
more than this driver is displaying.

1)  The part is able to queue up two packets (1) actively being transmi=
tted, and (1) queued up behind that packet.  The driver doesn't exploit=
 this; probably because this would cause some confusion, since we would=
n't really know which packet failed when this happens.

2)  TX performance is so..so.  With bing on another computer using '-z'=
 option it is reporting a fairly good value of 74Mbps.  I'll have to tr=
y with a re-compiled kernel at some point to give better feedback if we=
 can improve this more.

Your interpretation makes some sense on the transmit side.  The RX curr=
ently has a DMA queue that extends to a depth of 9 (currently).  So get=
ting one transmit out before checking the RX may improve things a bit.

James
