From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 6 Jan 2012 18:25:09 +0000
Message-ID: <1325874309.25896.2.camel@bwh-desktop>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
	 <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
	 <1325788584.3764.28.camel@bwh-desktop>
	 <F6FB0E698C9B3143BDF729DF22286646027184@ORSMSX102.amr.corp.intel.com>
	 <CAHXqBF+ZY-KH8hOi+QnDZVHx+8OOqP5CLXR44YtDLB3=1DDEOA@mail.gmail.com>
	 <363B5007A0D944459CBE9CF6A37B891B01E292@ORSMSX104.amr.corp.intel.com>
	 <1325873362.2850.20.camel@bwh-desktop>
	 <363B5007A0D944459CBE9CF6A37B891B01E718@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Miroslaw <mirqus@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:61609 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758899Ab2AFSZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 13:25:15 -0500
In-Reply-To: <363B5007A0D944459CBE9CF6A37B891B01E718@ORSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-06 at 18:20 +0000, Waskiewicz Jr, Peter P wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Friday, January 06, 2012 10:09 AM
> > To: Waskiewicz Jr, Peter P
> > Cc: Michal Miroslaw; Skidmore, Donald C; Kirsher, Jeffrey T;
> > davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> > sassmann@redhat.com
> > Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal =
data
> >=20
> > On Fri, 2012-01-06 at 17:55 +0000, Waskiewicz Jr, Peter P wrote:
> > > > -----Original Message-----
> > > > From: Micha=C5=82 Miros=C5=82aw [mailto:mirqus@gmail.com]
> > > > Sent: Thursday, January 05, 2012 3:51 PM
> > > > To: Skidmore, Donald C
> > > > Cc: Ben Hutchings; Kirsher, Jeffrey T; davem@davemloft.net;
> > > > netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com;
> > > > Waskiewicz Jr, Peter P
> > > > Subject: Re: [net-next 8/9] ixgbe: add interface to export ther=
mal
> > > > data
> > > >
> > > > Drivers outside of drivers/hwmon just select HWMON in Kconfig. =
This
> > > > adds a 3kB .c file to the kernel build for the first one that n=
eeds it.
> > >
> > > This is where we run into issues though.  We can put this depende=
ncy
> > > in, but customers don't pull upstream kernels, they rely on the O=
SV's
> > > to distribute updates.  The customer doesn't want HWMON, and if t=
heir
> > > kernel doesn't ship with HWMON support for ixgbe, then we're sunk=
=2E
> >=20
> > So if !IS_ENABLED(CONFIG_HWMON), don't try to create an hwmon devic=
e,
> > but create the attributes anyway.
>=20
> And if CONFIG_HWMON is not enabled, are we then responsible for
> creating the hwmon area in sysfs to link in our attributes?  That
> would make even less sense to include HWMON attributes if HWMON isn't
> built in.

No, the attributes actually appear under the parent device.

> > > The point is what we're trying to implement, based on what our cu=
stomers'
> > > requirements are, is something completely different than what HWM=
ON is
> > > providing.  Trying to wedge HWMON onto this framework we're tryin=
g to
> > > provide just overcomplicates the entire thing we're trying to pro=
vide.
> > > It's a generic interface to generic data in our drivers,
> > [...]
> >=20
> > It sounds like you want to provide a "generic" ixgbe interface on d=
ifferent
> > operating systems.  But that is not a valid argument for an in-tree=
 driver.
>=20
> No, we're trying to provide a generic ixgbe interface on Linux
> systems.  The reality is different OSV's pull our driver from upstrea=
m
> to build their distros,

Yes we know.

[...]
> The reality is these attributes of our thermal sensors are about 5% o=
f
> the data we need to export.
[...]

And I think all you need to do is (1) give these particular attributes
the right names and (2) create a child hwmon device if possible.  Is
that so hard?

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
