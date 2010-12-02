From: David Miller <davem@davemloft.net>
Subject: Re: bridge netpoll support: mismatch between net core and bridge
 headers
Date: Thu, 02 Dec 2010 09:51:35 -0800 (PST)
Message-ID: <20101202.095135.226774598.davem@davemloft.net>
References: <AANLkTi=hq6S_NvPEkTovkceUe9Orcitj_oHN1mVUW7+A@mail.gmail.com>
	<20101201.163319.193705748.davem@davemloft.net>
	<AANLkTimO79DLyCb5vXQ04keX6Mjwv32wNQLRZcfyPNF2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753044Ab0LBRvJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 12:51:09 -0500
In-Reply-To: <AANLkTimO79DLyCb5vXQ04keX6Mjwv32wNQLRZcfyPNF2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Mike Frysinger <vapier.adi@gmail.com>
Date: Thu, 2 Dec 2010 03:29:17 -0500

> On Wed, Dec 1, 2010 at 19:33, David Miller wrote:
>> Attached. =A0Also please provide one of the failing ".config" files,
>> and please test if simply going "make oldconfig" unbreaks things.
>> It may be that randconfig allows configurations that the config
>> system normally does not allow.
>=20
> hrm, so your patch does fix things.  the downside is that it might be
> caused by kgdboe (which isnt in mainline yet).  that's the only
> randconfig i can find so far to cause the issue.

If that's the case you just need to check and make sure that kgdboe
handles dependencies properly in it's Kconfig changes.

I suspect that simply adding kgdboe as a new "or" case to the
"def_bool" statement of NETPOLL in driver/net/Kconfig will fix the
problem.

If kgdboe is using "select" to handle these dependencies, that's the
bug.
