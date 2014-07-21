From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [RFC 0/2] net: phy: Prevent an MDIO bus from being unloaded
 while in use
Date: Mon, 21 Jul 2014 15:55:53 -0300
Message-ID: <20140721185552.GA20027@arch.cereza>
References: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAGVrzcYo7BKmjxLMfB7u8rkgE1o+CDkDkWvCSL4kZ8S3whx=hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56086 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933388AbaGUS4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 14:56:49 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcYo7BKmjxLMfB7u8rkgE1o+CDkDkWvCSL4kZ8S3whx=hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Thanks for the quick reply.

On 21 Jul 11:42 AM, Florian Fainelli wrote:
[..]
> >
> > This patchset fixes this by calling module_{get,put} in the etherne=
t driver.
> > After this patch, the mvmdio driver is no longer removable:
> >
> >   $ modprobe -r mvmdio
> >   modprobe: can't unload module mvmdio: Resource temporarily unavai=
lable
> >
> > Of course, we can expect a few drivers to have the same need and th=
erefore
> > we could argue about moving this to be part of the phydev connectio=
n.
>=20
> Right, that's exactly what jumps to mind when I take a look at your
> patch set. As long as a PHY device connected to a particular MDIO bus
> is in used, we should make sure its refcount does not hit zero.
>=20

Any suggestions about where to do it? I think the right place is
after the calls to bus_find_device() in of_phy_find_device() and
phy_connect().

> BTW, neither mvmdio nor mvneta seems to set their 'owner' field, is
> that intentional?
>=20

Actually, I had a patch that did so and then dropped it. The owner
is set to unconditionally for plaftorm drivers, so setting it has no
effect. See include/linux/platform_device.h:

/*
 * use a macro to avoid include chaining to get THIS_MODULE
 */
#define platform_driver_register(drv) \
        __platform_driver_register(drv, THIS_MODULE)

--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
