From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Mon, 29 Mar 2010 00:04:16 +0200
Message-ID: <20100328220416.GB4220@electric-eye.fr.zoreil.com>
References: <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
 <20100327.193815.242127373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, timo.teras@iki.fi, ivecera@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:46145 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755285Ab0C1WFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 18:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20100327.193815.242127373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Probably the rest of the driver should be audited for other
> areas where we may end up having this problem.

Those look safe
- MAC0
- MAC4
- MAR0
- CounterAddrLow
- CounterAddrHigh
- TxDescStartAddrLow
- TxDescStartAddrHigh
- RxDescAddrLow
- RxDescAddrHigh

The other candidates are not used yet.

[...]
> 1) Coverage for all possible bug cases.
>
> 2) Real 64-bit accesses on 64-bit platforms.

I see your point but the MACx and MARx registers are nowhere documented
as 64 bit : MAC0 and MAC4 (0x00 to 0x07) span IDR[0..5] + two reserved
bytes while MARx are documented as MAR[7..0] (0x08 to 0x0f). It would
be nice if it happened to work though.

-- 
Ueimor
