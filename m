From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio-net: new section mismatch warning. revert patch?
Date: Thu, 5 Nov 2009 15:10:53 +1030
Message-ID: <200911051510.54163.rusty@rustcorp.com.au>
References: <20091104141729.GA27288@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Uwe =?iso-8859-1?q?Kleine-K=F6nig?="
	<u.kleine-koenig@pengutronix.de>, Sam Ravnborg <sam@ravnborg.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alex Williamson <alex.williamson@hp.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Greg KH <gregkh@suse.de>,
	Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50743 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956AbZKEEkv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 23:40:51 -0500
In-Reply-To: <20091104141729.GA27288@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Nov 2009 12:47:30 am Michael S. Tsirkin wrote:
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

No, just rename "virtio_net" to "virtio_net_driver".  Meanwhile, ignore=
 it.
It's worked well for me so far.

Uwe: I apologize for accepting your patches.  I will be more careful in
future.

Cheers,
Rusty.
