From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Wed, 20 Jul 2016 10:25:21 +0200
Message-ID: <4806848.QL77nxBrs4@wuerfel>
References: <20160719153403.2967812-1-arnd@arndb.de> <3858062.NGQDOLnTj0@wuerfel> <wrfjlh0xvck3.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Mateusz Kulikowski <mateusz.kulikowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <wrfjlh0xvck3.fsf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, July 19, 2016 12:05:00 PM CEST Jes Sorensen wrote:
> Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> writes:
> > On Tuesday, July 19, 2016 11:46:04 AM CEST Jes Sorensen wrote:
> >> > diff --git a/drivers/staging/rtl8192e/rtl819x_TSProc.c b/drivers/staging/rtl8192e/rtl819x_TSProc.c
> >> > index 2c8a526773ed..e0a2fe5e6148 100644
> >> > --- a/drivers/staging/rtl8192e/rtl819x_TSProc.c
> >> > +++ b/drivers/staging/rtl8192e/rtl819x_TSProc.c
> >> > @@ -323,7 +323,7 @@ bool GetTs(struct rtllib_device *ieee, struct ts_common_info **ppTS,
> >> >       if (ieee->current_network.qos_data.supported == 0) {
> >> >               UP = 0;
> >> >       } else {
> >> > -             if (!IsACValid(TID)) {
> >> > +             if (!IsACValid((s8)TID)) {
> >> >                       netdev_warn(ieee->dev, "%s(): TID(%d) is not valid\n",
> >> >                                   __func__, TID);
> >> >                       return false;
> >> 
> >> TID is a 4-bit field, it should never go negative. The cast to s8 seems
> >> wrong to me, if anything it should be using u8. I do realize the macro
> >> IsACValid checks against negative too, but that just looks silly to me.
> >
> > Ok, I'll remove the extra comparison then to avoid the warning:
> >
> > staging/rtl8192e/rtl819x_TSProc.c:326:14: error: comparison is always
> > true due to limited range of data type [-Werror=type-limits]
> >
> > I guess it should be a separate patch. I had just stumbled over the
> > same thing before resending the patch but decided not to change it
> > to keep the patch simple.
> 
> I think that would be better, albeit not a big issue. 

Ok, and since Kalle applied the first patch to his tree, I'm now sending
a series of three patches that are all for Greg, which also avoids some
possible confusion.

> I'd like to get rid of all the drivers/staging/rtl* drivers eventually 

That would be great, yes.

Can you clarify what the long-term plan is? I see that
drivers/net/wireless/realtek/rtlwifi/ has most of the PCIe parts
and one USB device (rtl8192cu/rtl8188cus) while
drivers/net/wireless/rtl8xxx has all the USB parts including
that one.

Does that mean we want the staging drivers for PCIe devices
to get merged into rtlwifi, and the remaining USB drivers to get
replaced by r8xxxu?

As one data point that I can provide (but you are probably
aware of), I could never get my rtl8188cus stick to work with
rtlwifi, but I found the older r8712u device to work fine with
the staging/rtl8712 driver.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
