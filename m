From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Mon, 23 Aug 2010 07:53:40 -0700
Message-ID: <87tyml1itn.fsf@deeprootsystems.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
	<1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
	<3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com>
	<AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
	<87hbiql89d.fsf@deeprootsystems.com>
	<AANLkTinaddiPAcokH3fRVYAFf3N-Gz--U5Jd1iyNsi+m@mail.gmail.com>
	<87hbip9kxx.fsf@deeprootsystems.com>
	<AANLkTine=VLLm4+ReKeMKBdbV1JsunNagwKxGMDhEe8e@mail.gmail.com>
	<87y6c03jxj.fsf@deeprootsystems.com>
	<AANLkTi=WKcb59jJQuLVfqJG07Et+cU75GOC5Lrr_dXR4@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=WKcb59jJQuLVfqJG07Et+cU75GOC5Lrr_dXR4@mail.gmail.com>
	(Grant Likely's message of "Sat, 21 Aug 2010 01:10:05 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Likely <grant.likely@secretlab.ca> writes:

>>> If the override is global to the platform_bus_type, then the model
>>> will not scale.
>>
>> It will not scale any more (or less) than the current functionality =
of
>> the driver model which handles this globally. =A0Again, if scalabilt=
y
>> becomes a problem down the road, lets fix it then.
>
> Alright, I can agree to that.  I do agree that the runtime override i=
s
> far and away better than the weak symbol approach.  However, there
> needs to be some very clear rules in place for users of the override,
> namely that users must understand that they are stewards of the
> platform_bus_type, and must take care to preserve the default
> behaviour for "uninteresting" devices.

Completely agree here.

Any overrides of the dev_pm_ops functions that do not also call the
pm_generic_* functions (or their equivalents) should be suspect.

I'll post a proposal for a runtime override shortly.

> Also, the expectation should be that it is a temporary measure until =
a
> better abstraction is implemented.  It might be that a separate
> bus_type is the way to go (if the multiple driver registration proble=
m
> can be solved) or it might be a way to differentiate pm_ops either
> per-device or per-parent.  I'm not sure, but I'm starting on an OMAP
> project soon, so I may very well end up working on this.

Yes, I'll be glad to work on this too, but first I need to get through
reviewing the backlog of all the OMAP drivers we're converting to
runtime PM.

Kevin
