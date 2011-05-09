From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: fold dev_disable_lro() into
 netdev_fix_features()
Date: Mon, 09 May 2011 12:08:11 -0700 (PDT)
Message-ID: <20110509.120811.246541047.davem@davemloft.net>
References: <20110507114803.0D80A13A6B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, bhutchings@solarflare.com,
	bridge@lists.linux-foundation.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59465
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751551Ab1EITIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:08:44 -0400
In-Reply-To: <20110507114803.0D80A13A6B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  7 May 2011 13:48:02 +0200 (CEST)

> This moves checks that device is forwarding from bridge, IPv4 and IPv=
6
> code into netdev_fix_features(). As a side effect, after device is no=
 longer
> forwarding it gets LRO back. This also means that user is not allowed=
 to
> enable LRO after device is put to forwarding mode.
>=20
> This patch depends on removal of discrete offload setting ethtool ops=
=2E
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

We need to keep the check in the protocols because we don't want to
be testing protocol specific device state in generic code like
net/core/dev.c
