From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: virtio-net: new section mismatch warning. revert patch?
Date: Wed, 4 Nov 2009 18:25:00 +0100
Message-ID: <20091104172500.GB6323@merkur.ravnborg.org>
References: <20091104141729.GA27288@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alex Williamson <alex.williamson@hp.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:40747 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757316AbZKDRY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 12:24:56 -0500
Content-Disposition: inline
In-Reply-To: <20091104141729.GA27288@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 04, 2009 at 04:17:30PM +0200, Michael S. Tsirkin wrote:
> With v2.6.32-rcX I started getting section mismatch warnings for
> virtio_net.
> make with CONFIG_DEBUG_SECTION_MISMATCH=3Dy shows:
>=20
> WARNING: drivers/net/virtio_net.o(.data+0x90): Section mismatch in
> reference from the variable virtio_net to the function
> .devexit.text:virtnet_remove()                                       =
                            =20
> The variable virtio_net references                                   =
                                        =20
> the function __devexit virtnet_remove()                              =
                                        =20
> If the reference is valid then annotate the                          =
                                        =20
> variable with __exit* (see linux/init.h) or name the variable:       =
                                        =20
> *driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_c=
onsole,                                 =20
>=20
> virtnet_remove was converted to devexit by this commit:
>=20
> 	commit 3d1285beff2e8467b8c3884d83b7a91a99aa9fcd
> 	Author: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> 	Date:   Wed Sep 30 22:28:34 2009 +0000
>=20
> 	    move virtnet_remove to .devexit.text
>=20
> We didn't have these warnings in v2.6.31, so this is a regression.
> revert?

It is correct to annotate the exit function __devexit.
So we should try to silence modpost in other ways.

Two options:
1) annotate the virtio_net variable with __ref to tell
   it is allowed to reference __init, __exit annotated stuff.
2) Rename virtio_net to virtio_net_driver

This is not a "my machine no longer works" issue but it would
be nice to have it sorted out one way or the other before next -rc.

	Sam
