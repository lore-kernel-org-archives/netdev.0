From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Sat, 27 Mar 2010 19:38:15 -0700 (PDT)
Message-ID: <20100327.193815.242127373.davem@davemloft.net>
References: <1269732054.8653.155.camel@localhost>
	<20100327.163005.28815553.davem@davemloft.net>
	<20100328003143.GA8501@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, timo.teras@iki.fi, ivecera@redhat.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751671Ab0C1Chx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Mar 2010 22:37:53 -0400
In-Reply-To: <20100328003143.GA8501@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Romieu <romieu@fr.zoreil.com>
Date: Sun, 28 Mar 2010 01:31:43 +0100

> This is quite similar to b39fe41f481d20c201012e4483e76c203802dda7
> though said registers are not even documented as 64-bit registers
> - as opposed to the initial TxDescStartAddress ones - but as single
> bytes which must be combined into 32 bits at the MMIO read/write
> level before being merged into a 64 bit logical entity.
>=20
> Credits go to Ben Hutchings <ben@decadent.org.uk> for the MAR
> registers (aka "multicast is broken for ages on ARM) and to
> Timo Ter=E4s <timo.teras@iki.fi> for the MAC registers.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks Francois.

Probably the rest of the driver should be audited for other
areas where we may end up having this problem.

Or, we should create readq/writeq macros (like other drivers do on
32-bit platforms, f.e. see drivers/net/niu.c) which write the two
32-bit parts in this required order.  Then access the registers using
readq/writeq entities throughout the driver.

This would have two benefits:

1) Coverage for all possible bug cases.

2) Real 64-bit accesses on 64-bit platforms.

Just some suggestions.

Thanks.
