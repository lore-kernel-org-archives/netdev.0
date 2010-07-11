From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] bnx2x: add support for receive hashing
Date: Sun, 11 Jul 2010 18:45:13 +0200
Message-ID: <1278866713.2538.148.camel@edumazet-laptop>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FBFB@SJEXCHCCR02.corp.ad.broadcom.com>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FD52@SJEXCHCCR02.corp.ad.broadcom.com>
	 <AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
	 <20100710.191242.70196353.davem@davemloft.net>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704DC@SJEXCHCCR02.corp.ad.broadcom.com>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704FA@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58808 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab0GKQpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 12:45:17 -0400
Received: by wyf23 with SMTP id 23so2820424wyf.19
        for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 09:45:15 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704FA@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 11 juillet 2010 =C3=A0 06:16 -0700, Vladislav Zolotarov a =C3=
=A9crit :
> Dave, it's obvious that there a demand for a new HW/FW configuration
> from our side - "rx hash enable" which is currently tightly coupled
> with the RSS capability. As long as RSS flow in our FW includes a few
> more things apart from just creating an RSS hash and as long as there
> are flows (even hypothetical) that demand the RSS hash regardless the
> RSS itself we started to work on separation of these two features fro=
m
> FW perspective. This of course will demand a new FW version but once
> we have it we'll be able to be more specific in HW configuration and
> have a cleaner code.
>=20
> Technically, our FW may provide the Rx HASH always and in a current
> driver configuration this is what it does.
> I wonder if the driver always provides the HW RX HASH in the
> skb->rxhash regardless the value of NETIF_F_RXHASH bit in a
> netdev->features will it cause any harm? If not we can get rid of two
> extra conditionals in the bnx2x_rx_int().

Hi

Please dont top-post on netdev, thanks.

NETIF_RX_HASH bit is needed so that we can disable skb->rxhash from a
particular NIC if we know the hardware provided rxhash is not fulfillin=
g
our needs (We prefer spend some cpu cycles to recompute a software
rxhash).

Software one for example deliver same rxhash values for both ways of a
TCP flow, it can help conntracking for example.

The conditional in driver rx is cheap, since the condition is the same
for all packets and CPU can predicts the branch.



