From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Sat, 2 Apr 2011 01:52:39 +0200
Message-ID: <20110401235239.GE29397@sortiz-mobl>
References: <20110202195417.228e2656@queued.net>
 <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca>
 <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo>
 <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2011 at 11:56:35AM -0600, Grant Likely wrote:
> On Fri, Apr 1, 2011 at 11:47 AM, Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>=
 wrote:
> > On Fri, 1 Apr 2011 13:20:31 +0200
> > Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> >
> >> Hi Grant,
> >>
> >> On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
> > [...]
> >> > Gah. =A0Not all devices instantiated via mfd will be an mfd devi=
ce,
> >> > which means that the driver may very well expect an *entirely
> >> > different* platform_device pointer; which further means a very h=
igh
> >> > potential of incorrectly dereferenced structures (as evidenced b=
y a
> >> > patch series that is not bisectable). =A0For instance, the xilin=
x ip
> >> > cores are used by more than just mfd.
> >> I agree. Since the vast majority of the MFD subdevices are MFD
> >> specific IPs, I overlooked that part. The impacted drivers are the
> >> timberdale and the DaVinci voice codec ones.
>=20
> Another option is you could do this for MFD devices:
>=20
> struct mfd_device {
>         struct platform_devce pdev;
>         struct mfd_cell *cell;
> };
>=20
> However, that requires that drivers using the mfd_cell will *never*
> get instantiated outside of the mfd infrastructure, and there is no
> way to protect against this so it is probably a bad idea.
>=20
> Or, mfd_cell could be added to platform_device directly which would
> *by far* be the safest option at the cost of every platform_device
> having a mostly unused mfd_cell pointer.  Not a significant cost in m=
y
> opinion.
I thought about this one, but I had the impression people would want to=
 kill
me for adding an MFD specific pointer to platform_device. I guess it's =
worth
giving it a try since it would be a simple and safe solution.
I'll look at it later this weekend.

Thanks for the input.

Cheers,
Samuel.

--=20
Intel Open Source Technology Centre
http://oss.intel.com/
