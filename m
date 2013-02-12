From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Issue with Micrel PCI Network Driver.
Date: Tue, 12 Feb 2013 12:07:47 +0000
Message-ID: <1360670867.5374.249.camel@deadeye.wl.decadent.org.uk>
References: <51158774.8080405@novatechweb.com>
	 <1360604764.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
	 <1360604823.2701.11.camel@bwh-desktop.uk.solarflarecom.com>
	 <87halhkfkc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <joseph.lutz@novatechweb.com>, <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24975 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758826Ab3BLMID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:08:03 -0500
In-Reply-To: <87halhkfkc.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:10 +0100, Bj=C3=B8rn Mork wrote:
> Ben Hutchings <bhutchings@solarflare.com> writes:
> > On Mon, 2013-02-11 at 17:46 +0000, Ben Hutchings wrote:
> >> On Fri, 2013-02-08 at 17:17 -0600, Joseph Lutz wrote:
> >> > I am having an issue with one of the network interface drivers. =
The=20
> >> > driver in question is 'drivers/net/ethernet/micrel/ksz884x.c', t=
he=20
> >> > driver for the Micrel-Kendin device 8841.
> >> > I am trying to get systemd to rename the three network interface=
s in my=20
> >> > embedded atom system. I have one of the interfaces being renamed=
 (an=20
> >> > Intel Corporation 82574L), but the two Micrel interfaces are not=
 being=20
> >> > renamed. I traced this down to the driver not populating the=20
> >> > /sys/devices/pci* information. Instead it places the driver into=
=20
> >> > /sys/devices/virtual/net/.
> >> [...]
> >>=20
> >> Right, this driver doesn't specify the parent device (PCI device) =
for
> >> the net devices it creates.
> >>=20
> >> All you should need to is add:
> >> 	SET_NETDEV_DEV(dev, pdev);
> >> underneath the call to alloc_etherdev().
> >
> > Or rather:
> > 	SET_NETDEV_DEV(dev, &pdev->dev);
>=20
>=20
> That should of course be fixed.  But this bug should not prevent
> userspace from renaming the device, should it? Sounds like a userspac=
e
> application making too many stupid assumptions to me.  Does it work f=
or
> network devices attached to other buses?

It prevents userspace from applying a naming policy that incorporates
the PCI slot number.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
