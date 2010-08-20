From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Fri, 20 Aug 2010 14:08:49 -0600
Message-ID: <AANLkTine=VLLm4+ReKeMKBdbV1JsunNagwKxGMDhEe8e@mail.gmail.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
 <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
 <3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com> <AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
 <87hbiql89d.fsf@deeprootsystems.com> <AANLkTinaddiPAcokH3fRVYAFf3N-Gz--U5Jd1iyNsi+m@mail.gmail.com>
 <87hbip9kxx.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"gregkh@suse.de" <gregkh@suse.de>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kyle D Moffett <kyle@moffetthome.net>
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87hbip9kxx.fsf@deeprootsystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 20, 2010 at 12:51 PM, Kevin Hilman
<khilman@deeprootsystems.com> wrote:
> Grant Likely <grant.likely@secretlab.ca> writes:
>
> [...]
>
>>> One of the primary goals of this (at least for me and it seems Magn=
us also)
>>> is to keep drivers ignorant of their bus type, and any bus-type-spe=
cific
>>> code should be done in the bus_type implementation.
>>
>> Heh; which just screams to me that bus_type is the wrong level to be
>> abstracting the behaviour
>
> Heh, now I feel like we're going around in circles. =A0Remember, I ne=
ver
> wanted to create add a new bus_type. =A0Someone else [ahem] suggested
> doing the abstraction at the bus_type level. =A0;)

Hey!  I didn't suggest it either!  I believe that was Greg at ELC.  I
just... um... kind of took it and ran with it.  :-)

>> (but I also understand your need for the
>> "omap_device" wrapper around platform_device which also requires som=
e
>> method to sort out when a platform_device really is an omap_device
>> without an unsafe dereference).
>
> Yes, I'm working on the devres approach to that now, as is Magnus for
> the sh-mobile version (proposed for .36-rc1[1])
>
>>> Both for SH and OMAP, we've been using the (admiteddly broken)
>>> weak-symbol-override approach to getting a custom bus-type based on=
 the
>>> platform_bus. =A0We've been using that in OMAP for a while now and =
have
>>> not seen any need to for the drivers to know if they are on the van=
illa
>>> platform_bus or the customized one.
>>>
>>> I'm very curious to hear what type of impact you expect to the driv=
ers.
>>
>> My fears on this point may very well be unfounded. =A0This isn't the
>> hill I'm going to die on either. =A0Show me an implementation of dri=
ver
>> sharing that is clean and prove me wrong! =A0:-)
>
> IMHO, simply overriding the few dev_pm_ops methods was the cleanest a=
nd
> simplest.
>
> Since we seem to be in agreement now that the a new bus may not the
> right abstraction for this (since we want it to be completely
> transparent to the drivers), I'll go back to the original design. =A0=
No new
> bus types, keep the platform_bus as is, but simply override the few
> dev_pm_ops methods I care about. =A0This is what is done on SH,
> SH-Mobile[1] and my original version for OMAP that started this
> conversation.
>
> Yes, the weak-symbol method of overriding is not scalable, but that's=
 a
> separate issue from whether or not to create a new bus. =A0I have a
> proposed fix for the weak which I'll post shortly.

Okay.

One constraint remains though:  If you can override the dev_pm_ops on
a per-device or per-device-parent basis, then you've got my support.
If the override (even when fixed to work at runtime) applies to every
device on the platform_bus_type, then I'll nack it.  My concern here
is that the SoC or platform support code doesn't get to "own" the
platform_bus_type.  Other drivers/code can register their own set of
platform_devices, which may also need to perform their own dev_pm_ops
override.  If the override is global to the platform_bus_type, then
the model will not scale.

Cheers,
g.
