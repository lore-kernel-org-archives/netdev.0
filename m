From: Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Wed, 28 May 2014 12:44:35 -0700
Message-ID: <53863CA3.7040000@codeaurora.org>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org> <1400875040-13269-2-git-send-email-sboyd@codeaurora.org> <20140524124858.GR22111@sirena.org.uk> <5385063F.30407@codeaurora.org> <20140528151646.GU20155@pengutronix.de> <20140528171219.GD5099@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140528171219.GD5099-GFdadSzt00ze9xe1eoZjHA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/28/14 10:12, Mark Brown wrote:
> On Wed, May 28, 2014 at 05:16:46PM +0200, Uwe Kleine-K=F6nig wrote:
>> On Tue, May 27, 2014 at 02:40:15PM -0700, Stephen Boyd wrote:
>>> On 05/24/14 05:48, Mark Brown wrote:
>>>> So, according to the datasheet I managed to find this device has a
>>>> supply VDD_IO (so normally written vdd-io-supply here), some other
>>>> supplies which are tied to VDD_IO (so can probably be omitted) and=
 a
>>>> supply VDD_A3.3 none of which are optional.  There is an internal
>>>> regulator which can be used to drop a higher voltage VDD_IO down f=
or
>>>> some of the supplies tied to it but that's essentially a noop from
>>>> software as far as I can tell.  None of these supplies are obvious=
ly
>>>> optional, though I've not read the datasheet in detail so I may ha=
ve
>>>> missed something here.
>> There is a difference between the supply being optional for the hard=
ware
>> to work and the need to specify it in the device tree, isn't it? My
>> expectation is that when it's not specified there is just nothing th=
e
>> the software needs to care for.=20
> If the supply must always be physically present the bindings should b=
e
> specified as it being mandatory and the code written in that fashion;=
 as
> an extension Linux will put a dummy in but this is attempting to hand=
le
> incorrect DTs.  This means we have functional error handling in cases
> where there is something to worry about and simplifies the code using
> the regulator.

Ok, you're saying the opposite of Rob. Should it be required or optiona=
l
in the DT binding?

>
> regulator_get_optional() should *only* be used if the supply may be
> omitted from the physical design and should generally always be
> accompanied by code which does something substantially different such=
 as
> using an internal regulator or changing the source for a reference
> voltage instead.
>
>

Ok. Dave M has already picked up all these patches so I'll send a patch
to replace regulator_get_optional() with regulator_get() and fix up the
error handling unless I hear otherwise.

--=20
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
