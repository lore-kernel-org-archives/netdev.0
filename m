From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Issue with Micrel PCI Network Driver.
Date: Tue, 12 Feb 2013 11:10:59 +0100
Message-ID: <87halhkfkc.fsf@nemi.mork.no>
References: <51158774.8080405@novatechweb.com>
	<1360604764.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
	<1360604823.2701.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <joseph.lutz@novatechweb.com>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52468 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932672Ab3BLKLl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:11:41 -0500
In-Reply-To: <1360604823.2701.11.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Mon, 11 Feb 2013 17:47:03 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:
> On Mon, 2013-02-11 at 17:46 +0000, Ben Hutchings wrote:
>> On Fri, 2013-02-08 at 17:17 -0600, Joseph Lutz wrote:
>> > I am having an issue with one of the network interface drivers. Th=
e=20
>> > driver in question is 'drivers/net/ethernet/micrel/ksz884x.c', the=
=20
>> > driver for the Micrel-Kendin device 8841.
>> > I am trying to get systemd to rename the three network interfaces =
in my=20
>> > embedded atom system. I have one of the interfaces being renamed (=
an=20
>> > Intel Corporation 82574L), but the two Micrel interfaces are not b=
eing=20
>> > renamed. I traced this down to the driver not populating the=20
>> > /sys/devices/pci* information. Instead it places the driver into=20
>> > /sys/devices/virtual/net/.
>> [...]
>>=20
>> Right, this driver doesn't specify the parent device (PCI device) fo=
r
>> the net devices it creates.
>>=20
>> All you should need to is add:
>> 	SET_NETDEV_DEV(dev, pdev);
>> underneath the call to alloc_etherdev().
>
> Or rather:
> 	SET_NETDEV_DEV(dev, &pdev->dev);


That should of course be fixed.  But this bug should not prevent
userspace from renaming the device, should it? Sounds like a userspace
application making too many stupid assumptions to me.  Does it work for
network devices attached to other buses?


Bj=C3=B8rn
