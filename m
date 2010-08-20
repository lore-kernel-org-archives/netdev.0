From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Fri, 20 Aug 2010 11:51:38 -0700
Message-ID: <87hbip9kxx.fsf@deeprootsystems.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
	<1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
	<3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com>
	<AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
	<87hbiql89d.fsf@deeprootsystems.com>
	<AANLkTinaddiPAcokH3fRVYAFf3N-Gz--U5Jd1iyNsi+m@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Moffett\, Kyle D" <Kyle.D.Moffett@boeing.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm\@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"magnus.damm\@gmail.com" <magnus.damm@gmail.com>,
	"gregkh\@suse.de" <gregkh@suse.de>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Kyle D Moffett <kyle@moffetthome.net>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:51356 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814Ab0HTSvm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 14:51:42 -0400
In-Reply-To: <AANLkTinaddiPAcokH3fRVYAFf3N-Gz--U5Jd1iyNsi+m@mail.gmail.com>
	(Grant Likely's message of "Thu, 19 Aug 2010 16:22:41 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely <grant.likely@secretlab.ca> writes:

[...]

>> One of the primary goals of this (at least for me and it seems Magnu=
s also)
>> is to keep drivers ignorant of their bus type, and any bus-type-spec=
ific
>> code should be done in the bus_type implementation.
>
> Heh; which just screams to me that bus_type is the wrong level to be
> abstracting the behaviour=20

Heh, now I feel like we're going around in circles.  Remember, I never
wanted to create add a new bus_type.  Someone else [ahem] suggested
doing the abstraction at the bus_type level.  ;)

> (but I also understand your need for the
> "omap_device" wrapper around platform_device which also requires some
> method to sort out when a platform_device really is an omap_device
> without an unsafe dereference).

Yes, I'm working on the devres approach to that now, as is Magnus for
the sh-mobile version (proposed for .36-rc1[1])

>> Both for SH and OMAP, we've been using the (admiteddly broken)
>> weak-symbol-override approach to getting a custom bus-type based on =
the
>> platform_bus. =A0We've been using that in OMAP for a while now and h=
ave
>> not seen any need to for the drivers to know if they are on the vani=
lla
>> platform_bus or the customized one.
>>
>> I'm very curious to hear what type of impact you expect to the drive=
rs.
>
> My fears on this point may very well be unfounded.  This isn't the
> hill I'm going to die on either.  Show me an implementation of driver
> sharing that is clean and prove me wrong!  :-)

IMHO, simply overriding the few dev_pm_ops methods was the cleanest and
simplest.

Since we seem to be in agreement now that the a new bus may not the
right abstraction for this (since we want it to be completely
transparent to the drivers), I'll go back to the original design.  No n=
ew
bus types, keep the platform_bus as is, but simply override the few
dev_pm_ops methods I care about.  This is what is done on SH,
SH-Mobile[1] and my original version for OMAP that started this
conversation.

Yes, the weak-symbol method of overriding is not scalable, but that's a
separate issue from whether or not to create a new bus.  I have a
proposed fix for the weak which I'll post shortly.

Kevin

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2010-August/0=
22411.html



