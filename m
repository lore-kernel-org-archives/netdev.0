From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 20:24:43 +0100
Message-ID: <4B4CCC7B.8040609@gmail.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com> <4B4CA4E5.7030800@gmail.com> <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com> <4B4CBA93.4090909@gmail.com> <3DBBD805E3BA064A87F551C0E8BD367402897418@MAILSRV.intcomgrp.com> <3DBBD805E3BA064A87F551C0E8BD36740289741C@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Kosin <JKosin@intcomgrp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49651 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753849Ab0ALTYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 14:24:48 -0500
In-Reply-To: <3DBBD805E3BA064A87F551C0E8BD36740289741C@MAILSRV.intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/01/2010 20:03, James Kosin a =E9crit :
>=20
> Scratch that.  The interrupt doesn't queue up or send another packet =
directly.  So, it wouldn't help on performance here.  But, may in other=
 implementations that queue/transmit packets in the ISR.  At least in t=
he case where the transmitter is limited to one.
>=20

It could, at least on SMP. tx completion wakes a blocked sender, while
this cpu continue with RX handling (possibly expensive)

But even on UP, doing tx completion before rx handling allows
a better reuse of skb just freed (and partly present in cpu cache, if a=
vailable).

Start of IRQ

1) tx completion
    -> free a skb

2) rx handling:
    -> allocate an skb, kmalloc() reuses previous one, still in cpu cac=
he.

End of IRQ
