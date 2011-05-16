From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: Change netdev_fix_features messages loglevel
Date: Mon, 16 May 2011 23:37:39 +0300
Message-ID: <20110516203739.GC18148@redhat.com>
References: <20110516131757.ED57E13A6A@rere.qmqm.pl>
 <20110516.151434.829498612745581899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	herbert@gondor.hengli.com.au, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484Ab1EPUiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 16:38:07 -0400
Content-Disposition: inline
In-Reply-To: <20110516.151434.829498612745581899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 03:14:34PM -0400, David Miller wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 16 May 2011 15:17:57 +0200 (CEST)
>=20
> > Those reduced to DEBUG can possibly be triggered by unprivileged pr=
ocesses
> > and are nothing exceptional. Illegal checksum combinations can only=
 be
> > caused by driver bug, so promote those messages to WARN.
> >=20
> > Since GSO without SG will now only cause DEBUG message from
> > netdev_fix_features(), remove the workaround from register_netdevic=
e().
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Applied, thanks.

Cool, how about we make 'Features changed' debug as well?
This way userspace can't fill up the log just by tweaking tun features
with an ioctl.

Untested, but you get the message.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index 3ed09f8..538a1fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5270,7 +5270,7 @@ int __netdev_update_features(struct net_device *d=
ev)
 	if (dev->features =3D=3D features)
 		return 0;
=20
-	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
+	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
 		dev->features, features);
=20
 	if (dev->netdev_ops->ndo_set_features)
--=20
MST
