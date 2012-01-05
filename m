From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Thu, 5 Jan 2012 18:36:24 +0000
Message-ID: <1325788584.3764.28.camel@bwh-desktop>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
	 <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Miroslaw <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24223 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757881Ab2AESg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:36:28 -0500
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-05 at 17:53 +0000, Skidmore, Donald C wrote:
> >-----Original Message-----
> >From: Micha=C5=82 Miros=C5=82aw [mailto:mirqus@gmail.com]
> >Sent: Friday, December 23, 2011 9:59 AM
> >To: Kirsher, Jeffrey T
> >Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
> >gospo@redhat.com; sassmann@redhat.com; Waskiewicz Jr, Peter P
> >Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal d=
ata
> >
> >2011/12/23 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> >> From: Don Skidmore <donald.c.skidmore@intel.com>
> >>
> >> Some of our adapters have thermal data available, this patch expor=
ts
> >this
> >> data via a read-only sysfs interface.
> >
> >Just curious: can't this use the hwmon subsystem to be consistent wi=
th
> >other system monitoring devices?
> >
> >Best Regards,
> >Micha=C5=82 Miros=C5=82aw
>=20
> Sorry about the slow response, first vacation then I hadn't heard of
> hwmon and wanted to look into it a bit.  I can see why you mentioned
> it as it looks to be close to what I'm trying to do here.  However I
> don't think it quite matches.  I'll list my thoughts below:
>=20
> - We are trying to export a large set of data that our customers are
> requesting.  The thermals were just the first patch and the other dat=
a
> items wouldn't really fit well in the hwmon (i.e. FW version,
> secondary MAC address).

Nevertheless, there is a specific way that the thermal information
should be exposed.

> - Didn't seem like we had much data to offer hwmon anyway just sensor
> temp, caution threshold, maxop threshold and location of sensor.  All
> the other data (which you haven't seen yet so couldn't have known :)
> wasn't related.
> - The thermal data we do have is defined in our FW and could change
> (number of sensors) based on that FW.  I wasn't sure whether that
> would be an issue for hwmon.

I have the same issue with the current Solarflare controllers, as the
driver has no static information about specific boards.  It is possible
to generate hwmon attributes dynamically though I've not yet got round
to completing my implementation of this.  (Since firmware is also
responsible for thermal shutdown, handling any of this stuff in the
driver has been a low priority.)

> - I went with sysfs based on a conversation with Peter Waskiewicz.  H=
e
> mentioned that there was discussion on how to export generic data at
> netconf and sysfs was brought up as the best choice.=20

Sensors are also exposed through sysfs, but following a specific naming
convention and using a separate hwmon device.

(Oddly, though, the sensor attributes are must be attached to the hwmon
device's parent - which will be your PCI device.  So you may not need t=
o
make many changes.)

Ben.

> Thanks for reviewing the patch and bring up this question. :)
> -Don Skidmore <donald.c.skidmore@intel.com>

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
