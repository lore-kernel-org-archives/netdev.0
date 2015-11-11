From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 14:48:40 -0500 (EST)
Message-ID: <20151111.144840.430771235700359719.davem@davemloft.net>
References: <yw1x7flonxs5.fsf@unicorn.mansr.com>
	<20151111.142650.1297832998846138251.davem@davemloft.net>
	<yw1x37wcnxcm.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbbKKTsm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:48:42 -0500
In-Reply-To: <yw1x37wcnxcm.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: M=E5ns Rullg=E5rd <mans@mansr.com>
Date: Wed, 11 Nov 2015 19:35:05 +0000

>> I don't think it's silly at all.
>=20
> I'm sure I read somewhere that the time spent spinning on a lock shou=
ld
> be kept as small as possible.
>=20
>> And unless you can measure it making a difference, don't knock the i=
dea.
>=20
> I tried using netif_tx_lock() in the IRQ handler instead, and it lock=
ed
> up solid.  Clearly that was the wrong thing to do.

Oh that's right, it's a BH lock not an IRQ one.

Yet another argument for doing everything in ->poll(), thus making all
operations outside of NAPI scheduling run in software interrupt
context, and therefore being able to make use of the TXQ lock for
this.
