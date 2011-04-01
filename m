From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available to drivers
Date: Fri, 1 Apr 2011 17:58:44 -0600
Message-ID: <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
References: <20110202195417.228e2656@queued.net> <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca> <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo> <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
 <20110401235239.GE29397@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110401235239.GE29397@sortiz-mobl>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 1, 2011 at 5:52 PM, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wr=
ote:
> On Fri, Apr 01, 2011 at 11:56:35AM -0600, Grant Likely wrote:
>> On Fri, Apr 1, 2011 at 11:47 AM, Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org=
> wrote:
>> > On Fri, 1 Apr 2011 13:20:31 +0200
>> > Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
>> >
>> >> Hi Grant,
>> >>
>> >> On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
>> > [...]
>> >> > Gah. =A0Not all devices instantiated via mfd will be an mfd dev=
ice,
>> >> > which means that the driver may very well expect an *entirely
>> >> > different* platform_device pointer; which further means a very =
high
>> >> > potential of incorrectly dereferenced structures (as evidenced =
by a
>> >> > patch series that is not bisectable). =A0For instance, the xili=
nx ip
>> >> > cores are used by more than just mfd.
>> >> I agree. Since the vast majority of the MFD subdevices are MFD
>> >> specific IPs, I overlooked that part. The impacted drivers are th=
e
>> >> timberdale and the DaVinci voice codec ones.
>>
>> Another option is you could do this for MFD devices:
>>
>> struct mfd_device {
>> =A0 =A0 =A0 =A0 struct platform_devce pdev;
>> =A0 =A0 =A0 =A0 struct mfd_cell *cell;
>> };
>>
>> However, that requires that drivers using the mfd_cell will *never*
>> get instantiated outside of the mfd infrastructure, and there is no
>> way to protect against this so it is probably a bad idea.
>>
>> Or, mfd_cell could be added to platform_device directly which would
>> *by far* be the safest option at the cost of every platform_device
>> having a mostly unused mfd_cell pointer. =A0Not a significant cost i=
n my
>> opinion.
> I thought about this one, but I had the impression people would want =
to kill
> me for adding an MFD specific pointer to platform_device. I guess it'=
s worth
> giving it a try since it would be a simple and safe solution.
> I'll look at it later this weekend.
>
> Thanks for the input.

[cc'ing gregkh because we're talking about modifying struct platform_de=
vice]

I'll back you up on this one.  It is a far better solution than the
alternatives.  At least with mfd, it covers a large set of devices.  I
think there is a strong argument for doing this.  Or alternatively,
the particular interesting fields from mfd_cell could be added to
platform_device.  What information do child devices need access to?

g.
