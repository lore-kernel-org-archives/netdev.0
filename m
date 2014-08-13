From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Parent device of MDIO bus
Date: Wed, 13 Aug 2014 12:43:14 -0300
Message-ID: <CAOMZO5CAfLYq_LTHMhemHY1GZKFYEs-ucW313F9CmpTjWRdNig@mail.gmail.com>
References: <m3egwkwl9v.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:42631 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbaHMPnQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 11:43:16 -0400
Received: by mail-la0-f54.google.com with SMTP id hz20so9095316lab.41
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 08:43:14 -0700 (PDT)
In-Reply-To: <m3egwkwl9v.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2014 at 10:51 AM, Krzysztof Ha=C5=82asa <khalasa@piap.p=
l> wrote:
> Hi,
>
> I noticed a recent change a71e3c37960ce5f9c6a519bc1215e3ba9fa83e75:
>     net: phy: Set the driver when registering an MDIO bus device
>
>     mdiobus_register() registers a device which is already bound to a=
 driver.
>     Hence, the driver pointer should be set properly in order to trac=
k down
>     the driver associated to the MDIO bus.
>
>     This will be used to allow ethernet driver to pin down a MDIO bus=
 driver,
>     preventing it from being unloaded while the PHY device is running=
=2E
>
> Does this mean an MDIO driver must now be separate from its Ethernet
> driver in order for the latter to be rmmod-able? Otherwise, the Ether=
net
> .probe (*_init_one()) calls mdiobus_register() and immediately bumps
> refcount (for both drivers in a common module) forever.
>
> The other option seems to be moving mdio_register() from Ethernet's
> .probe() to dev->open(). This will make the driver un-rmmod-able when
> the Ethernet device is open (not a big problem and we had it this way
> some time ago). It will be rmmod-able again when all Ethernets are
> closed.
>
> Or am I missing something?
> What do you think?

This patch has been reverted in mainline.
