From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 RESEND 2/9] ethtool: enable GSO and GRO by default
Date: Tue, 15 Feb 2011 14:00:43 -0800 (PST)
Message-ID: <20110215.140043.59699086.davem@davemloft.net>
References: <66135e57d38599c0dfce347643858558c4f026c4.1297594674.git.mirq-linux@rere.qmqm.pl>
	<20110213.105023.68138742.davem@davemloft.net>
	<20110215214649.GA23866@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755465Ab1BOWAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 17:00:07 -0500
In-Reply-To: <20110215214649.GA23866@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 15 Feb 2011 22:46:49 +0100

> On Sun, Feb 13, 2011 at 10:50:23AM -0800, David Miller wrote:
>> From: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> Date: Sun, 13 Feb 2011 12:11:45 +0100 (CET)
>> > Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> This is not appropriate.
>>=20
>> Now, every driver that lacks SG support will spit out that warning
>> message in netdev_fix_features().
>>=20
>> That's why the check is there conditionalizing NETIF_F_GSO on
>> NETIF_F_SG in register_netdevice().
>=20
> I think all those messages should be converted to DEBUG level. Those
> conditions are constant and can be better described in
> Documentation/networking/ or ethtool manpage. Preferably along the
> device-specific conditions when implemented.
>=20
> Or I could just drop the message for the GSO case as it's something n=
ew here
> anyway (I added it to make it consistent with handling of other featu=
res).

The messages exist to let driver authors know they've constructed an
illegal set of feature bits.

Since you're now adding the GSO bit yourself, you should perform
due diligence and prevent the illegal combination yourself.

This has no other impact on the other messages and cases, which
definitely should stay intact.

Your change is just wrong and knowingly introduces useless log
messages, please just fix it up.
