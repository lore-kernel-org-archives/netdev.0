From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Please revert removal of /sys/class/net/*/features
Date: Tue, 10 Apr 2012 13:46:33 -0700
Message-ID: <20120410134633.4456a1b0@nehalam.linuxnetplumber.net>
References: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
	<20120410195956.GA28447@rere.qmqm.pl>
	<1334089547.2624.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35376 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab2DJUqg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 16:46:36 -0400
In-Reply-To: <1334089547.2624.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Apr 2012 21:25:47 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2012-04-10 at 21:59 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > On Tue, Apr 10, 2012 at 11:08:51AM -0700, Stephen Hemminger wrote:
> > > This commit needs to be reverted. It removed an available sysfs f=
ile, and sysfs
> > > files are part of the ABI. It caused a bug in our current release=
 of Vyatta because
> > > the shell script was using the sysfs file to see if VLAN was supp=
orted on a device.
> > >=20
> > > An API maybe redundant, but you can't just remove it.
> >=20
> > There was a discussion about it before the patch was accepted. It w=
as
> > concluded that due to features flags changes, the /sys/class/net/*/=
features
> > was never a stable API.
>=20
> For reference:
> http://thread.gmane.org/gmane.linux.network/199115/focus=3D199136
>=20
> But note that the VLAN-related feature flags never actually changed
> value.
>=20
> Ben.
>=20

It is actually not a big deal for our product since 3.3 is
really early in development cycle and the script can be fixed in
that release. Also, we release an image with utilities, scripts and
kernel in one release, and don't have to support running new kernels wi=
th
older userspace.

I am more worried that other people might be hit=20
the same thing. What about a patch to keep the old flags values
available for backwards compatiablity. Also, when removing a sysfs
file, shouldn't the documented feature removal process be used?
