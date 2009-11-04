From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: virtio-net: new section mismatch warning. revert patch?
Date: Wed, 4 Nov 2009 16:17:30 +0200
Message-ID: <20091104141729.GA27288@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alex Williamson <alex.williamson@hp.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756343AbZKDOUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 09:20:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With v2.6.32-rcX I started getting section mismatch warnings for
virtio_net.
make with CONFIG_DEBUG_SECTION_MISMATCH=3Dy shows:

WARNING: drivers/net/virtio_net.o(.data+0x90): Section mismatch in
reference from the variable virtio_net to the function
=2Edevexit.text:virtnet_remove()                                       =
                            =20
The variable virtio_net references                                     =
                                      =20
the function __devexit virtnet_remove()                                =
                                      =20
If the reference is valid then annotate the                            =
                                      =20
variable with __exit* (see linux/init.h) or name the variable:         =
                                      =20
*driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_con=
sole,                                 =20

virtnet_remove was converted to devexit by this commit:

	commit 3d1285beff2e8467b8c3884d83b7a91a99aa9fcd
	Author: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
	Date:   Wed Sep 30 22:28:34 2009 +0000

	    move virtnet_remove to .devexit.text

We didn't have these warnings in v2.6.31, so this is a regression.
revert?

--=20
MST
