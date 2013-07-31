From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: Don't let ndo_start_xmit return
 NETDEV_TX_BUSY without link
Date: Wed, 31 Jul 2013 11:51:01 -0700 (PDT)
Message-ID: <20130731.115101.340503855490269301.davem@davemloft.net>
References: <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20130730.160530.831845971567683172.davem@davemloft.net>
	<20130731081649.GA1754@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com,
	Frank.Li@freescale.com, shawn.guo@linaro.org,
	kernel@pengutronix.de, hector.palacios@digi.com,
	tim.sander@hbm.com, rostedt@goodmis.org, tglx@linutronix.de,
	stephen@networkplumber.org, B38611@freescale.com,
	florian@openwrt.org, bhutchings@solarflare.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab3GaSvF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 14:51:05 -0400
In-Reply-To: <20130731081649.GA1754@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Wed, 31 Jul 2013 10:16:49 +0200

> On Tue, Jul 30, 2013 at 04:05:30PM -0700, David Miller wrote:
>> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Date: Tue, 30 Jul 2013 11:29:40 +0200
>>=20
>> > Don't test for having link and let hardware deal with this situati=
on.
>> >=20
>> > Without this patch I see a machine running an -rt patched Linux be=
ing
>> > stuck in sch_direct_xmit when it looses link while there is still =
a
>> > packet to be sent. In this case the fec_enet_start_xmit routine re=
turned
>> > NETDEV_TX_BUSY which makes the network stack reschedule the packet=
 and
>> > so sch_direct_xmit calls fec_enet_start_xmit again.
>> > I failed to reproduce a complete hang without -rt, but I think the
>> > problem exists there, too.
>> >=20
>> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>=20
>> Applied, thanks.
> Thanks, I see it as a264b981f2c76e281ef27e7232774bf6c54ec865 in net.g=
it
> (i.e.
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=
=3Da264b981f2c76e281ef27e7232774bf6c54ec865)
>=20
> You missed to take the
>=20
> 	Acked-and-tested-by: Fugang Duan <B38611@freescale.com>

This is not an official tag recognized by patchwork, he should say:

Acked-by: Fugang Duan <B38611@freescale.com>
Tested-by: Fugang Duan <B38611@freescale.com>

> . If you want to fix that, you can do:
>=20
> 	git filter-branch --msg-filter 'if test $GIT_COMMIT =3D a264b981f2c7=
6e281ef27e7232774bf6c54ec865; then sed "/David/ i Acked-and-tested-by: =
=46ugang Duan <B38611@freescale.com>"; else cat; fi' a264b981f2c76e281^=
=2E.
>=20
> on your master branch to add it to that commit.

My GIT history is permanent once pushed out, I cannot change history or=
 else it
would break everyone cloning my tree.
