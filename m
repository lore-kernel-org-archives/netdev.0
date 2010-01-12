From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 19:08:19 +0100
Message-ID: <4B4CBA93.4090909@gmail.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com> <4B4CA4E5.7030800@gmail.com> <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Kosin <JKosin@intcomgrp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754463Ab0ALSIn@vger.kernel.org>
In-Reply-To: <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
