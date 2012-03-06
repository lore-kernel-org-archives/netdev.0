From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] lpc32xx: Added ethernet driver
Date: Tue, 06 Mar 2012 04:13:50 -0800
Message-ID: <1331036030.2474.40.camel@edumazet-laptop>
References: <1330983641-32622-1-git-send-email-stigge@antcom.de>
	 <1330987524.2538.61.camel@bwh-desktop> <4F55D099.5070006@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	eilong@broadcom.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, w.sang@pengutronix.de,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
	baruch@tkos.co.il, joe@perches.com
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F55D099.5070006@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 06 mars 2012 =C3=A0 09:53 +0100, Roland Stigge a =C3=A9crit :

> Sounds reasonable, and will do it.
>=20
> However, I implemented it from the example of
> drivers/net/ethernet/via/via-velocity.c:velocity_poll() - is there a
> good reason for doing it that way in the velocity driver or is it don=
e
> incorrectly there, also?
>=20

Its done in a non efficient way.

It works as is, but its not the right thing to do.
The NAPI port was very minimal on via-velocity it seems.

A better way is to hold no locks in the RX handler, allowing calls to
netif_receive_skb() [ and potential calls to xmit while handling this
incoming skbs ]

Problem of saying "we dont expect to be SMP anyway", is that this let
reference material for future drivers that will copy/paste the code,
then experience performance problems.
