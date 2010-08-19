From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Thu, 19 Aug 2010 12:20:14 -0700
Message-ID: <87hbiql89d.fsf@deeprootsystems.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
	<1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
	<3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com>
	<AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
Received: from mail-pz0-f46.google.com ([209.85.210.46]:49017 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0HSTUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 15:20:18 -0400
In-Reply-To: <AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
	(Grant Likely's message of "Mon, 16 Aug 2010 00:43:01 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely <grant.likely@secretlab.ca> writes:

> I'm not convinced (yet) that this is the right approach, and I'd like
> to see a few sample drivers converted to the new approach.  Creating
> new bus_types that "inherit" from the platform_bus is actually not a
> bad idea, and it is an elegant way to change the behaviour (for
> example, how power management is implemented) for devices connected in
> a different way.
>
> A problem with the approach that Kevin pointed out is that drivers
> that need to work on both the platform_bus_type and the new
> soc_bus_type must explicitly register themselves on both bus types.

And potentially more than 2 if a driver exists for a hardware block on
different SoCs.  Magnus raised this issue for drivers used across SH and
ARM/SH-Mobile, and the same issue exists between TI OMAP and TI DaVinci
SoCs.

> There is no mechanism to allow drivers from one bus type to also be
> made available to another bus type. Certainly it would be possible to
> invent a mechanism, but the more I think about it, them more I think
> it will be a bad idea.  The runtime-PM use-case that kicked this
> discussion off makes the assumption that a driver will behave
> identically when attached to either the platform_bus_type or the
> soc_bus_type.  However, I think that in the general case that
> assumption will prove to be false.  I strongly suspect that the new
> bus type will turn out to be not as similar to the platform_bus_type
> as originally assumed and that there will still be bus-type-specific
> impact on device drivers

What makes you suspect that?  Maybe Patrick has other use-cases in mind,
but from a PM perspective, I have not seen any impact.

One of the primary goals of this (at least for me and it seems Magnus also)
is to keep drivers ignorant of their bus type, and any bus-type-specific
code should be done in the bus_type implementation.

Both for SH and OMAP, we've been using the (admiteddly broken)
weak-symbol-override approach to getting a custom bus-type based on the
platform_bus.  We've been using that in OMAP for a while now and have
not seen any need to for the drivers to know if they are on the vanilla
platform_bus or the customized one.

I'm very curious to hear what type of impact you expect to the drivers.

Kevin
