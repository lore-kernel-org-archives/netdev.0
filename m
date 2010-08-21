From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Fri, 20 Aug 2010 17:10:00 -0700
Message-ID: <87y6c03jxj.fsf@deeprootsystems.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
	<1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
	<3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com>
	<AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
	<87hbiql89d.fsf@deeprootsystems.com>
	<AANLkTinaddiPAcokH3fRVYAFf3N-Gz--U5Jd1iyNsi+m@mail.gmail.com>
	<87hbip9kxx.fsf@deeprootsystems.com>
	<AANLkTine=VLLm4+ReKeMKBdbV1JsunNagwKxGMDhEe8e@mail.gmail.com>
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
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53087 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab0HUAKE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 20:10:04 -0400
In-Reply-To: <AANLkTine=VLLm4+ReKeMKBdbV1JsunNagwKxGMDhEe8e@mail.gmail.com>
	(Grant Likely's message of "Fri, 20 Aug 2010 14:08:49 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely <grant.likely@secretlab.ca> writes:

[...]

>>>
>>> My fears on this point may very well be unfounded. =A0This isn't th=
e
>>> hill I'm going to die on either. =A0Show me an implementation of dr=
iver
>>> sharing that is clean and prove me wrong! =A0:-)
>>
>> IMHO, simply overriding the few dev_pm_ops methods was the cleanest =
and
>> simplest.
>>
>> Since we seem to be in agreement now that the a new bus may not the
>> right abstraction for this (since we want it to be completely
>> transparent to the drivers), I'll go back to the original design. =A0=
No new
>> bus types, keep the platform_bus as is, but simply override the few
>> dev_pm_ops methods I care about. =A0This is what is done on SH,
>> SH-Mobile[1] and my original version for OMAP that started this
>> conversation.
>>
>> Yes, the weak-symbol method of overriding is not scalable, but that'=
s a
>> separate issue from whether or not to create a new bus. =A0I have a
>> proposed fix for the weak which I'll post shortly.
>
> Okay.
>
> One constraint remains though:  If you can override the dev_pm_ops on
> a per-device or per-device-parent basis, then you've got my support.

hmm, a new requirement?, and one that would require some significant
changes to the driver model.

Currently, dev_pm_ops for a bus applies globally to *all* devices on
that bus (or class or type) and changing that would require changing th=
e
platform_bus code to start having per-device (or per-parent-device)
checks.=20

> If the override (even when fixed to work at runtime) applies to every
> device on the platform_bus_type, then I'll nack it. =20

/me can't help but wonder why the OMAP implementation is getting all th=
e
negative attention while the other identical implementations are alread=
y
upstream.

> My concern here is that the SoC or platform support code doesn't get
> to "own" the platform_bus_type.

Well, I'm not proposing that here.  This "feature" already exists in
mainline (albeit using the less-than-optimal weak symbol approach.)  Al=
l
I'm proposing is fixing it to make it multi-arch friendly.

If you think this behavior should be changed to non global, that should
be done a separate series since it is not directly related to runtime P=
M
support for a given platform, IMO.

> Other drivers/code can register their own set of
> platform_devices, which may also need to perform their own dev_pm_ops
> override. =20

IMHO, we should deal with such hypothetical, future problems *if* they
arise down the road.

> If the override is global to the platform_bus_type, then the model
> will not scale.

It will not scale any more (or less) than the current functionality of
the driver model which handles this globally.  Again, if scalabilty
becomes a problem down the road, lets fix it then.

Kevin
